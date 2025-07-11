<script setup lang="ts">
import { Ref, ref } from "vue";
import { authService } from "../../auth/auth.service";
import {
  EmptyStateType,
  TableRequestParams,
  TableResponse,
} from "../../mm_ui_kit/src/types/table.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { InvoiceRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { downloadBlob } from "~/mm_ui_kit/src/helpers/fileDownload";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import {
  getBadgeColor,
  getBadgeLabel,
} from "~/mm_ui_kit/src/helpers/invoiceUtils";

const serviceProviderId: Ref<string> = ref("");
const invoices: Ref<TableResponse<InvoiceRead> | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);
const defaultPagination = { limit: ITEMS_PER_PAGE[0], offset: "0" };
const organizations: Ref<ServiceProviderOrganizationRead[] | null> = ref(null);
const dropdownItems = (row: InvoiceRead): TypeDropdownItem[] => [
  {
    label: "Download invoice",
    type: "button",
    onClick: () => {
      downloadInvoice(row);
    },
  },
];
const emptyState: EmptyStateType = {
  icon: "receipt-percent-outline",
  title: "No invoices generated yet",
  description:
    "When an invoice is generated for a subscription it will be displayed here.",
};
const headers = [
  {
    key: "quaderno_invoice_number",
    label: "Invoice number",
    sortable: false,
  },
  {
    key: "customer",
    label: "Customer",
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

const downloadInvoice = async (invoice: InvoiceRead) => {
  try {
    const response = await billingAndInvoicingService.getSPInvoicePdf(
      invoice.service_provider_id,
      invoice.id,
    );
    downloadBlob(response, `${invoice.id}.pdf`);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: errorMessage || "Error fetching invoices",
      status: "error",
    });
  }
};

const handleUpdateParams = (params: TableRequestParams) => {
  getInvoices(params);
};

const organizationName = (organization_id: string) => {
  if (organizations.value) {
    const organizationItem = organizations.value?.find(
      (organization: ServiceProviderOrganizationRead) =>
        organization_id === organization?.organization?.id,
    );

    return organizationItem ? organizationItem.organization.name : "-";
  }
  return "-";
};

const getInvoices = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || "";
    }
    invoices.value = await billingAndInvoicingService.getInvoices(
      serviceProviderId.value,
      params || defaultPagination,
    );
    await getOrganizations();
    isLoading.value = false;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching invoices",
      status: "error",
    });
    isLoading.value = false;
  }
};

const getOrganizations = async () => {
  if (!invoices.value?.results) return;

  const uniqueConsumerIds = new Set(
    invoices.value.results.map((invoice) => invoice.service_consumer_id),
  );

  const uniqueOrganizations =
    await serviceProvidersService.getServiceProviderOrganizations(
      serviceProviderId.value,
      {
        offset: "0",
        limit: "10",
        organization_id: Array.from(uniqueConsumerIds) as string[],
      },
    );

  organizations.value = uniqueOrganizations?.results;
  return organizations;
};
</script>

<template>
  <m-m-overview-page
    resource-id="subscriptions.invoices"
    :show-config-banner="false"
  >
    <m-m-table
      cy="invoices-table"
      :is-loading="isLoading"
      :headers="headers"
      :rows="invoices?.results"
      show-search
      :total-rows="invoices?.total"
      :empty-state="emptyState"
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
            ?.formatted
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
      </template> </m-m-table
  ></m-m-overview-page>
</template>

<style scoped></style>
