<script setup lang="ts">
import { PropType, Ref, ref } from "vue";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { RoleRead } from "~/service-providers/Roles/roles.type";
import DialogAssignRole from "../Dialogs/DialogAssignRole.vue";
import DialogRemoveRole from "../Dialogs/DialogRemoveRole.vue";

const props = defineProps({
  user: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    required: true,
  },
  roles: {
    type: Array as PropType<RoleRead[] | null>,
    required: true,
    default: () => [],
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  rolesCategoryId: {
    type: String,
    required: true,
  },
  isSPViewerOnly: {
    type: Boolean,
    default: false,
  },
});

const headers = [
  {
    key: "name",
    label: "Role name",
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
const emit = defineEmits(["updateRoles", "updateTableParams"]);

const isAssignRoleDialogOpen: Ref<boolean> = ref(false);
const isRemoveRoleDialogOpen: Ref<boolean> = ref(false);
const dialogRolesDeleteData: Ref<RoleRead | null> = ref(null);

const handleAssignRoleDialog = () => {
  isAssignRoleDialogOpen.value = true;
};

const handleRemoveRoleDialog = (role: RoleRead) => {
  isRemoveRoleDialogOpen.value = true;
  dialogRolesDeleteData.value = role;
};

const getDropdownItems = (row: RoleRead) => [
  {
    label: "Remove role",
    type: "button",
    isDisabled: props.isSPViewerOnly,
    color: "error",
    onClick: () => handleRemoveRoleDialog(row),
  },
];

const roleDescription = (row: RoleRead) => row.description || "-";
</script>
<template>
  <m-m-expandable-card title="Roles" cy="roles-expandable">
    <m-m-table
      background-color="#F2F4F7"
      :headers="headers"
      empty-state="No roles"
      show-search
      :is-loading="isLoading"
      :rows="roles?.results || []"
      :total-rows="roles?.total || 0"
      cy="customers-roles-table"
      @update-params="emit('updateTableParams', $event)"
    >
      <template #action>
        <m-m-button
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          data-cy="assign-role-button"
          :is-disabled="isSPViewerOnly"
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
            roleDescription(row)
          }}</span>
        </div>
      </template>
      <template #actions="{ row }">
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
    v-if="serviceProviderId && isAssignRoleDialogOpen"
    :is-open="isAssignRoleDialogOpen"
    :service-provider-id="serviceProviderId"
    :assigned-roles="roles?.results"
    :customer="user.organization"
    :category-id="rolesCategoryId"
    @close-dialog="isAssignRoleDialogOpen = false"
    @update-roles="emit('updateRoles')"
  />
  <DialogRemoveRole
    v-if="serviceProviderId && isRemoveRoleDialogOpen"
    :service-provider-id="serviceProviderId"
    :is-open="isRemoveRoleDialogOpen"
    :account="user"
    :role="dialogRolesDeleteData"
    :policy-type-id="dialogRolesDeleteData?.type_id"
    @close-dialog="isRemoveRoleDialogOpen = false"
    @update-roles="emit('updateRoles')"
  />
</template>
<style scoped></style>
