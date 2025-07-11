<script setup lang="ts">
import { ComputedRef, Ref, computed, onMounted, ref } from "vue";
import {
  BillingAddressRead,
  PaymentIntentRead,
  ServiceConsumerRead,
} from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { authService } from "~/auth/auth.service";
import {
  OrganizationReadWithAttributes,
  PaginationSchema_ServiceProviderOrganizationUserRead_,
} from "~/iam/iam.types";
import Policies from "./Tabs/Policies.vue";
import Licenses from "./Tabs/Licenses.vue";
import Subscriptions from "./Tabs/Subscriptions.vue";
import LegalDocuments from "./Tabs/LegalDocuments.vue";
import Payments from "./Tabs/Payments.vue";
import Invoices from "./Tabs/Invoices.vue";
import Users from "./Tabs/Users.vue";
import Roles from "./Tabs/Roles.vue";
import { policiesService } from "~/service-providers/policies.service";
import { SPAgreementRead } from "~/service-providers/Licenses/licenses.types";
import { PaginationSchema_PolicyRead_ } from "~/service-providers/Policies/policies.types";
import { SPLegalDocumentRead } from "~/service-providers/LegalDocuments/legal-documents.types";
import { legalDocumentsService } from "~/service-providers/legal-documents.service";
import { InvoiceRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { useFlag } from "@unleash/proxy-client-vue";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { PolicyTypeBaseRead } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { RoleRead } from "~/service-providers/Roles/roles.type";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { useUiStore } from "~/stores/useUiStore";
import escapeObjectValuesForHtml from "~/mm_ui_kit/src/helpers/escapeObjectValuesForHtml";
import { useTranslation } from "i18next-vue";

const uiStore = useUiStore();
const { t } = useTranslation();

const props = defineProps({
  id: {
    type: String,
    required: true,
  },
});
const accountLicensesEnabled = useFlag("account_licenses");
const legalDocsEnabled = useFlag("legal_documents");
const invoicesAndPaymentsEnabled = useFlag("invoices_overview");
const billingAddressEnabled = useFlag("billing_and_invoicing");
const subscriptionsEnabled = useFlag("subscriptions");
const serviceProviderId: Ref<string> = ref("");
const isSummaryLoading: Ref<boolean> = ref(true);
const isInitialDataLoading: Ref<boolean> = ref(true);
const isLicensesLoading: Ref<boolean> = ref(true);
const isPaymentsLoading: Ref<boolean> = ref(true);
const isInvoicesLoading: Ref<boolean> = ref(true);
const isLegalDocumentsLoading: Ref<boolean> = ref(true);
const isPoliciesLoading: Ref<boolean> = ref(true);
const isRolesLoading: Ref<boolean> = ref(true);
const isUsersLoading: Ref<boolean> = ref(true);
const isSubscriptionsLoading: Ref<boolean> = ref(true);
const customer: Ref<OrganizationReadWithAttributes | null> = ref(null);
const licenses: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
const subscriptions: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
const policies: Ref<PaginationSchema_PolicyRead_ | null> = ref(null);
const roles: Ref<RoleRead[] | null> = ref(null);
const documents: Ref<TableResponse<SPLegalDocumentRead> | null> = ref(null);
const users: Ref<PaginationSchema_ServiceProviderOrganizationUserRead_ | null> =
  ref(null);
const billing_address: Ref<BillingAddressRead | null> = ref(null);
const serviceConsumerDetails: Ref<ServiceConsumerRead | null> = ref(null);
const invoices: Ref<TableResponse<InvoiceRead> | null> = ref(null);
const payments: Ref<TableResponse<PaymentIntentRead> | null> = ref(null);
const agreementTypes: Ref<AgreementTypePoliciesRead[] | null> = ref(null);
const defaultPagination = { limit: ITEMS_PER_PAGE[0], offset: "0" };
const rolePolicyTypeId: Ref<string | null> = ref(null);
const policyTypeCategoryId: Ref<string | null> = ref(null);
const createQueryParams = (
  params?: TableRequestParams,
  additionalParams?: Record<string, string>,
) => {
  return {
    ...defaultPagination,
    ...params,
    ...additionalParams,
  };
};

const formatBillingAddress: ComputedRef<string> = computed(() => {
  if (billing_address.value?.id) {
    const billingAddress = billing_address.value!;
    const {
      country = "",
      postal_code = "",
      town_city = "",
      address_line_1 = "",
      address_line_2 = "",
    } = billingAddress;

    const displayAddressField =
      [address_line_1, address_line_2, country, town_city].join("").length > 0;
    return displayAddressField
      ? `${[address_line_1, address_line_2, country, town_city].filter((val) => !!val).join(", ")}, ${postal_code}`
      : "";
  } else return "-";
});

const customerDetails = computed(() => {
  const details = [
    {
      key: "name",
      label: "Account name",
      text: customer.value?.organization.name,
      isEmpty: !customer.value?.organization.name,
    },
  ];

  if (billingAddressEnabled.value) {
    details.push({
      key: "billing_address",
      label: "Billing address",
      text: formatBillingAddress.value,
      isEmpty: !formatBillingAddress.value,
    });
  }

  if (customer.value?.attributes) {
    customer.value.attributes.forEach((attribute) => {
      details.push({
        key: attribute.id,
        label: attribute.name,
        text: attribute.value,
        isEmpty: attribute.value === null,
      });
    });
  }

  return details;
});

const title: ComputedRef<string> = computed(() =>
  t(
    "account_details.title",
    escapeObjectValuesForHtml({
      accountName: customer.value?.organization.name || "",
    }),
  ),
);

const handleActiveLicensesUpdate = (params: TableRequestParams) => {
  getLicenses(params);
};

const handleSubscriptionsUpdate = (params: TableRequestParams) => {
  getSubscriptions(params);
};
const handleInvoicesUpdate = (params: TableRequestParams) => {
  getInvoices(params);
};
const handlePaymentsUpdate = (params: TableRequestParams) => {
  getPayments(params);
};
const handleLegalDocumentsUpdate = (params: TableRequestParams) => {
  getLegalDocuments(params);
};
const handlePoliciesUpdate = (params: TableRequestParams) => {
  getPolicies(params);
};

const handleRolesUpdate = (params: TableRequestParams) => {
  getRoles(params);
};

const handleUsersUpdate = (params: TableRequestParams) => {
  getUsers(params);
};

const getUsers = async (params?: TableRequestParams) => {
  try {
    isUsersLoading.value = true;
    users.value =
      await serviceProvidersService.getServiceProviderOrganizationUsers(
        serviceProviderId.value,
        props.id,
        params || defaultPagination,
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching users",
      status: "error",
    });
  } finally {
    isUsersLoading.value = false;
  }
};
const getPolicyTypeCategories = async () => {
  try {
    const result = await policiesService.getPolicyTypeCategories();
    const rolePolicyTypeCategory = result.find(
      (policyType: PolicyTypeBaseRead) => policyType.name == "Role",
    );
    const policyTypeCategory = result.find(
      (policyType: PolicyTypeBaseRead) => policyType.name == "Policy",
    );
    rolePolicyTypeId.value = rolePolicyTypeCategory?.id;
    policyTypeCategoryId.value = policyTypeCategory?.id;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching policy type categories",
      status: "error",
    });
  }
};

