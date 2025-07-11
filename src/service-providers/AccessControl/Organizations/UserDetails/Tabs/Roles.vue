<script setup lang="ts">
import { computed, PropType, Ref, onMounted, ref } from "vue";
import DialogAssignRole from "../Dialogs/DialogAssignRole.vue";
import DialogRemoveRole from "../Dialogs/DialogRemoveRole.vue";
import { authService } from "~/auth/auth.service";
import {
  ServiceProviderOrganizationRead,
  ServiceProviderOrganizationUserRead,
} from "~/iam/iam.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import {
  EmptyStateType,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { PolicyRead } from "~/service-providers/Policies/policies.types";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { useUiStore } from "~/stores/useUiStore";

defineProps({
  roles: {
    type: Object as PropType<TableResponse<PolicyRead>>,
    default: () => ({}),
  },
  organizationId: {
    type: String,
    required: true,
  },
  customer: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    default: () => ({}),
  },
  user: {
    type: Object as PropType<ServiceProviderOrganizationUserRead>,
    default: () => ({}),
  },
  isLoading: {
    type: Boolean,
    required: true,
    default: false,
  },
  rolePolicyTypeCategoryId: {
    type: String,
    required: true,
  },
});

const uiStore = useUiStore();

const emit = defineEmits(["updateRoles"]);
const serviceProviderId: Ref<string> = ref("");
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const isAssignRoleDialogOpen: Ref<boolean> = ref(false);
const isRemoveRoleDialogOpen: Ref<boolean> = ref(false);
const dialogPoliciesDeleteData: Ref<PolicyTypeRead | null> = ref(null);
const allRoles: Ref<PolicyRead[]> = ref([]);
const showAssignRoleButton = computed(
  () => isSPAdmin.value || isSPEditor.value,
);

const headers = [
  {
    key: "name",
    label: "Policy name",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    key: "actions",
    label: "",
  },
];

const emptyState: EmptyStateType = {
  icon: sectionIcons["roleBased"],
  title: "Assign role to user",
  description:
    "Assign a role to this user so that the role applies to them when accessing your products.",
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/ciam/provide-access-to-customers#manually-assign-access",
};

const handleAssignRoleDialog = () => {
  isAssignRoleDialogOpen.value = !isAssignRoleDialogOpen.value;
};

const handleRemoveRoleDialog = (role: PolicyTypeRead) => {
  isRemoveRoleDialogOpen.value = !isRemoveRoleDialogOpen.value;
  if (!role) return;
  dialogPoliciesDeleteData.value = role;
};

const handleGetRoles = (roles: PolicyRead[]) => {
  allRoles.value = roles;
};

const handleRolesUpdates = () => {
  emit("updateRoles");
};

const handleUpdateRoleParams = (params: TableRequestParams) => {
  emit("updateRoles", params);
};

const getDropdownItems = (row: PolicyRead) => [
  {
    label: "Remove role",
    type: "button",
    isDisabled: uiStore.isSPViewerOnly,
    color: "error",
    onClick: () => handleRemoveRoleDialog(row),
  },
];

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  isSPAdmin.value = (await authService.isUserSPAdmin()) === true;
  isSPEditor.value = (await authService.isUserSPEditor()) === true;
});
</script>

<template>
  <m-m-expandable-card style="margin-top: 16px" title="Roles">
    <div
      class="mm-page-subtitle mm-page-subtitle--h2 mm-mb-4 mm-ml-12"
      style="align-self: start"
    >
      Roles assigned to {{ user.user?.first_name }}
      {{ user.user?.last_name }} from account
      {{ customer?.organization?.name }}
    </div>
    <m-m-table
      :is-loading="isLoading"
      :headers="headers"
      background-color="#F2F4F7"
      :rows="roles?.results"
      :total-rows="roles?.total"
      show-search
      cy="users-roles-table"
      :empty-state="emptyState"
      @update-params="handleUpdateRoleParams"
    >
      <template #empty-state-button>
        <m-m-button
          v-if="showAssignRoleButton"
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          cy="add-role-button"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="handleAssignRoleDialog"
        >
          Assign role
        </m-m-button>
      </template>
      <template #action>
        <m-m-button
          v-if="showAssignRoleButton"
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          cy="add-role-button"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="handleAssignRoleDialog"
        >
          Assign role
        </m-m-button>
      </template>
      <template #name="{ row }">
        <div class="mm-flex mm-flex-align-center">
          <span class="font-weight-500" :data-cy="`column-name-${row.id}`">{{
            row.name
          }}</span>
        </div>
      </template>
      <template #description="{ row }">
        <div class="mm-flex mm-flex-align-center">
          <span :data-cy="`column-description-${row.id}`">{{
            row.description
          }}</span>
        </div>
      </template>
      <template v-if="isSPAdmin || isSPEditor" #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="getDropdownItems(row)"
            :cy="`actions-dropdown-${row.id}`"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="text"
                :cy="`actions-${row.id}`"
              />
            </template>
          </m-m-dropdown>
        </div>
      </template>
    </m-m-table>
  </m-m-expandable-card>
  <DialogAssignRole
    :category-id="rolePolicyTypeCategoryId"
    :is-open="isAssignRoleDialogOpen"
    :data="roles"
    :organization-id="organizationId"
    :service-provider-id="serviceProviderId"
    :user="user"
    :assigned-policies="roles?.results"
    @get-roles="handleGetRoles"
    @close-dialog="handleAssignRoleDialog"
    @roles-updated="handleRolesUpdates"
  />
  <DialogRemoveRole
    :is-open="isRemoveRoleDialogOpen"
    :data="dialogPoliciesDeleteData"
    :organization-id="organizationId"
    :service-provider-id="serviceProviderId"
    :organization-name="customer?.organization?.name"
    :user="user"
    @close-dialog="handleRemoveRoleDialog"
    @roles-updated="handleRolesUpdates"
  />
</template>

<style scoped lang="scss"></style>
