<script setup lang="ts">
import { PropType, Ref, onMounted, ref } from "vue";
import { PaymentIntentRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { OrganizationRead } from "~/iam/iam.types";
import { organizationsService } from "~/organizations/organizations.service";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";

const props = defineProps({
  payments: {
    type: Object as PropType<TableResponse<PaymentIntentRead>>,
    default: () => {},
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
    default: false,
  },
  agreementTypes: {
    type: Array as PropType<AgreementTypePoliciesRead[]>,
    default: () => [],
  },
});
const emit = defineEmits(["update-params"]);
const organizations: Ref<OrganizationRead[] | null> = ref(null);
const paymentStatus = (row: PaymentIntentRead) => ({
  label: row.succeeded ? "Succeeded" : "Failed",
  badgeType: row.succeeded ? "Active" : "Inactive",
});
const headers = [
  {
    key: "payment_id",
    label: "Payment Id",
    sortable: false,
  },
  {
    key: "agreement_type_id",
    label: "Subscription name",
    sortable: false,
  },
  {
    key: "amount",
    label: "Amount",
    sortable: false,
  },
  {
    key: "payment_method",
    label: "Payment method",
    sortable: false,
  },
  {
    key: "status",
    label: "Payment status",
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
    sortable: false,
  },
];
const getOrganizations = async () => {
  if (!props.payments?.results) return;

  organizations.value = await Promise.all(
    props.payments?.results?.map((payment: PaymentIntentRead) =>
      organizationsService.getOrganization(payment.service_consumer_id),
    ),
  );
  return organizations;
};

const organizationName = (organization_id: string) => {
  if (organizations.value) {
    const organizationItem = organizations.value.find(
      (organization: OrganizationRead) => organization_id === organization.id,
    );

    return organizationItem ? organizationItem.name : "-";
  }

  return "-";
};

const failureReason = (row: PaymentIntentRead) => row.failure_reason || "-";

const handleUpdateParams = (params: TableRequestParams) => {
  emit("update-params", params);
};

const getAgreementName = (agreementTypeId: string) => {
  const agreementType: AgreementTypePoliciesRead = props.agreementTypes?.find(
    (agreementType: AgreementTypePoliciesRead) =>
      agreementType.id === agreementTypeId,
  );
  return agreementType ? agreementType?.name : "-";
};

onMounted(async () => {
  await getOrganizations();
});
</script>

<template>
  <m-m-expandable-card title="Payments" cy="payments-expandable">
    <m-m-table
      v-if="serviceProviderId"
      cy="payments-table"
      empty-state="No payments"
      :headers="headers"
      :rows="payments?.results"
      :total-rows="payments?.total"
      show-header
      :is-loading="isLoading"
      @update-params="handleUpdateParams"
    >
      <template #payment_id="{ row }">
        <m-m-text-ellipsis
          max-width="200px"
          :data-cy="`payment-id-column-${row.id}`"
          >{{ row.id }}
        </m-m-text-ellipsis>
      </template>
      <template #agreement_type_id="{ row }">
        {{ getAgreementName(row.agreement_type_id) }}
      </template>
      <template #amount="{ row }">
        {{ convertToMainUnit(Number(row.amount), row.currency)?.formatted }}
      </template>
      <template #status="{ row }">
        <m-m-badge
          :status="BadgeTypes[paymentStatus(row).badgeType]"
          :text="paymentStatus(row).label"
        />
      </template>
      <template #failure_reason="{ row }">
        {{ failureReason(row as PaymentIntentRead) }}
      </template>
      <template #customer="{ row }">
        {{ organizationName(row.service_consumer_id) }}
      </template>
      <template #date="{ row }">
        <m-m-formatted-date :raw-date="row.date" />
      </template>
    </m-m-table>
  </m-m-expandable-card>
</template>

<style scoped></style>
