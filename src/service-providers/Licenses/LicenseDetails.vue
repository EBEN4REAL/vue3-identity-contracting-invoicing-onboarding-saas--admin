<script setup lang="ts">
import { ComputedRef, Ref, computed, onMounted, ref } from "vue";
import { authService } from "~/auth/auth.service";
import { useRoute } from "vue-router";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import {
  AgreementExtendedRead,
  getBillingPeriod,
  getPriceModel,
} from "../billing-types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { policiesService } from "../policies.service";
import { SPAgreementRead } from "./licenses.types";
import Payments from "./LicenseDetails/Tabs/Payments.vue";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { useFlag } from "@unleash/proxy-client-vue";
import Invoices from "./LicenseDetails/Tabs/Invoices.vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { LegalDocumentRead } from "../LegalDocuments/legal-documents.types";
import LegalDocuments from "./LicenseDetails/Tabs/LegalDocuments.vue";
import { legalDocumentsService } from "../legal-documents.service";
import {
  InvoiceRead,
  PaymentIntentRead,
} from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import DialogCancelSubscription from "./Dialogs/DialogCancelSubscription.vue";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { useUiStore } from "~/stores/useUiStore";
import { useTranslation } from "i18next-vue";
import escapeObjectValuesForHtml from "~/mm_ui_kit/src/helpers/escapeObjectValuesForHtml";

const uiStore = useUiStore();
const route = useRoute();
const { t } = useTranslation();
const paymentsEnabled = useFlag("billing_and_invoicing");
const legalDocsEnabled = useFlag("legal_documents");
const serviceProviderId: Ref<string> = ref("");
const agreementBillingDetails: Ref<AgreementExtendedRead | null> = ref(null);
const agreement: Ref<SPAgreementRead | null> = ref(null);
const defaultPagination = { limit: ITEMS_PER_PAGE[0], offset: "0" };
const documents: Ref<TableResponse<LegalDocumentRead> | null> = ref(null);
const invoices: Ref<TableResponse<InvoiceRead> | null> = ref(null);
const payments: Ref<TableResponse<PaymentIntentRead> | null> = ref(null);
const isInvoicesLoading: Ref<boolean> = ref(true);
const isPaymentsLoading: Ref<boolean> = ref(true);
const isLegalDocumentsLoading: Ref<boolean> = ref(true);
const isAgreementDetailsLoading: Ref<boolean> = ref(true);
const isDialogCancelSubscriptionOpen: Ref<boolean> = ref(false);
const isAgreementCancelling = ref(false);

const handleError = (error: string) => {
  eventBus.$emit("onShowToast", {
    text: error,
    status: "error",
  });
};

const isAccessLicenseRoute = computed(() => {
  return route.path.includes("access-license");
});

const dropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => [
  {
    label: `Cancel  ${isAccessLicenseRoute.value ? "license" : "subscription"}`,
    type: "button",
    isDisabled:
      (isCancelledAtEndOfBillingPeriod.value
        ? true
        : !agreement.value?.active) || uiStore.isSPViewerOnly,
    onClick: () => {
      isDialogCancelSubscriptionOpen.value = true;
    },
  },
]);

const badgeStatus = (license: SPAgreementRead) => {
  if (license && !license?.cancelled && !license?.active) {
    return BadgeTypes.Warning;
  } else {
    return license?.cancelled
      ? BadgeTypes.Cancelled
      : license?.active
        ? BadgeTypes.Active
        : BadgeTypes.Inactive;
  }
};

const badgeText: ComputedRef<string> = computed(() =>
  badgeStatus(agreement.value as SPAgreementRead) == "warning" ? "Pending" : "",
);

const isRecurringBilling = computed(() => {
  return (
    agreementBillingDetails.value?.agreement_type.billing_type !== "ONCE_OFF" &&
    agreementBillingDetails.value?.agreement_type.billing_type !== "FREE" &&
    agreementBillingDetails.value?.agreement_type.billing_type !== null
  );
});

const pricingModel = computed(() => {
  if (!agreementBillingDetails.value?.agreement_type.billing_type) {
    return "Free";
  }
  return getPriceModel(
    agreementBillingDetails.value?.agreement_type.billing_type,
  );
});

const price = computed(() => {
  return agreementBillingDetails.value?.agreement_type?.price?.amount
    ? agreementBillingDetails.value?.agreement_type?.price?.amount.toFixed(2)
    : "-";
});

const showPrice = computed(() => {
  return (
    !!agreementBillingDetails?.value?.agreement_type.billing_type &&
    pricingModel.value !== "Free"
  );
});

const isUserBasedRecurring = computed(() => {
  return (
    agreementBillingDetails.value?.agreement_type.billing_type ===
    "USER_BASED_RECURRING"
  );
});
const isCancellingInProgress: ComputedRef<boolean> = computed(
  () =>
    isAgreementCancelling.value &&
    (!agreementBillingDetails.value?.cancelled ||
      !isCancelledAtEndOfBillingPeriod.value),
);
const isCancellingProcessFinished: ComputedRef<boolean> = computed(
  () =>
    isAgreementCancelling.value &&
    (agreementBillingDetails.value?.cancelled ||
      isCancelledAtEndOfBillingPeriod.value),
);
const isCancelledAtEndOfBillingPeriod = computed(
  () => agreementBillingDetails.value?.cancel_at_period_end,
);

