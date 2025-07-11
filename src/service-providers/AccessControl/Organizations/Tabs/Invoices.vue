<script setup lang="ts">
import { Ref, onMounted, ref } from "vue";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { organizationsService } from "~/organizations/organizations.service";
import { InvoiceRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { OrganizationRead } from "~/iam/iam.types";
import { PropType } from "vue";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { downloadBlob } from "~/mm_ui_kit/src/helpers/fileDownload";
import {
  getBadgeColor,
  getBadgeLabel,
} from "~/mm_ui_kit/src/helpers/invoiceUtils";

const props = defineProps({
  invoices: {
    type: Object as PropType<TableResponse<InvoiceRead>>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
    default: false,
  },
});
const emit = defineEmits(["update-params"]);

const dropdownItems = (row: InvoiceRead): TypeDropdownItem[] => [
  {
    label: "Download invoice",
    type: "button",
    onClick: () => {
      downloadInvoice(row);
    },
  },
];

const organizations: Ref<OrganizationRead[] | null> = ref(null);
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
    key: "invoice.date",
    label: "Date created",
    sortable: true,
  },
  {
    key: "invoice.payment_due_date",
    label: "Due date",
    sortable: true,
  },
  {
    label: "",
    key: "actions",
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

const organizationName = (organization_id: string) => {
  if (organizations.value) {
    const organizationItem = organizations.value.find(
      (organization: OrganizationRead) => organization_id === organization.id,
    );

    return organizationItem ? organizationItem.name : "-";
  }

  return "-";
};

const getOrganizations = async () => {
  if (!props.invoices?.results) return;
  else {
    organizations.value = await Promise.all(
      props.invoices?.results.map((invoice: InvoiceRead) =>
        organizationsService.getOrganization(invoice.service_consumer_id),
      ),
    );
    return organizations;
  }
};
const handleUpdateParams = (params: TableRequestParams) => {
  emit("update-params", params);
};
onMounted(async () => {
  if (props.invoices) await getOrganizations();
});
</script>

<template>
  <m-m-expandable-card title="Invoices" cy="invoices-expandable">
    <m-m-table
      show-search
      background-color="#F2F4F7"
      cy="invoices-table"
      :is-loading="isLoading"
      :headers="headers"
      :rows="invoices?.results"
      :total-rows="invoices?.total"
      empty-state="No invoices"
      @update-params="handleUpdateParams"
    >
      <template #quaderno_invoice_number="{ row }">
        <m-m-text-ellipsis max-width="200px">
          {{
            row.quaderno_invoice_number
              ? "#" + row.quaderno_invoice_number
              : "-"
          }}
        </m-m-text-ellipsis>
      </template>
      <template #customer="{ row }">
        {{ organizationName(row.service_consumer_id) }}
      </template>
      <template #total_amount="{ row }">
        {{
          convertToMainUnit(Number(row.total_amount), row.currency)?.formatted
        }}
      </template>
      <template #remaining_amount="{ row }">
        {{
          convertToMainUnit(Number(row.remaining_amount), row.currency)
            .formatted
        }}
      </template>
      <template #invoice.date="{ row }">
        <m-m-formatted-date :raw-date="row.date" />
      </template>
      <template #status="{ row }">
        <m-m-badge
          :status="BadgeTypes[getBadgeColor(row)]"
          :text="getBadgeLabel(row)"
        />
      </template>
      <template #invoice.payment_due_date="{ row }">
        <m-m-formatted-date :raw-date="row.payment_due_date" />
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
