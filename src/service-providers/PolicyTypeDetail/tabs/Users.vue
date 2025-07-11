<script lang="ts" setup>
import { computed, ComputedRef, ref, Ref } from "vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { ServiceProviderOrganizationUserRead } from "~/iam/iam.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { policiesService } from "~/service-providers/policies.service";
import { AllPolicyRead } from "~/service-providers/Policies/policies.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
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
  activeCategoryName: {
    type: String,
    default: "",
  },
  policyName: {
    type: String,
    default: "",
  },
  isPolicyPublished: {
    type: Boolean,
    default: false,
  },
});

const uiStore = useUiStore();

const isLoading = ref(false);
const assignDialogOpen = ref(false);
const policiesAssigned: Ref<TableResponse<AllPolicyRead> | null> = ref(null);
const users: Ref<ServiceProviderOrganizationUserRead[] | null> = ref(null);
const tableHeaders: TableHeader[] = [
  {
    key: "assigned_id",
    label: "User",
  },
  {
    key: "organization_id",
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

const dropdownItems = (row: AllPolicyRead): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "link",
    to: goToUserDetails(row),
  },
];

const getPolicies = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    const requestParams = {
      policy_assignment: "ORGANIZATION_USER",
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
    const response = policiesAssigned.value?.results
      ? await Promise.all(
          policiesAssigned.value.results.map(async (policy) => {
            const response =
              await serviceProvidersService.getServiceProviderUsers(
                props.serviceProviderId as string,
                { organization_user_id: policy.assigned_id },
              );
            return response?.results;
          }),
        )
      : [];
    users.value = response.flat();
  } finally {
    isLoading.value = false;
  }
};

const findUser = (user_id: string) => {
  return users.value?.find((user) => user.organization_user?.id === user_id);
};

const getOrganizationName = (user_id: string): string => {
  const user = findUser(user_id);
  return user ? user.organization.name : "-";
};

const getUserFullName = (user_id: string): string => {
  const user = findUser(user_id);
  return user
    ? user.user.first_name
      ? `${user.user.first_name} ${user.user.last_name}`
      : user.user.email
    : "-";
};

const goToUserDetails = (user_id: string) => {
  const user = findUser(user_id);
  return `/sp/users/${user?.organization?.id}/user_details/${user?.id}`;
};
</script>
<template>
  <div class="mm-flex mm-flex-justify-end mm-mb-10">
    <m-m-button
      variant="outlined"
      size="small"
      prepend-icon="plus"
      cy="button-assign-item"
      :is-disabled="isButtonAssignPolicyDisabled"
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
    empty-state="No users"
    cy="table-policies-assigned-users"
    @update-params="getPolicies"
  >
    <template #empty-state-button>
      <m-m-button
        variant="elevated"
        size="small"
        prepend-icon="plus-white"
        cy="empty-state-button-assign-policy"
        :is-disabled="isButtonAssignPolicyDisabled"
        @click="assignDialogOpen = true"
      >
        Assign {{ props.activeCategoryName === "Role" ? "role" : "policy" }}
        <m-m-tooltip v-if="!isPolicyPublished" display-position="center"
          >You cannot assign this item as it needs to be published
          first</m-m-tooltip
        >
      </m-m-button>
    </template>
    <template #assigned_id="{ row }">
      <m-m-link
        :to="goToUserDetails(row.assigned_id)"
        font-weigth="500"
        :cy="`name-${row?.assigned_id}`"
      >
        {{ getUserFullName(row.assigned_id) }}
      </m-m-link>
    </template>
    <template #organization_id="{ row }">
      {{ getOrganizationName(row.assigned_id) }}
    </template>
    <template #assigned_on="{ row }">
      <m-m-formatted-date :raw-date="row.assigned_on" />
    </template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown list-side="left" :items="dropdownItems(row.assigned_id)">
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
    selected-entity-type="user"
    @update="getPolicies"
    @close="assignDialogOpen = false"
  />
</template>
