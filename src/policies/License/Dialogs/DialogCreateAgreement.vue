<script lang="ts" setup>
import { Ref, ref, computed, onMounted, ComputedRef } from "vue";
import {
  OrganizationRead,
  ServiceProviderOrganizationRead,
} from "~/iam/iam.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { policiesService } from "~/service-providers/policies.service";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { useRoute } from "vue-router";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  isAccessLicense: {
    type: Boolean,
    default: false,
  },
  licenseName: {
    type: String,
    default: "",
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
});

const emit = defineEmits([
  "closeDialog",
  "updateList",
  "update-selected-customer",
]);

const onDialogClose = () => {
  resetForm();
  emit("closeDialog");
};

const route = useRoute();
const entitiesValue: Ref<string[]> = ref([]);
const customers: Ref<ServiceProviderOrganizationRead[]> = ref([]);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const isSaving: Ref<boolean> = ref(false);
const totalCustomers: Ref<number> = ref(0);
const isLoading: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const activeAgreementNamesByCustomer = ref(new Map<string, Set<string>>());
const assignedOrgs: Ref<OrganizationRead[] | null> = ref(null);

const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const combinedOrganizations = computed(() => {
  const assignedIds = new Set(
    assignedOrgs.value?.map((org) => org.organization_id),
  );
  const availableOrganizations = customers.value?.map((org) => ({
    id: org.organization.id,
    name: org.organization.name,
    disabled: assignedIds.has(org.organization.id),
    disabledText: assignedIds.has(org.organization.id) ? "Already added" : "",
  }));
  return availableOrganizations;
});

const isSubmitButtonDisabled: ComputedRef<boolean> = computed(
  () => isSubmitButtonLoading.value || entitiesValue.value.length === 0,
);

const dialogConfig = computed(() => {
  return {
    title: props.isAccessLicense
      ? `Allocate license ${props.licenseName}`
      : "New subscription",
    icon: props.isAccessLicense ? "ticket-outline" : "arrow-rounded-outline",
  };
});

const customersForAutocomplete = computed(() =>
  customers.value?.map((customer) => customer.organization),
);

const getCustomers = async (params: TableRequestParams) => {
  isLoading.value = true;
  const customersRes =
    await serviceProvidersService.getServiceProviderOrganizations(
      props.serviceProviderId,
      params,
    );

  isLoading.value = false;

  customers.value = customersRes?.results || [];
  totalCustomers.value = customersRes?.total || 0;
};

const submitForm = async () => {
  try {
    isSubmitButtonLoading.value = true;
    isSaving.value = true;
    await Promise.all(
      entitiesValue.value.map(async (customerId) => {
        const response = await policiesService.assignAgreement(
          props.serviceProviderId,
          route.params.license_id as string,
          customerId,
          {
            active: true,
            effective_from_date: new Date().toISOString(),
          },
        );
        if (props.isAccessLicense) {
          eventBus.$emit("onShowToast", {
            text: "Successfully allocated license",
            status: "info",
          });
        } else {
          const selectedCustomer = customersForAutocomplete.value.find(
            (customer) => customer.id == customerId,
          );
          const status = response.active ? "ACTIVE" : "PENDING";
          emit("update-selected-customer", {
            customer: selectedCustomer,
            status,
          });
        }
        if (!activeAgreementNamesByCustomer.value.has(customerId)) {
          activeAgreementNamesByCustomer.value.set(customerId, new Set());
        }
        activeAgreementNamesByCustomer.value
          .get(customerId)
          ?.add(props.licenseName);
      }),
    );
    emit("updateList");
    isSaving.value = false;
    onDialogClose();
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = "Err";
    isSaving.value = false;
    isSubmitButtonLoading.value = false;
  }
};

const getOrgsAssignedToAgreements = async () => {
  try {
    if (!props.serviceProviderId || !route.params.license_id) {
      return;
    }
    assignedOrgs.value =
      await policiesService.getOrganizationsAssignedToAgreement(
        props.serviceProviderId,
        route.params.license_id as string,
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching organizations assigned to agreement",
      status: "error",
    });
  }
};

const resetForm = () => {
  entitiesValue.value = [];
  isSubmitButtonLoading.value = false;
};

onMounted(async () => {
  await getOrgsAssignedToAgreements();
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="dialogConfig.title"
    :icon="dialogConfig.icon"
    icon-size="24px"
    cy="dialog-allocate-agreement"
    @close="onDialogClose"
  >
    <template #default>
      <form v-mm-focus-first>
        <m-m-autocomplete
          id="customer"
          v-model="entitiesValue"
          required
          placeholder="Search account"
          label="Customer account"
          :items="combinedOrganizations"
          :total-items="customers.total"
          item-title="name"
          item-value="id"
          cy="customer-search"
          icon-prepended="search-lg"
          clear-button="x-circle"
          :loading="isLoading"
          multiple
          @update-params="getCustomers"
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
          class="mm-flex mm-flex-gap-4 mm-flex-justify-start mm-mt-3 allocate-link"
          target="_blank"
          href="/sp/accounts?openModal=true"
          >Or click here to create a new account
          <m-m-icon class="mm-mt-2" icon="arrow-top-right-on-square" />
        </m-m-link>
      </form>
    </template>
    <template #footer>
      <m-m-button
        variant="outlined"
        min-width="100px"
        cy="button-cancel"
        @click="onDialogClose"
        >Cancel</m-m-button
      >
      <m-m-button
        cy="button-submit"
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        @click="submitForm"
      >
        Confirm
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss">
:deep(.mm-dialog-body-header-content) {
  svg {
    stroke: currentColor !important;
  }
}
.allocate-link {
  width: fit-content;
}
</style>
