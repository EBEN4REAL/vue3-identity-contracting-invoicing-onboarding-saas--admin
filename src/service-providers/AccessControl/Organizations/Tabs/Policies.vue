<script setup lang="ts">
import { PropType, Ref, ref } from "vue";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import {
  PaginationSchema_PolicyRead_,
  PolicyRead,
} from "~/service-providers/Policies/policies.types";
import DialogAssignPolicy from "../Dialogs/DialogAssignPolicy.vue";
import DialogRemovePolicy from "../Dialogs/DialogRemovePolicy.vue";
const props = defineProps({
  user: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    required: true,
  },
  policies: {
    type: Object as PropType<PaginationSchema_PolicyRead_ | null>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  policyTypeCategoryId: {
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
const emit = defineEmits(["updatePolicies", "updateTableParams"]);

const isAssignPolicyDialogOpen: Ref<boolean> = ref(false);
const isRemovePolicyDialogOpen: Ref<boolean> = ref(false);
const dialogPoliciesDeleteData: Ref<PolicyRead | null> = ref(null);
const allPolicies: Ref<PolicyRead[]> = ref([]);

const handleAssignPolicyDialog = () => {
  isAssignPolicyDialogOpen.value = true;
};

const handleRemovePolicyDialog = (policy: PolicyRead) => {
  isRemovePolicyDialogOpen.value = true;
  dialogPoliciesDeleteData.value = policy;
};

const getDropdownItems = (row: PolicyRead) => [
  {
    label: "Remove policy",
    isDisabled: props.isSPViewerOnly,
    type: "button",
    color: "error",
    onClick: () => handleRemovePolicyDialog(row),
  },
];

const policyDescription = (row: PolicyRead) => row.description || "-";

const handlePolicies = (policies: PolicyRead[]) => {
  allPolicies.value = policies;
};
</script>
<template>
  <m-m-expandable-card title="Policies" cy="policies-expandable">
    <m-m-table
      background-color="#F2F4F7"
      :headers="headers"
      empty-state="No policies"
      show-search
      :is-loading="isLoading"
      :rows="policies?.results || []"
      :total-rows="policies?.total || 0"
      cy="customers-policies-table"
      @update-params="emit('updateTableParams', $event)"
    >
      <template #action>
        <m-m-button
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          data-cy="assign-policy-button"
          :is-disabled="isSPViewerOnly"
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
            policyDescription(row)
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
  <DialogAssignPolicy
    v-if="serviceProviderId && isAssignPolicyDialogOpen"
    :is-open="isAssignPolicyDialogOpen"
    :service-provider-id="serviceProviderId"
    :organization-id="user?.organization.id"
    :all-policies="policies"
    :policy-type-category-id="policyTypeCategoryId"
    @get-policies="handlePolicies"
    @close-dialog="isAssignPolicyDialogOpen = false"
    @update-policies="emit('updatePolicies')"
  />
  <DialogRemovePolicy
    v-if="serviceProviderId && isRemovePolicyDialogOpen"
    :service-provider-id="serviceProviderId"
    :is-open="isRemovePolicyDialogOpen"
    :user-id="user?.organization.id"
    :org-name="user?.organization.name"
    :policy="dialogPoliciesDeleteData"
    @close-dialog="isRemovePolicyDialogOpen = false"
    @update-policies="emit('updatePolicies')"
  />
</template>
<style scoped></style>
