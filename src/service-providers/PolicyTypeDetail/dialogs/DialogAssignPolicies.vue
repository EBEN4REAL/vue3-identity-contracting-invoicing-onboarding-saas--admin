<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { policiesService } from "~/service-providers/policies.service";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  OrganizationRead,
  OrganizationUserRead,
  ServiceProviderOrganizationRead,
  ServiceProviderOrganizationUserRead,
} from "~/iam/iam.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { OrganizationUserPolicyAssignmentUserIDRead } from "~/policies/policies.types";

const props = defineProps({
  policyTypeId: {
    type: String,
    default: "",
  },
  policyName: {
    type: String,
    default: "",
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  selectedEntityType: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["close", "update"]);
const entitiesValue: Ref<string[]> = ref([]);
const users: Ref<TableResponse<ServiceProviderOrganizationUserRead> | null> =
  ref(null);
const organizations: Ref<TableResponse<ServiceProviderOrganizationRead> | null> =
  ref(null);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const isAutocompleteLoading: Ref<boolean> = ref(false);
const isSubmitButtonDisabled: ComputedRef<boolean> = computed(
  () => isSubmitButtonLoading.value || entitiesValue.value?.length == 0,
);
const defaultPagination = { limit: ITEMS_PER_PAGE[0], offset: "0" };
const assignedOrgs: Ref<OrganizationRead[] | null> = ref(null);
const assignedOrgUsers: Ref<OrganizationUserPolicyAssignmentUserIDRead[]> = ref(
  [],
);

const userName = (userObject: OrganizationUserRead) =>
  (userObject.first_name?.length ?? 0) > 0 &&
  (userObject.last_name?.length ?? 0) > 0
    ? userObject?.first_name + " " + userObject?.last_name
    : userObject.email;

const combinedOrganizations = computed(() => {
  const assignedIds = new Set(
    assignedOrgs.value?.map((org) => org.organization_id),
  );
  const availableOrganizations = organizations.value?.results.map((org) => ({
    id: org.organization.id,
    name: org.organization.name,
    disabled: assignedIds.has(org.organization.id),
    disabledText: assignedIds.has(org.organization.id) ? "Already added" : "",
  }));
  return availableOrganizations;
});

const combinedUsers = computed(() => {
  const assignedUserIds = new Set(
    assignedOrgUsers.value.map((user) => user.organization_user_id),
  );
  const availableUsers = users.value?.results?.map((user) => ({
    id: user.organization_user?.id,
    name: `${userName(user.user)} (${user.organization.name})`,
    disabled: assignedUserIds.has(user.organization_user?.id),
    disabledText: assignedUserIds.has(user.organization_user?.id)
      ? "Already added"
      : "",
  }));
  return availableUsers;
});

const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const submitAssignToUsers = async () => {
  try {
    await Promise.all(
      entitiesValue.value.map((userId) =>
        policiesService.assignPolicy(props.serviceProviderId, {
          policy_type_id: props.policyTypeId,
          organization_user_id: userId,
          organization_id: props.serviceProviderId,
        }),
      ),
    );
    emit("update");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Policy already assigned to ${props.selectedEntityType}`,
      status: "error",
    });
  }
};

const submitAssignToOrganizations = async () => {
  try {
    await Promise.all(
      entitiesValue.value.map((organizationId) =>
        policiesService.assignPolicyToOrganization(props.serviceProviderId, {
          policy_type_id: props.policyTypeId,
          organization_id: organizationId,
        }),
      ),
    );
    emit("update");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Policy already assigned to ${props.selectedEntityType}`,
      status: "error",
    });
  }
};

const onSubmit = async () => {
  isSubmitButtonLoading.value = true;
  try {
    if (props.selectedEntityType === "user") {
      await submitAssignToUsers();
    } else {
      await submitAssignToOrganizations();
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error assigning policy",
      status: "error",
    });
  } finally {
    isSubmitButtonLoading.value = false;
  }
};
const getUsers = async (params?: TableRequestParams) => {
  try {
    isAutocompleteLoading.value = true;
    users.value = await serviceProvidersService.getServiceProviderUsers(
      props.serviceProviderId,
      params || defaultPagination,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching users",
      status: "error",
    });
  } finally {
    isAutocompleteLoading.value = false;
  }
};

