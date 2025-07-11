<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { PaginationSchema_PolicyTypeRead_ } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  OrganizationUserRead,
  PaginationSchema_OrganizationRead_,
  ServiceProviderOrganizationUserRead,
} from "~/iam/iam.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { usePolicyUxCategoriesStore } from "~/stores/policyUxCategories";
import router from "~/router/index.router";
const props = defineProps({
  policyTypeId: {
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
  allPolicies: {
    type: Object as PaginationSchema_PolicyTypeRead_,
    default: () => {},
  },
  assignedPolicies: {
    type: Object as PaginationSchema_PolicyTypeRead_,
    default: () => {},
  },
  selectedEntityType: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["close", "update", "update-all-policies"]);
const policyUxCategoriesStore = usePolicyUxCategoriesStore();
const selectedPolicy: Ref<string[]> = ref([]);
const entitiesValue: Ref<string[]> = ref([]);
const users: Ref<ServiceProviderOrganizationUserRead | null> = ref(null);
const organizations: Ref<PaginationSchema_OrganizationRead_ | null> = ref(null);
const totalItems: Ref<number> = ref(0);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const isAutocompleteLoading: Ref<boolean> = ref(false);
const isSubmitButtonDisabled: ComputedRef<boolean> = computed(
  () =>
    isSubmitButtonLoading.value ||
    entitiesValue.value?.length == 0 ||
    selectedPolicy.value.length == 0 ||
    computedPolicies.value?.find((role) => role.id == selectedPolicy.value)
      ?.disabled,
);
const defaultPagination = { limit: ITEMS_PER_PAGE[0], offset: "0" };

const userName = (userObject: OrganizationUserRead) =>
  userObject.first_name?.length > 0 && userObject.last_name?.length > 0
    ? userObject?.first_name + " " + userObject?.last_name
    : userObject.email;

const computedPolicies: ComputedRef<PolicyTypeRead[]> = computed(() => {
  if (!props.allPolicies?.results || !entitiesValue.value?.length) {
    return [];
  }

  const filterAssignedPolicies = (assignedPolicy: PolicyTypeRead): boolean => {
    switch (props.selectedEntityType) {
      case "organization":
        return entitiesValue.value?.includes(assignedPolicy.organization_id);
      case "user":
        return entitiesValue.value?.includes(assignedPolicy.assigned_id);
      default:
        return false;
    }
  };

  const assignedPoliciesByEntity = props.assignedPolicies?.results.filter(
    filterAssignedPolicies,
  );

  return props.allPolicies.results.map((policyType) => {
    const isAlreadyAdded =
      assignedPoliciesByEntity?.some(
        (assignedPolicy: PolicyTypeRead) =>
          policyType.id === assignedPolicy.type_id &&
          assignedPolicy.policy_assignment === computedSelectedEntityType.value,
      ) ?? false;

    let disabledText = "";
    if (isAlreadyAdded) {
      disabledText = "Already added";
    } else if (!policyType.published) {
      disabledText = "Not yet published";
    }

    return {
      ...policyType,
      disabled: isAlreadyAdded || !policyType.published,
      disabledText,
    };
  });
});

const formattedUsers: ComputedRef<ServiceProviderOrganizationUserRead[]> =
  computed(() =>
    (users.value?.results ?? []).map((userObject) => ({
      id: userObject.organization_user?.id,
      name: `${userName(userObject.user)} (${userObject.organization.name})`,
    })),
  );

const computedSelectedEntityType: ComputedRef<string> = computed(
  () =>
    ({ user: "ORGANIZATION_USER", organization: "ORGANIZATION" })[
      props.selectedEntityType
    ],
);
const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];
const submitAssignToUsers = async () => {
  try {
    await Promise.all(
      entitiesValue.value.map((userId) => {
        const orgId = users.value?.results.find(
          (user) => user.organization_user.id === userId,
        )?.organization.id;
        return policiesService.assignPolicy(props.serviceProviderId, {
          policy_type_id: selectedPolicy.value,
          organization_user_id: userId,
          organization_id: orgId,
        });
      }),
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
          policy_type_id: selectedPolicy.value,
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
        params || defaultPagination,
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

const fetchEntities = async (params?: TableRequestParams) => {
  if (props.selectedEntityType == "user") await getUsers(params);
  else await getOrganizations(params);
};
const handleUpdateAllPolicies = (params?: TableRequestParams) => {
  emit("update-all-policies", params);
};
onMounted(async () => {
  await fetchEntities();
});

const roleUxCategory = computed(() =>
  policyUxCategoriesStore.policyUxCategories.find(
    (category) => category.name === "Policy",
  ),
);

const goToCreateRole = computed(() => {
  policyUxCategoriesStore.setActiveCategory(roleUxCategory?.value?.id || "");
  return router.resolve({
    name: "NewPolicyType",
    params: {
      service_provider_id: props.serviceProviderId,
    },
  }).href;
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Assign Policies"
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
          :items="formattedUsers"
          :total-items="users?.results?.length"
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
          :items="
            organizations?.results.map((orgObject) => ({
              ...orgObject.organization,
            }))
          "
          :total-items="organizations?.results?.length"
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
        <m-m-autocomplete
          id="autocomplete-multiple"
          v-model="selectedPolicy"
          class="mm-mt-14"
          placeholder="Search policy"
          label="Search & assign policies"
          cy="select-policies"
          icon-prepended="search-lg"
          clear-button="x-circle"
          :items="computedPolicies"
          :total-items="totalItems"
          item-title="name"
          item-value="id"
          @update-params="handleUpdateAllPolicies"
        >
          <template #option="{ item }">
            <div class="mm-flex mm-flex-justify-between mm-w-10">
              <div :class="selectPolicyOptionClassList(item.disabled)">
                {{ item.external_facing_name }}
                <div
                  v-if="item.disabled"
                  class="mm-flex mm-flex-justify-between mm-flex-grow"
                >
                  <m-m-badge
                    class="mm-ml-3"
                    :status="BadgeTypes.Inactive"
                    :text="item.disabledText"
                    cy="badge-added"
                  />
                  <m-m-icon icon="check-thin-primary" width="12px" />
                </div>
              </div>
            </div>
          </template>
        </m-m-autocomplete>
        <m-m-link
          class="mm-flex mm-flex-gap-4 mm-flex-justify-start mm-mt-3"
          target="_blank"
          :href="goToCreateRole"
          >Or click here to create a new policy
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
