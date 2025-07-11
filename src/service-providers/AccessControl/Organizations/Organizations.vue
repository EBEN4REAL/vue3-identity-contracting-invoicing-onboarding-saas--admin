<script setup lang="ts">
import { ComputedRef, Ref, computed, onMounted, ref } from "vue";
import { authService } from "~/auth/auth.service";
import {
  EmptyStateType,
  TableRequestParams,
} from "~/mm_ui_kit/src/types/table.types";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { useRoute, useRouter } from "vue-router";
import {
  OrganizationRead,
  PaginationSchema_OrganizationRead_,
} from "~/iam/iam.types";
import OrganizationCreateModal from "~/service-providers/AccessControl/Organizations/Dialogs/OrganizationCreateModal.vue";
import DialogImportOrganizations from "~/service-providers/AccessControl/Organizations/Dialogs/DialogImportOrganizations.vue";
import {
  CustomerOrganizationMetricsRead,
  TimeBasedValuesType,
} from "~/events/events.types";
import { auditEventsService } from "~/logs/Tabs/AuditLog/audit-events.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useFlag } from "@unleash/proxy-client-vue";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const router = useRouter();
const route = useRoute();
const accountsMetricsEnabled = useFlag("accounts_metrics");
const serviceProviderId: Ref<string> = ref("");
const metrics: Ref<CustomerOrganizationMetricsRead | null> = ref(null);
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const organizations: Ref<PaginationSchema_OrganizationRead_ | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);
const isDialogCreateCustomerOpen: Ref<boolean> = ref(false);
const isDialogImportOrganizationsOpen: Ref<boolean> = ref(false);
const forceUpdate = ref(0);
const emptyState: EmptyStateType = {
  title: "Create your first account",
  description:
    "You can create an organization account to access your applications or they will appear here when they try to login to your apps.",
  learnMoreHref: "https://docs.myveriam.com/for-providers/customer-accounts",
  icon: "building-library-outline",
};
const headers = [
  {
    key: "name",
    label: "Account name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    width: "30%",
  },
  {
    key: "created_date",
    label: "Onboarded date",
    sortable: true,
    sortIcon: true,
    order: "desc",
    defaultSortItem: true,
  },
  {
    key: "is_active",
    label: "Status",
    sortable: false,
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const getOrganizations = async (params?: TableRequestParams) => {
  isLoading.value = true;

  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }

  organizations.value =
    await serviceProvidersService.getServiceProviderOrganizations(
      serviceProviderId.value,
      params
        ? params
        : {
            limit: ITEMS_PER_PAGE[0],
            offset: "0",
            sort: headers[1].key + ":" + headers[1].order,
          },
    );
  isLoading.value = false;
};

const statusMap = (isActive: boolean) => {
  return isActive ? BadgeTypes.Active : BadgeTypes.Inactive;
};

const detailedViewLink = (row: OrganizationRead) =>
  `/sp/accounts/${row.organization?.id}`;

const handleUpdateParams = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getOrganizations(params);
};

const onCreateCustomerDialogOpen = () => {
  isDialogCreateCustomerOpen.value = true;
};

const onCreateCustomerDialogClose = () => {
  isDialogCreateCustomerOpen.value = false;
  const updateOrganizations = async () => {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
      forceUpdate.value++;
    }
  };
  updateOrganizations();
};

const onDialogImportOrganizationsOpen = () => {
  isDialogImportOrganizationsOpen.value = true;
};

const onDialogImportOrganizationsClose = () => {
  isDialogImportOrganizationsOpen.value = false;
};

const totalOrgs = computed(() => organizations.value?.total ?? 0);

const numberOfNewAccountsTimeBasedValues: ComputedRef<TimeBasedValuesType> =
  computed(() => ({
    startTimeValue:
      metrics.value?.new_customer_organizations_in_previous_time_period ?? 0,
    endTimeValue: metrics.value?.new_customer_organizations ?? 0,
  }));

const totalNumberOfAccountsTimeBasedValues: ComputedRef<TimeBasedValuesType> =
  computed(() => ({
    startTimeValue:
      metrics.value?.start_date_active_customer_organizations ?? 0,
    endTimeValue: metrics.value?.end_date_active_customer_organizations ?? 0,
  }));

