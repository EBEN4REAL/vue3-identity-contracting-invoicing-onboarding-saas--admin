<script setup lang="ts">
import { Ref, onMounted, ref } from "vue";
import { authService } from "../../auth/auth.service";
import {
  EmptyStateType,
  TableRequestParams,
  TableResponse,
} from "../../mm_ui_kit/src/types/table.types";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { PaymentIntentRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";

const serviceProviderId: Ref<string> = ref("");
const payments: Ref<TableResponse<PaymentIntentRead> | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);
const paymentStatus = (row: PaymentIntentRead) => ({
  label: row.succeeded ? "Succeeded" : "Failed",
  badgeType: row.succeeded ? "Active" : "Inactive",
});
const emptyState: EmptyStateType = {
  icon: "price-tag-outline",
  title: "No payments",
  description:
    "When a payment is made by one of your customers it will be displayed here.",
};
const headers = [
  {
    key: "payment_id",
    label: "Payment Id",
    sortable: false,
  },
  {
    key: "service_consumer_name",
    label: "Customer",
    sortable: false,
  },
  {
    key: "payment_method",
    label: "Payment method",
    sortable: false,
  },
  {
    key: "amount",
    label: "Amount",
    sortable: false,
  },
  {
    key: "status",
    label: "Status",
    sortable: false,
  },
  {
    key: "failure_reason",
    label: "Failure reason",
    sortable: false,
  },
  {
    key: "date",
    label: "Date",
    sortable: true,
    sortIcon: true,
    order: "desc",
  },
];

const failureReason = (row: PaymentIntentRead) => row.failure_reason || "-";

const handleUpdateParams = (params: TableRequestParams) => {
  getPayments(params);
};

const getPayments = async (params: TableRequestParams) => {
  isLoading.value = true;
  const response = await billingAndInvoicingService.getPayments(
    serviceProviderId.value,
    params,
  );
  payments.value = response;
  isLoading.value = false;
  return response;
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
});
</script>

<template>
  <m-m-overview-page
    resource-id="subscriptions.payments"
    :show-config-banner="false"
  >
    <m-m-table
      v-if="serviceProviderId"
      cy="payments-table"
      :is-loading="isLoading"
      :headers="headers"
      :rows="payments?.results"
      :total-rows="payments?.total"
      show-header
      :empty-state="emptyState"
      @update-params="handleUpdateParams"
    >
      <template #payment_id="{ row }">
        <m-m-text-ellipsis
          max-width="200px"
          :data-cy="`payment-id-column-${row.id}`"
          >{{ row.id }}
        </m-m-text-ellipsis>
      </template>
      <template #status="{ row }">
        <m-m-badge
          :status="BadgeTypes[paymentStatus(row).badgeType]"
          :text="paymentStatus(row).label"
        />
      </template>
      <template #amount="{ row }">
        {{ convertToMainUnit(Number(row.amount), row.currency)?.formatted }}
      </template>
      <template #failure_reason="{ row }">
        {{ failureReason(row as PaymentIntentRead) }}
      </template>
      <template #service_consumer_name="{ row }">
        {{ row.service_consumer_name || "-" }}
      </template>
      <template #date="{ row }">
        <m-m-formatted-date :raw-date="row.date" format="D MMM YYYY, HH:mm" />
      </template> </m-m-table
  ></m-m-overview-page>
</template>

<style scoped></style>