const getRoles = async (params?: TableRequestParams) => {
  try {
    isRolesLoading.value = true;
    const result = await policiesService.getExternalOrganizationPolicies(
      serviceProviderId.value,
      customer.value?.organization?.id,
      {
        policy_category_id: rolePolicyTypeId.value,
        ...params,
      },
    );
    roles.value = result;
  } finally {
    isRolesLoading.value = false;
  }
};
const getPolicies = async (params?: TableRequestParams) => {
  try {
    isPoliciesLoading.value = true;
    policies.value = await policiesService.getExternalOrganizationPolicies(
      serviceProviderId.value,
      props.id,
      {
        ...(params || defaultPagination),
        policy_category_id: policyTypeCategoryId.value,
      },
    );
  } finally {
    isPoliciesLoading.value = false;
  }
};

const getLicenses = async (params?: TableRequestParams) => {
  try {
    isLicensesLoading.value = true;
    licenses.value = await policiesService.getAgreements(
      serviceProviderId.value,
      {
        service_consumer_id: props.id,
        ...(params || defaultPagination),
        category: "ACCESS",
      },
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching licenses",
      status: "error",
    });
  } finally {
    isLicensesLoading.value = false;
  }
};

const getSubscriptions = async (params?: TableRequestParams) => {
  try {
    isSubscriptionsLoading.value = true;
    subscriptions.value = await policiesService.getAgreements(
      serviceProviderId.value,
      {
        service_consumer_id: props.id,
        ...(params || defaultPagination),
        category: "SUBSCRIPTION",
      },
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching subscriptions",
      status: "error",
    });
  } finally {
    isSubscriptionsLoading.value = false;
  }
};