const priceLabel = computed(() => {
  return isUserBasedRecurring.value ? "Price (per user)" : "Price";
});

const title: ComputedRef<string> = computed(() =>
  t(
    "subscriptions.subscription_details.title",
    escapeObjectValuesForHtml({
      agreementName: agreement.value?.agreement_name || "",
      serviceConsumerName:
        agreementBillingDetails.value?.service_consumer_name || "",
    }),
  ),
);

const createQueryParams = (
  params?: TableRequestParams,
  additionalParams?: Record<string, string | boolean>,
) => {
  return {
    ...defaultPagination,
    ...params,
    ...additionalParams,
  };
};

const isAgreementActive = computed(() => {
  return agreement.value?.active;
});

const getServiceProvider = async () => {
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
};

const getInvoices = async (params?: TableRequestParams) => {
  const queryParams = createQueryParams(params, {
    agreement_id: route.params.license_id.toString(),
  });
  try {
    await getServiceProvider();
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

const cancelSubscription = async () => {
  try {
    await policiesService.cancelServiceProviderAgreement(
      serviceProviderId.value,
      agreement.value?.id,
    );
  } catch {
    eventBus.$emit("onShowToast", {
      text: "Error cancelling subscription",
      status: "error",
    });
  } finally {
    if (!isRecurringBilling.value || isUserBasedRecurring.value) {
      await getLicense();
    } else {
      isAgreementCancelling.value = true;
      await pollGetAgreementBillingDetails();
    }
    isDialogCancelSubscriptionOpen.value = false;
  }
};

const getPayments = async (params?: TableRequestParams) => {
  const queryParams = createQueryParams(params, {
    agreement_id: route.params.license_id.toString(),
  });
  try {
    await getServiceProvider();
    isPaymentsLoading.value = true;
    payments.value = await billingAndInvoicingService.getPayments(
      serviceProviderId.value,
      queryParams,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching payments",
      status: "error",
    });
  } finally {
    isPaymentsLoading.value = false;
  }
};

const getLicenseDetails = async () => {
  try {
    await getServiceProvider();
    isAgreementDetailsLoading.value = true;
    agreementBillingDetails.value =
      await billingAndInvoicingService.getAgreementBillingDetails(
        serviceProviderId.value,
        route.params?.license_id.toString(),
      );
  } catch (error) {
    handleError(error as string);
  } finally {
    isAgreementDetailsLoading.value = false;
    if (isCancellingProcessFinished.value) {
      isAgreementCancelling.value = false;
    }
  }
};

const getLicense = async () => {
  try {
    agreement.value = await policiesService.getAgreement(
      serviceProviderId.value,
      route.params?.license_id.toString(),
    );
  } catch (error) {
    handleError(error as string);
  }
};

const pollGetAgreementBillingDetails = async () => {
  let timeoutId: number;
  const checkBillingDetails = async () => {
    await getLicenseDetails();
    if (
      agreementBillingDetails.value?.next_billing_due_date &&
      !isCancellingInProgress.value
    ) {
      clearTimeout(timeoutId);
      return;
    }
    timeoutId = setTimeout(checkBillingDetails, 2000);
  };
  checkBillingDetails();
};

const getLegalDocuments = async (params?: TableRequestParams) => {
  const queryParams = createQueryParams(params, {
    fully_signed: true,
  });
  try {
    await getServiceProvider();
    isLegalDocumentsLoading.value = true;
    documents.value = await legalDocumentsService.getAgreementLegalDocuments(
      serviceProviderId.value,
      route.params.license_id.toString(),
      queryParams,
    );
  } finally {
    isLegalDocumentsLoading.value = false;
  }
};

const handlePaymentsUpdate = (params: TableRequestParams) => {
  getPayments(params);
};
const handleLegalDocumentsUpdate = (params: TableRequestParams) => {
  getLegalDocuments(params);
};
const handleInvoicesUpdate = (params: TableRequestParams) => {
  getInvoices(params);
};

const formattedTotalPrice = computed(() => {
  if (!agreementBillingDetails.value?.currency) return "";

  return convertToMainUnit(
    Number(
      agreementBillingDetails.value.current_cost_per_billing_period_amount || 0,
    ),
    agreementBillingDetails.value.currency,
  ).formatted;
});

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  await getLicenseDetails();
  await getLicense();
});
</script>
<template>
  <m-m-teleport to="common-page-layout-header-title">
    <div v-if="agreement" class="mm-flex mm-flex-align-center">
      <div v-sanitize-html="title" />
      <m-m-badge
        v-if="isCancelledAtEndOfBillingPeriod"
        :status="BadgeTypes.Warning"
        indicator
        text="Non Renewing"
        class="mm-ml-8"
      />
      <m-m-badge
        v-else
        :status="badgeStatus(agreement as SPAgreementRead)"
        :text="badgeText"
        indicator
        class="mm-ml-8"
      />
    </div>
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-subtitle">
    <div
      v-sanitize-html="$t('subscriptions.subscription_details.subtitle')"
    ></div>
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-controls">
    <div class="mm-flex mm-flex-gap-6">
      <m-m-dropdown
        v-if="!agreement?.cancelled"
        cy="license-details-header-dropdown"
        :items="dropdownItems"
      />
    </div>
  </m-m-teleport>
  <div>
    <div class="mm-page-title mm-page-title--h2 mm-mb-8">Summary</div>
    <div class="mm-flex mm-flex-column mm-flex-gap-12">
      <m-m-skeleton-loader v-if="isAgreementDetailsLoading" />
      <m-m-card v-else class="mm-pa-8">
        <div
          class="mm-grid mm-grid-columns-4 mm-grid-row-gap-12 mm-grid-column-gap-16"
        >
          <div class="mm-page-item-label">
            Customer account
            <div class="mm-page-item-value">
              <m-m-link
                class="license-details--link"
                font-weigth="500"
                :to="`/sp/accounts/${agreementBillingDetails?.service_consumer_id}`"
                cy="organization-name"
              >
                {{ agreementBillingDetails?.service_consumer_name }}
              </m-m-link>
            </div>
          </div>
          <div class="mm-page-item-label">
            Effective from
            <div class="mm-page-item-value" data-cy="effective-from">
              <m-m-formatted-date :raw-date="agreement?.effective_from_date" />
            </div>
          </div>
          <div v-if="agreement?.cancelled" class="mm-page-item-label">
            Effective to
            <div class="mm-page-item-value" data-cy="effective-to">
              <m-m-formatted-date :raw-date="agreement?.valid_until" />
            </div>
          </div>
          <div v-if="!isAccessLicenseRoute" class="mm-page-item-label">
            Pricing model
            <div class="mm-page-item-value" data-cy="pricing-model">
              {{ pricingModel }}
            </div>
          </div>
          <div
            v-if="showPrice && !isAccessLicenseRoute"
            class="mm-page-item-label"
          >
            {{ priceLabel }}
            <div class="mm-page-item-value" data-cy="price">
              {{
                convertToMainUnit(
                  Number(price),
                  agreementBillingDetails?.agreement_type?.price
                    ?.currency as string,
                ).formatted
              }}
            </div>
          </div>
          <div v-if="isUserBasedRecurring" class="mm-page-item-label">
            <div class="mm-flex mm-flex-align-center mm-flex-gap-2">
              Total price
              <div>
                <m-m-icon icon="info" width="16px" height="16px" />
                <m-m-tooltip display-position="toRight">
                  This is the total amount based on the current active users on
                  the subscription times the price per user. Excludes any
                  prorata amounts for current billing period.
                </m-m-tooltip>
              </div>
            </div>
            <div class="mm-page-item-value">
              {{ formattedTotalPrice }}
            </div>
          </div>
          <div
            v-if="isRecurringBilling && !isAccessLicenseRoute"
            class="mm-page-item-label"
          >
            Billing period
            <div class="mm-page-item-value" data-cy="billing-period">
              {{
                agreementBillingDetails?.agreement_type?.billing_period_unit &&
                getBillingPeriod(
                  agreementBillingDetails?.agreement_type?.billing_period_unit,
                )
              }}
            </div>
          </div>
          <div
            v-if="
              isRecurringBilling && !isAccessLicenseRoute && isAgreementActive
            "
            class="mm-page-item-label"
          >
            Next billing date
            <div class="mm-page-item-value" data-cy="next-billing-date">
              <m-m-formatted-date
                :raw-date="agreementBillingDetails?.next_billing_due_date"
              />
            </div>
          </div>
        </div>
      </m-m-card>

      <m-m-divider />
      <Payments
        v-if="paymentsEnabled && !isAccessLicenseRoute"
        :payments="payments"
        :is-loading="isPaymentsLoading"
        @update-params="handlePaymentsUpdate"
      />
      <Invoices
        v-if="paymentsEnabled && !isAccessLicenseRoute"
        :invoices="invoices"
        :is-loading="isInvoicesLoading"
        @update-params="handleInvoicesUpdate"
      />
      <LegalDocuments
        v-if="legalDocsEnabled"
        :documents="documents"
        :service-provider-id="serviceProviderId"
        :is-loading="isLegalDocumentsLoading"
        @update-params="handleLegalDocumentsUpdate"
      />
    </div>
  </div>
  <dialog-cancel-subscription
    v-if="isDialogCancelSubscriptionOpen"
    :is-access-license="isAccessLicenseRoute"
    :is-open="isDialogCancelSubscriptionOpen"
    :service-provider-id="serviceProviderId"
    :agreement-id="agreement?.id"
    :is-user-based-pricing="isUserBasedRecurring"
    @close="isDialogCancelSubscriptionOpen = false"
    @cancel-subscription="cancelSubscription"
  />
</template>
<style scoped lang="scss">
.license-details {
  &--link {
    text-decoration: underline;
  }
}

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
</style>
