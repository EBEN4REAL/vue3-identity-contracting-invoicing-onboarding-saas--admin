<script lang="ts" setup>
import useVuelidate from "@vuelidate/core";
import { helpers, required } from "@vuelidate/validators";
import { Ref, ref, computed, reactive, onMounted, watch } from "vue";
import { authService } from "~/auth/auth.service";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  TableResponse,
  TableRequestParams,
} from "~/mm_ui_kit/src/types/table.types";
import { policiesService } from "~/service-providers/policies.service";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  AgreementTypeRead,
  SPAgreementRead,
  TypeAllocateLicenseForm,
  TypeAllocateLicenseFormRules,
  TypeValidatorAllocateLicenseForm,
} from "../licenses.types";
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

const serviceProviderId: Ref<string> = ref("");
const customers: Ref<ServiceProviderOrganizationRead[]> = ref([]);
const agreements: Ref<AgreementTypeRead[]> = ref([]);
const activeAgreements: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const isSaving: Ref<boolean> = ref(false);
const totalCustomers: Ref<number> = ref(0);
const totalAgreements: Ref<number> = ref(0);
const currentParams: Ref<TableRequestParams | null> = ref(null);
const isLoading: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const activeAgreementNamesByCustomer = ref(new Map<string, Set<string>>());
const formattedAgreements = ref([]);

const dialogConfig = computed(() => {
  return {
    title: props.isAccessLicense ? "Allocate license" : "New subscription",
    icon: props.isAccessLicense ? "ticket-outline" : "arrow-rounded-outline",
  };
});

const handleLink = computed(() => {
  return props.isAccessLicense
    ? `/sp/${serviceProviderId.value}/licenses/new`
    : `/sp/${serviceProviderId.value}/plans/new`;
});

const agreementTypeLabel = computed(() => {
  return props.isAccessLicense ? "license" : "plan";
});

const form = reactive<TypeAllocateLicenseForm>({
  customer: "",
  license: "",
});

const formRules: TypeAllocateLicenseFormRules = {
  customer: {
    required: helpers.withMessage("Customer account is required", required),
  },
  license: {
    required: helpers.withMessage(
      `${!props.isAccessLicense ? "Plan" : "License"} is required`,
      required,
    ),
  },
};

const v$: TypeValidatorAllocateLicenseForm = useVuelidate(formRules, form);

const customersForAutocomplete = computed(() =>
  customers.value?.map((customer) => customer.organization),
);

const getCustomers = async (params: TableRequestParams) => {
  isLoading.value = true;
  const customersRes =
    await serviceProvidersService.getServiceProviderOrganizations(
      serviceProviderId.value,
      params,
    );

  isLoading.value = false;

  customers.value = customersRes?.results || [];
  totalCustomers.value = customersRes?.total || 0;
};

const category = computed(() =>
  !props.isAccessLicense ? "SUBSCRIPTION" : "ACCESS",
);

const getAgreementTypes = async (params: TableRequestParams) => {
  isLoading.value = true;
  currentParams.value = params;
  const agreementRes = await policiesService.getAgreementTypes(
    serviceProviderId.value,
    {
      ...params,
      category: category.value,
    },
  );

  isLoading.value = false;

  agreementRes?.results.forEach((agreement) => {
    if (!agreement.default_policies?.length) {
      agreement.disabled = true;
      agreement.hasNoDefaultPolicies = true;
    }
  });

  agreements.value = agreementRes?.results || [];
  totalAgreements.value = agreementRes?.total || 0;
  await getActiveLicenses();
};

const submitForm = async () => {
  const validationResult = await v$.value.$validate();
  isSubmitButtonLoading.value = true;
  if (!validationResult) {
    return;
  }
  try {
    isSaving.value = true;
    const response = await policiesService.assignAgreement(
      serviceProviderId.value,
      form.license,
      form.customer,
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
        (customer) => customer.id == form.customer,
      );
      const status = response.active ? "ACTIVE" : "PENDING";
      emit("update-selected-customer", {
        customer: selectedCustomer,
        status,
      });
    }
    emit("updateList");
    if (!activeAgreementNamesByCustomer.value.has(form.customer)) {
      activeAgreementNamesByCustomer.value.set(form.customer, new Set());
    }
    activeAgreementNamesByCustomer.value.get(form.customer)?.add(form.license);
    isSaving.value = false;
    onDialogClose();
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = "Err";
    isSaving.value = false;
    isSubmitButtonLoading.value = false;
  }
};