const getPayments = async (params?: TableRequestParams) => {
  const queryParams = createQueryParams(params, {
    service_consumer_id: props.id,
  });
  try {
    isPaymentsLoading.value = true;
    payments.value = await billingAndInvoicingService.getPayments(
      serviceProviderId.value,
      queryParams,
    );
    await getAgreementTypes();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching payments",
      status: "error",
    });
  } finally {
    isPaymentsLoading.value = false;
  }
};

const getAgreementTypes = async () => {
  if (!payments?.value) return;
  agreementTypes.value = await Promise.all(
    payments?.value.results?.map((payment: PaymentIntentRead) =>
      agreementTypesService.getAgreementType(
        serviceProviderId.value,
        payment.agreement_type_id,
      ),
    ),
  );
  return agreementTypes;
};

const getLegalDocuments = async (params?: TableRequestParams) => {
  const queryParams = createQueryParams(params, {
    service_consumer_id: props.id,
  });
  try {
    isLegalDocumentsLoading.value = true;
    documents.value = await legalDocumentsService.getLegalDocuments(
      serviceProviderId.value,
      queryParams,
    );
  } catch (error) {
    console.error("Error fetching legal documents", error);
  } finally {
    isLegalDocumentsLoading.value = false;
  }
};

const getInvoices = async (params?: TableRequestParams) => {
  const queryParams = createQueryParams(params, {
    service_consumer_id: props.id,
  });
  try {
    isInvoicesLoading.value = true;
    invoices.value = await billingAndInvoicingService.getInvoices(
      serviceProviderId.value,
      queryParams,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching invoices",
      status: "error",
    });
  } finally {
    isInvoicesLoading.value = false;
  }
};

const getBillingAddress = async (orgId: string): Promise<void> => {
  try {
    serviceConsumerDetails.value =
      await billingAndInvoicingService.getServiceConsumerDetails(
        serviceProviderId.value,
        orgId,
      );
    billing_address.value = serviceConsumerDetails.value?.billing_address;
  } catch (error) {
    console.error("Error fetching billing address", error);
  }
};

const handleStatus = (isActive: boolean) => {
  return isActive ? BadgeTypes.Active : BadgeTypes.Inactive;
};

const getCustomerDetails = async () => {
  try {
    customer.value =
      await serviceProvidersService.getServiceProviderOrganizationDetails(
        serviceProviderId.value,
        props.id,
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "There was an error while fetching data",
      status: "error",
    });
  }
};

const getSummary = async () => {
  try {
    isSummaryLoading.value = true;

    const promises = [];

    promises.push(getCustomerDetails());

    if (billingAddressEnabled.value) {
      promises.push(getBillingAddress(props.id));
    }
    await Promise.all(promises);
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  } finally {
    isSummaryLoading.value = false;
  }
};

const getInitialData = async () => {
  try {
    isInitialDataLoading.value = true;

    const userProfile = await authService.getProfile();
    await getPolicyTypeCategories();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }

    await getSummary();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  } finally {
    isInitialDataLoading.value = false;
  }
};

