<script setup lang="ts">
import { computed, PropType, Ref, onMounted, ref } from "vue";
import DialogAssignPolicy from "../Dialogs/DialogAssignPolicy.vue";
import DialogRemovePolicy from "../Dialogs/DialogRemovePolicy.vue";
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
  policies: {
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
  policyTypeCategoryId: {
    type: String,
    required: true,
  },
});
const uiStore = useUiStore();
const emit = defineEmits(["updatePolicies"]);
const serviceProviderId: Ref<string> = ref("");
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const isAssignPolicyDialogOpen: Ref<boolean> = ref(false);
const isRemovePolicyDialogOpen: Ref<boolean> = ref(false);
const dialogPoliciesDeleteData: Ref<PolicyTypeRead | null> = ref(null);
const allPolicies: Ref<PolicyRead[]> = ref([]);
const showAssignPolicyButton = computed(
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
  icon: sectionIcons["policyBased"],
  title: "Assign policy to user",
  description:
    "Assign a policy to this user so that the policy applies to them when accessing your products.",
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/ciam/provide-access-to-customers#manually-assign-access",
};
const handleAssignPolicyDialog = () => {
  isAssignPolicyDialogOpen.value = !isAssignPolicyDialogOpen.value;
};

const handleRemovePolicyDialog = (policy: PolicyTypeRead) => {
  isRemovePolicyDialogOpen.value = !isRemovePolicyDialogOpen.value;
  if (!policy) return;
  dialogPoliciesDeleteData.value = policy;
};

const handlePolicyUpdates = () => {
  emit("updatePolicies");
};

const handleUpdatePolicyParams = (params: TableRequestParams) => {
  emit("updatePolicies", params);
};

const handleGetPolicies = (policies: PolicyRead[]) => {
  allPolicies.value = policies;
};

const getDropdownItems = (row: PolicyRead) => [
  {
    label: "Remove policy",
    isDisabled: uiStore.isSPViewerOnly,
    type: "button",
    color: "error",
    onClick: () => handleRemovePolicyDialog(row),
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
  <m-m-expandable-card title="Policies">
    <div
      class="mm-page-subtitle mm-page-subtitle--h2 mm-mb-4 mm-ml-12"
      style="align-self: start"
    >
      Policies assigned to {{ user.user.first_name }}
      {{ user.user.last_name }} from account
      {{ customer?.organization?.name }}
    </div>
    <m-m-table
      :is-loading="isLoading"
      :headers="headers"
      :rows="policies?.results"
      :total-rows="policies?.total"
      show-search
      cy="users-policies-table"
      :empty-state="emptyState"
      @update-params="handleUpdatePolicyParams"
    >
      <template v-if="showAssignPolicyButton" #empty-state-button>
        <m-m-button
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          cy="add-policy-button"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="handleAssignPolicyDialog"
        >
          Assign policy
        </m-m-button>
      </template>
      <template #action>
        <m-m-button
          v-if="showAssignPolicyButton"
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          cy="add-policy-button"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="handleAssignPolicyDialog"
        >
          Assign policy
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
  <DialogAssignPolicy
    :category-id="policyTypeCategoryId"
    :is-open="isAssignPolicyDialogOpen"
    :data="policies"
    :organization-id="organizationId"
    :service-provider-id="serviceProviderId"
    :user="user"
    :assigned-policies="policies?.results"
    @get-policies="handleGetPolicies"
    @close-dialog="handleAssignPolicyDialog"
    @policies-updated="handlePolicyUpdates"
  />
  <DialogRemovePolicy
    :is-open="isRemovePolicyDialogOpen"
    :data="dialogPoliciesDeleteData"
    :organization-id="organizationId"
    :service-provider-id="serviceProviderId"
    :organization-name="customer?.organization?.name"
    :user="user"
    @close-dialog="handleRemovePolicyDialog"
    @policies-updated="handlePolicyUpdates"
  />
</template>

<style scoped lang="scss"></style>