const resetForm = () => {
  form.customer = "";
  form.license = "";
  v$.value.$reset();
  isSubmitButtonLoading.value = false;
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
});

const getActiveLicenses = async () => {
  if (form.customer) {
    activeAgreements.value = await policiesService.getActiveLicenses(
      serviceProviderId.value,
      form.customer,
      {
        category: category.value,
        agreement_type_ids: agreements.value.map((item) => item.id),
      },
    );
    const activeLicenses = activeAgreements.value?.results || [];
    const activeAgreementNames = new Set(
      activeLicenses.map((item) => item.agreement_name),
    );
    activeAgreementNamesByCustomer.value.set(
      form.customer,
      activeAgreementNames,
    );

    formattedAgreements.value = agreements.value.map((license) => {
      if (activeAgreementNames.has(license.external_facing_name)) {
        return { ...license, disabled: true, alreadyAdded: true };
      }
      return { ...license, alreadyAdded: false };
    });
  }
};

const selectLicenseOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];
watch(
  () => form.customer,
  async (newValue, oldValue) => {
    if (newValue !== oldValue) {
      v$.value.license.$reset();
    }
    await getActiveLicenses();
    form.license = "";
  },
);
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
          v-model="form.customer"
          required
          placeholder="Search account"
          label="Customer account"
          :items="customersForAutocomplete"
          :total-items="totalCustomers"
          item-title="name"
          item-value="id"
          cy="customer-search"
          icon-prepended="search-lg"
          clear-button="x-circle"
          :errors="v$.customer.$errors"
          :loading="isLoading"
          @update-params="getCustomers"
        >
          <template #option="{ item }">
            <div
              class="mm-flex mm-flex-justify-between mm-flex-align-center mm-w-10"
            >
              <div class="option-overflow">
                <div
                  class="mm-page-option mm-flex mm-flex-align-center mm-flex-gap-3"
                >
                  <span class="option-truncate">{{ item.name }}</span>
                  <m-m-badge
                    v-if="form.customer.includes(item.id)"
                    text="Added"
                    cy="badge-added"
                  />
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
        <div class="mm-mt-12">
          <m-m-autocomplete
            v-if="form.customer"
            id="autocomplete-multiple"
            v-model="form.license"
            :data-select-value="form.license"
            :placeholder="`Search ${agreementTypeLabel}`"
            :label="`Select ${agreementTypeLabel}`"
            data-cy="select-license"
            icon-prepended="search-lg"
            clear-button="x-circle"
            :items="formattedAgreements"
            :total-items="totalAgreements"
            item-title="external_facing_name"
            item-value="id"
            required
            :errors="v$.license.$errors"
            :loading="isLoading"
            @update-params="getAgreementTypes"
          >
            <template #option="{ item }">
              <div :class="selectLicenseOptionClassList(item.disabled)">
                {{ item.external_facing_name }}
                <div
                  v-if="item.disabled"
                  class="mm-flex mm-flex-justify-between mm-flex-grow"
                >
                  <m-m-badge
                    class="mm-ml-3"
                    :status="BadgeTypes.Inactive"
                    :text="`${item.hasNoDefaultPolicies ? 'Disabled' : 'Already added'}`"
                    cy="badge-added"
                  />
                  <m-m-icon
                    v-if="!item.hasNoDefaultPolicies"
                    icon="check-thin-primary"
                    width="12px"
                  />
                </div>
                <m-m-tooltip v-if="item.hasNoDefaultPolicies">
                  Can't allocate this
                  {{ agreementTypeLabel }}
                  because there are no default policies attached. Attach a
                  default policy first and then you can assign it.
                </m-m-tooltip>
              </div>
            </template>
          </m-m-autocomplete>
          <m-m-link
            v-if="form.customer"
            class="mm-flex mm-flex-gap-4 mm-flex-justify-start mm-mt-3 allocate-link"
            target="_blank"
            :href="handleLink"
            >Or click here to create a new {{ agreementTypeLabel }}
            <m-m-icon class="mm-mt-2" icon="arrow-top-right-on-square" />
          </m-m-link>
        </div>
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
        :is-disabled="isSubmitButtonLoading"
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