onMounted(async () => {
  await getInitialData();
});
</script>
<template>
  <m-m-teleport to="common-page-layout-header-title">
    <div
      v-if="customer?.organization.name"
      class="mm-flex mm-flex-align-center"
    >
      <div v-sanitize-html="title" />
      <m-m-badge
        :status="handleStatus(customer.is_active)"
        indicator
        class="mm-ml-8"
      />
    </div>
  </m-m-teleport>
  <div class="mm-page-title mm-page-title--h2 mm-mb-8">Summary</div>
  <m-m-data-iterator v-if="!isSummaryLoading" :data="customerDetails" />
  <m-m-skeleton-loader v-else height="92" />
  <m-m-divider class="expandables-divider" />
  <div class="expandables-wrapper">
    <template v-if="accountLicensesEnabled">
      <Licenses
        v-if="!isInitialDataLoading"
        :user="customer"
        :is-loading="isLicensesLoading"
        :licenses="licenses"
        :is-s-p-viewer-only="uiStore.isSPViewerOnly"
        :service-provider-id="serviceProviderId"
        @update-params="handleActiveLicensesUpdate"
        @update-licenses="getLicenses" />
      <m-m-skeleton-loader v-else height="48"
    /></template>

    <template v-if="subscriptionsEnabled">
      <Subscriptions
        v-if="!isInitialDataLoading"
        :user="customer"
        :is-loading="isSubscriptionsLoading"
        :is-s-p-viewer-only="uiStore.isSPViewerOnly"
        :licenses="subscriptions"
        :service-provider-id="serviceProviderId"
        @update-params="handleSubscriptionsUpdate"
        @update-licenses="getSubscriptions"
      />
      <m-m-skeleton-loader v-else height="48" />
    </template>

    <template v-if="invoicesAndPaymentsEnabled">
      <Payments
        v-if="!isInitialDataLoading"
        :payments="payments"
        :agreement-types="agreementTypes"
        :service-provider-id="serviceProviderId"
        :is-loading="isPaymentsLoading"
        @update-params="handlePaymentsUpdate"
        @update-payments="getPayments"
      />
      <m-m-skeleton-loader v-else height="48" />
    </template>

    <template v-if="invoicesAndPaymentsEnabled">
      <Invoices
        v-if="!isInitialDataLoading"
        :invoices="invoices"
        :is-loading="isInvoicesLoading"
        @update-params="handleInvoicesUpdate"
      />
      <m-m-skeleton-loader v-else height="48" />
    </template>

    <template v-if="legalDocsEnabled">
      <LegalDocuments
        v-if="!isInitialDataLoading"
        :documents="documents"
        :service-provider-id="serviceProviderId"
        @update-params="handleLegalDocumentsUpdate"
      />
      <m-m-skeleton-loader v-else height="48" />
    </template>

    <Policies
      v-if="!isInitialDataLoading"
      :user="customer"
      :is-loading="isPoliciesLoading"
      :policies="policies"
      :is-s-p-viewer-only="uiStore.isSPViewerOnly"
      :service-provider-id="serviceProviderId"
      :policy-type-category-id="policyTypeCategoryId"
      @update-policies="getPolicies"
      @update-table-params="handlePoliciesUpdate"
    />
    <m-m-skeleton-loader v-else height="48" />

    <Roles
      v-if="!isInitialDataLoading"
      :user="customer"
      :is-loading="isPoliciesLoading"
      :is-s-p-viewer-only="uiStore.isSPViewerOnly"
      :roles="roles"
      :service-provider-id="serviceProviderId"
      :roles-category-id="rolePolicyTypeId"
      @update-roles="getRoles"
      @update-table-params="handleRolesUpdate"
    />
    <m-m-skeleton-loader v-else height="48" />

    <Users
      v-if="!isInitialDataLoading"
      :id="id"
      :is-loading="isUsersLoading"
      :is-s-p-viewer-only="uiStore.isSPViewerOnly"
      :users="users"
      @update-table-params="handleUsersUpdate"
    />
    <m-m-skeleton-loader v-else height="48" />
  </div>
</template>
<style scoped>
:deep(.mm-table) {
  padding: 0 24px 24px 24px;
}
:deep(.mm-expandable-card--active) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body tr) {
  background-color: #fff;
}
:deep(.mm-table-body thead tr) {
  background-color: #fafbfc;
}
:deep(.mm-table-actions-cell) {
  overflow: hidden;
  white-space: nowrap;
}
.iterator-title {
  font-size: 20px;
  font-weight: 600;
  line-height: 30px;
  text-align: left;
  color: var(--Gray-700, #384250);
}
.expandables-divider {
  margin: 24px 0;
}
.expandables-wrapper {
  display: flex;
  gap: 16px;
  flex-direction: column;
}
</style>
