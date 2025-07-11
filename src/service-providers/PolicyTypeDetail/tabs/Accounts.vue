<script lang="ts" setup>
import { computed, ComputedRef, ref, Ref } from "vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { policiesService } from "~/service-providers/policies.service";
import { AllPolicyRead } from "~/service-providers/Policies/policies.types";
import DialogAssignPolicies from "../dialogs/DialogAssignPolicies.vue";
import { useUiStore } from "~/stores/useUiStore";

const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  policyId: {
    type: String,
    default: "",
  },
  policyName: {
    type: String,
    default: "",
  },
  activeCategoryName: {
    type: String,
    default: "",
  },
  isPolicyPublished: {
    type: Boolean,
    default: false,
  },
});

const uiStore = useUiStore();

const emptyState: string = "No accounts";
const assignDialogOpen = ref(false);
const isLoading = ref(false);
const policiesAssigned: Ref<TableResponse<AllPolicyRead> | null> = ref(null);
const tableHeaders: TableHeader[] = [
  {
    key: "assigned_organization_name",
    label: "Account",
  },
  {
    key: "assigned_on",
    label: "Assigned on",
    sortable: true,
    sortIcon: true,
    order: "desc",
    defaultSortItem: true,
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const isButtonAssignPolicyDisabled: ComputedRef<boolean> = computed(
  () => !props.isPolicyPublished || uiStore.isSPViewerOnly,
);

const getPolicies = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    const requestParams = {
      policy_assignment: "ORGANIZATION",
      policy_type_ids: props.policyId,
      ...(params || {
        limit: ITEMS_PER_PAGE[0],
        offset: "0",
      }),
    };
    policiesAssigned.value = await policiesService.getAllExternalPolicies(
      props.serviceProviderId as string,
      requestParams,
    );
  } finally {
    isLoading.value = false;
  }
};
</script>
<template>
  <div class="mm-flex mm-flex-justify-end mm-mb-10">
    <m-m-button
      variant="outlined"
      size="small"
      prepend-icon="plus"
      cy="button-assign-item"
      :disabled="isButtonAssignPolicyDisabled"
      @click="assignDialogOpen = true"
    >
      Assign {{ activeCategoryName === "Role" ? "role" : "policy" }}
      <m-m-tooltip v-if="!isPolicyPublished" display-position="toLeft"
        >You cannot assign this item as it needs to be published
        first</m-m-tooltip
      >
    </m-m-button>
  </div>
  <m-m-table
    :is-loading="isLoading"
    :headers="tableHeaders"
    :rows="policiesAssigned?.results"
    :total-rows="policiesAssigned?.total"
    :empty-state="emptyState"
    cy="table-policies-assigned-accounts"
    @update-params="getPolicies"
  >
    <template #empty-state-button>
      <m-m-button
        variant="elevated"
        size="small"
        prepend-icon="plus-white"
        cy="empty-state-button-assign-item"
        :disabled="isButtonAssignPolicyDisabled"
        @click="assignDialogOpen = true"
      >
        Assign {{ activeCategoryName === "Role" ? "role" : "policy" }}
        <m-m-tooltip v-if="!isPolicyPublished" display-position="center"
          >You cannot assign this item as it needs to be published
          first</m-m-tooltip
        >
      </m-m-button>
    </template>
    <template #assigned_organization_name="{ row }">
      <m-m-link
        :to="`/sp/accounts/${row.organization_id}`"
        font-weigth="500"
        :cy="`name-${row?.id}`"
      >
        {{ row.assigned_organization_name }}
      </m-m-link>
    </template>
    <template #assigned_on="{ row }">
      <m-m-formatted-date :raw-date="row.assigned_on" />
    </template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown
          list-side="left"
          :items="[
            {
              label: 'View details',
              type: 'link',
              to: `/sp/accounts/${row.organization_id}`,
            },
          ]"
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
  <dialog-assign-policies
    v-if="assignDialogOpen"
    :policy-type-id="props.policyId"
    :policy-name="props.policyName"
    :service-provider-id="serviceProviderId"
    :is-open="assignDialogOpen"
    selected-entity-type="organization"
    @update="getPolicies"
    @close="assignDialogOpen = false"
  />
</template>