const totalNumberOfAccounts: ComputedRef<TimeBasedValuesType> = computed(
  () => ({
    startTimeValue: 0,
    endTimeValue: totalOrgs.value ?? 0,
  }),
);

const getCustomerOrganizationMetrics = async () => {
  try {
    metrics.value = await auditEventsService.getCustomerOrganizationMetrics(
      serviceProviderId.value,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching customer organization metrics",
      status: "error",
    });
  }
};

onMounted(async () => {
  isSPAdmin.value = (await authService.isUserSPAdmin()) === true;
  isSPEditor.value = (await authService.isUserSPEditor()) === true;
  if (route.query.openModal) {
    isDialogCreateCustomerOpen.value = true;
  }
  await getCustomerOrganizationMetrics();
});

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_account",
    action: onCreateCustomerDialogOpen,
    isDisabled: uiStore.isSPViewerOnly,
  },
  {
    key: "import_accounts",
    action: onDialogImportOrganizationsOpen,
    isDisabled: uiStore.isSPViewerOnly,
  },
]);
</script>

<template>
  <m-m-overview-page
    resource-id="accounts"
    :buttons="buttons"
    :show-config-banner="false"
  ></m-m-overview-page>
  <div
    v-if="metrics && accountsMetricsEnabled"
    class="mm-flex mm-flex-gap-10 mm-mb-10"
  >
    <m-m-totals-card
      title="Active accounts"
      :time-based-values="totalNumberOfAccountsTimeBasedValues"
      tooltip-content="Current total number of accounts where users have logged in to one of your applications"
      more-is-positive
    />
    <m-m-totals-card
      title="New accounts"
      :time-based-values="numberOfNewAccountsTimeBasedValues"
      tooltip-content="Number of new accounts added in the last 30 days"
      more-is-positive
    />
    <m-m-totals-card
      title="Total number of accounts"
      :time-based-values="totalNumberOfAccounts"
      :show-footer-text="false"
    />
  </div>
  <m-m-table
    :key="forceUpdate"
    cy="organizations-table"
    :is-loading="isLoading"
    :headers="headers"
    :rows="organizations?.results"
    :total-rows="organizations?.total"
    show-search
    :empty-state="emptyState"
    @update-params="handleUpdateParams"
  >
    <template #empty-state-button>
      <m-m-button
        prepend-icon="plus-white"
        cy="empty-state-button-create-organization"
        :is-disabled="uiStore.isSPViewerOnly"
        @click="onCreateCustomerDialogOpen"
      >
        Create account
      </m-m-button>
    </template>
    <template #name="{ row }">
      <m-m-link
        :to="detailedViewLink(row)"
        font-weigth="500"
        :cy="`table-${row.organization?.id}`"
      >
        {{ row.organization?.name }}
      </m-m-link>
    </template>
    <template #created_date="{ row }">
      <m-m-formatted-date :raw-date="row.created_date" />
    </template>
    <template #is_active="{ row }">
      <m-m-badge
        :status="statusMap(row.is_active as boolean)"
        indicator
        :data-cy="`badge-${row.organization.id}`"
      />
    </template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown
          list-side="left"
          :items="[
            {
              label: 'View details',
              type: 'button',
              onClick: () => router.push(`/sp/accounts/${row.organization.id}`),
            },
          ]"
          :cy="`actions-dropdown-${row.organization.id}`"
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

  <OrganizationCreateModal
    :is-open="isDialogCreateCustomerOpen"
    :service-provider-id="serviceProviderId"
    @close="onCreateCustomerDialogClose"
  />

  <dialog-import-organizations
    :is-open="isDialogImportOrganizationsOpen"
    :service-provider-id="serviceProviderId"
    @update="getOrganizations"
    @close="onDialogImportOrganizationsClose"
  />
</template>

<style lang="scss" scoped>
.customer-header-controls {
  display: flex;
  gap: 12px;

  @media (max-width: $breakpoint-sm) {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
