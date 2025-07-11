<script setup lang="ts">
import { PropType } from "vue";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { InvoiceRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { downloadBlob } from "~/mm_ui_kit/src/helpers/fileDownload";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import {
  getBadgeColor,
  getBadgeLabel,
} from "~/mm_ui_kit/src/helpers/invoiceUtils";
const props = defineProps({
  invoices: {
    type: Object as PropType<TableResponse<InvoiceRead>>,
    default: () => {},
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update-params"]);

const headers = [
  {
    key: "quaderno_invoice_number",
    label: "Invoice number",
    sortable: false,
  },
  {
    key: "total_amount",
    label: "Invoice amount",
    sortable: false,
  },
  {
    key: "remaining_amount",
    label: "Amount outstanding",
    sortable: false,
  },
  {
    key: "status",
    label: "Status",
    sortable: false,
  },
  {
    key: "date",
    label: "Date created",
    sortable: true,
    sortIcon: true,
    order: "desc",
    sortName: "invoice.date",
  },
  {
    key: "payment_due_date",
    label: "Due date",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "invoice.payment_due_date",
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const dropdownItems = (row: InvoiceRead): TypeDropdownItem[] => [
  {
    label: "Download invoice",
    type: "button",
    onClick: () => {
      downloadInvoice(row);
    },
  },
];

const downloadInvoice = async (invoice: InvoiceRead) => {
  try {
    const pdfBlob = await billingAndInvoicingService.getInvoicePdf(
      invoice.service_consumer_id,
      invoice.id,
    );
    downloadBlob(pdfBlob, `invoice_${invoice.id}.pdf`);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error downloading invoice",
      status: "error",
    });
  }
};

const handleUpdateParams = (params: TableRequestParams) => {
  emit("update-params", params);
};
</script>

<template>
  <m-m-expandable-card title="Invoices" cy="invoices-expandable">
    <m-m-table
      cy="invoices-table"
      :headers="headers"
      :rows="props.invoices?.results"
      :total-rows="props.invoices?.total"
      empty-state="No invoices"
      :is-loading="isLoading"
      @update-params="handleUpdateParams"
    >
      <template #quaderno_invoice_number="{ row }">
        <m-m-text-ellipsis
          max-width="200px"
          :data-cy="`invoice-id-column-${row.quaderno_invoice_number}`"
        >
          {{
            row.quaderno_invoice_number
              ? "#" + row.quaderno_invoice_number
              : "-"
          }}
        </m-m-text-ellipsis>
      </template>
      <template #total_amount="{ row }">
        {{
          convertToMainUnit(Number(row.total_amount), row.currency)?.formatted
        }}
      </template>
      <template #status="{ row }">
        <m-m-badge
          :status="BadgeTypes[getBadgeColor(row)]"
          :text="getBadgeLabel(row)"
        />
      </template>
      <template #date="{ row }">
        <m-m-formatted-date :raw-date="row.date" />
      </template>
      <template #payment_due_date="{ row }">
        <m-m-formatted-date :raw-date="row.payment_due_date" />
      </template>
      <template #remaining_amount="{ row }">
        <span>{{
          convertToMainUnit(Number(row.remaining_amount), row.currency)
            ?.formatted
        }}</span>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="dropdownItems(row)"
            :cy="`actions-dropdown-${row.id}`"
            max-width="218px"
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
  </m-m-expandable-card>
</template>

<style scoped></style>