const getOrganizations = async (params?: TableRequestParams) => {
  try {
    isAutocompleteLoading.value = true;
    organizations.value =
      await serviceProvidersService.getServiceProviderOrganizations(
        props.serviceProviderId,
        params ? params : { limit: ITEMS_PER_PAGE[0], offset: "0" },
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error while fetching organizations",
      status: "error",
    });
  } finally {
    isAutocompleteLoading.value = false;
  }
};

const getOrgsAssignedToPolicies = async () => {
  try {
    assignedOrgs.value = await policiesService.getOrganizationsAssignedToPolicy(
      props.serviceProviderId,
      props.policyTypeId,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching organizations assigned to policies",
      status: "error",
    });
  }
};

const getOrgUsersAssignedToPolicies = async () => {
  try {
    assignedOrgUsers.value =
      await policiesService.getOrganizationUsersAssignedToPolicy(
        props.serviceProviderId,
        props.policyTypeId,
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching organizations assigned to policies",
      status: "error",
    });
  }
};

onMounted(async () => {
  if (props.selectedEntityType === "user") {
    await getOrgUsersAssignedToPolicies();
  } else {
    await getOrgsAssignedToPolicies();
  }
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Assign ${props.policyName}`"
    icon="shield-check-light"
    cy="dialog-assign-policies"
    @close="emit('close')"
  >
    <template #default>
      <div class="autocompletes-group">
        <m-m-autocomplete
          v-if="props.selectedEntityType === 'user'"
          id="autocomplete-users"
          v-model="entitiesValue"
          :loading="isAutocompleteLoading"
          :placeholder="'Search users'"
          :label="'Select user(s)'"
          cy="select-users"
          icon-prepended="search-lg"
          clear-button="x-circle"
          :items="combinedUsers"
          :total-items="users?.total"
          item-title="name"
          item-value="id"
          multiple
          @update-params="getUsers"
        >
          <template #option="{ item }">
            <div class="mm-flex mm-flex-justify-between mm-w-10">
              <div :class="selectPolicyOptionClassList(item.disabled)">
                {{ item.name }}
                <div
                  v-if="item.disabled"
                  class="mm-flex mm-flex-justify-between mm-flex-grow"
                >
                  <m-m-badge
                    class="mm-ml-3"
                    :status="BadgeTypes.Inactive"
                    text="Already added"
                    cy="badge-added"
                  />
                  <m-m-icon icon="check-thin-primary" width="12px" />
                </div>
              </div>
            </div>
          </template>
        </m-m-autocomplete>

        <m-m-autocomplete
          v-if="props.selectedEntityType === 'organization'"
          id="autocomplete-organizations"
          v-model="entitiesValue"
          :loading="isAutocompleteLoading"
          :placeholder="'Search accounts'"
          :label="'Select account(s)'"
          cy="select-organizations"
          icon-prepended="search-lg"
          clear-button="x-circle"
          :items="combinedOrganizations"
          :total-items="organizations?.total"
          item-title="name"
          item-value="id"
          multiple
          @update-params="getOrganizations"
        >
          <template #option="{ item }">
            <div class="mm-flex mm-flex-justify-between mm-w-10">
              <div :class="selectPolicyOptionClassList(item.disabled)">
                {{ item.name }}
                <div
                  v-if="item.disabled"
                  class="mm-flex mm-flex-justify-between mm-flex-grow"
                >
                  <m-m-badge
                    class="mm-ml-3"
                    :status="BadgeTypes.Inactive"
                    text="Already added"
                    cy="badge-added"
                  />
                  <m-m-icon icon="check-thin-primary" width="12px" />
                </div>
              </div>
            </div>
          </template>
        </m-m-autocomplete>
        <m-m-link
          v-if="props.selectedEntityType === 'organization'"
          class="mm-flex mm-flex-gap-4 mm-flex-justify-start mm-mt-3"
          target="_blank"
          href="/sp/accounts?openModal=true"
          >Or click here to create a new account
          <m-m-icon class="mm-mt-2" icon="arrow-top-right-on-square" />
        </m-m-link>
      </div>
    </template>
    <template #footer>
      <m-m-button
        variant="outlined"
        min-width="100px"
        cy="button-cancel"
        @click="emit('close')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        cy="button-submit"
        @click="onSubmit"
      >
        Yes, Assign
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss">
.autocompletes-group {
  display: flex;
  flex-direction: column;
}
</style>
