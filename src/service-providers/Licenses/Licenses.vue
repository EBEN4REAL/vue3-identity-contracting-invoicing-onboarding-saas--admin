<script setup lang="ts">
import { ComputedRef, Ref, computed, onMounted, ref } from "vue";
import { authService } from "../../auth/auth.service";
import { ITEMS_PER_PAGE } from "../../common/constants";
import { policiesService } from "../policies.service";
import {
  EmptyStateType,
  TableRequestParams,
  TableResponse,
} from "../../mm_ui_kit/src/types/table.types";
import { badgeStatus, badgeText } from "~/mm_ui_kit/src/helpers/agreementUtils";
import { SPAgreementRead } from "./licenses.types";
import { useRouter } from "vue-router";
import DialogCancelLicense from "./DialogCancelLicense.vue";
import { useFlag } from "@unleash/proxy-client-vue";
import { auditEventsService } from "~/logs/Tabs/AuditLog/audit-events.service";
import {
  AgreementMetricsRead,
  TimeBasedValuesType,
} from "~/events/events.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import DialogAllocateSubscription from "./Dialogs/DialogAllocateAgreement.vue";
import DialogAllocationSuccessful from "./Dialogs/DialogAllocationSuccessful.vue";
import { defaultSortItem } from "~/mm_ui_kit/src/helpers/defaultSortItem";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { DropdownItem } from "~/mm_ui_kit/src/types/overviewPage.types";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

// feature flags
const licenseDetailsEnabled = useFlag("license_details_page");
const router = useRouter();
const serviceProviderId: Ref<string> = ref("");
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const licenses: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
const isCancelLicenseDialogOpen: Ref<boolean> = ref(false);
const isAllocateSubscriptionDialogOpen: Ref<boolean> = ref(false);
const isSuccessfulAllocationDialogOpen: Ref<boolean> = ref(false);
const dialogCancelLicenseData: Ref<SPAgreementRead | null> = ref(null);
const allocationSuccessfulDialogData: Ref<ServiceProviderOrganizationRead | null> =
  ref(null);
const isLoading: Ref<boolean> = ref(true);
const forceRefresh: Ref<number> = ref(0);

const emptyState: EmptyStateType = {
  title: "Create your first subscription",
  description:
    "Create a new subscription based on one of the plans you have configured.",
  icon: "arrow-rounded-outline",
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/subscription-management/managing-subscriptions/create-subscriptions",
};
const metrics: Ref<AgreementMetricsRead | null> = ref(null);
const headers = [
  {
    key: "agreement_name",
    sortName: "name",
    label: "Subscription name",
    sortable: true,
    sortIcon: true,
    order: "asc",
  },
  {
    key: "service_consumer_name",
    label: "Customer",
  },
  {
    key: "created_date",
    label: "Created date",
    sortable: true,
    sortIcon: true,
    order: "desc",
    defaultSortItem: true,
  },
  {
    key: "effective_from_date",
    label: "Effective from",
    sortable: true,
    sortIcon: true,
    order: "desc",
  },
  {
    key: "valid_until",
    label: "Effective to",
  },
  {
    key: "cancelled",
    label: "Status",
    sortable: false,
    filter: {
      type: "select",
      options: [
        { label: "Active", value: "false" },
        { label: "Cancelled", value: "true" },
      ],
    },
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const activeSubscriptionsTimeBasedValues: ComputedRef<TimeBasedValuesType> =
  computed(() => ({
    startTimeValue: metrics.value?.start_date_active_agreements_count ?? 0,
    endTimeValue: metrics.value?.end_date_active_agreements_count ?? 0,
  }));

const cancelledSubscriptionsTimeBasedValues: ComputedRef<TimeBasedValuesType> =
  computed(() => ({
    startTimeValue:
      metrics.value?.cancelled_agreements_in_previous_time_period ?? 0,
    endTimeValue: metrics.value?.cancelled_agreements_in_time_period ?? 0,
  }));

const newSubscriptionsTimeBasedValues: ComputedRef<TimeBasedValuesType> =
  computed(() => ({
    startTimeValue: metrics.value?.new_agreements_in_previous_time_period ?? 0,
    endTimeValue: metrics.value?.new_agreements_in_time_period ?? 0,
  }));

const mainHeaderDropdownItems: ComputedRef<DropdownItem[]> = computed(() => [
  {
    key: "create_new_plan",
    action: onRedirectToCreateNewPlan,
  },
]);

const onRedirectToCreateNewPlan = () => {
  router.push({
    path: `/sp/${serviceProviderId.value}/plans/new`,
  });
};

const handleUpdateParams = async (params: TableRequestParams) => {
  try {
    isLoading.value = true;
    const userProfile = await authService.getProfile();
    if (serviceProviderId.value === "") {
      if (userProfile?.sp_org) {
        serviceProviderId.value = userProfile.sp_org;
      }
    }
    await getLicenses(params);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};
const handleSuccessfulAllocation = (params: TableRequestParams) => {
  try {
    handleUpdateParams(params);
  } catch (error) {
    console.error("Allocation error");
  } finally {
    isSuccessfulAllocationDialogOpen.value = true;
  }
};

const handleCancelLicenseDialog = (license: SPAgreementRead) => {
  isCancelLicenseDialogOpen.value = true;
  dialogCancelLicenseData.value = license;
};

const getLicenses = async (params?: TableRequestParams) => {
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }

  const queryParams = {
    category: "SUBSCRIPTION",
    limit: ITEMS_PER_PAGE[0],
    offset: "0",
    sort: defaultSortItem(headers),
  };
  if (params) Object.assign(queryParams, params);

  try {
    licenses.value = await policiesService.getAgreements(
      serviceProviderId.value,
      queryParams,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

const handleLicenseCancel = async (license: SPAgreementRead) => {
  await policiesService.cancelAgreements(serviceProviderId.value, license.id);
  await getLicenses();
  forceRefresh.value += 1;
  isCancelLicenseDialogOpen.value = false;
};

const detailedView = (row: SPAgreementRead) => `/sp/subscription/${row?.id}`;

const getDropdownItems = (row: SPAgreementRead) => [
  {
    isHidden: !licenseDetailsEnabled.value,
    label: "View subscription",
    type: "link",
    to: `/sp/subscription/${row.id}`,
  },
  {
    label: "Cancel subscription",
    color: "error",
    type: "button",
    isDisabled: row.cancelled === true || uiStore.isSPViewerOnly,
    onClick: () => handleCancelLicenseDialog(row),
  },
];

onMounted(async () => {
  isSPAdmin.value = (await authService.isUserSPAdmin()) === true;
  isSPEditor.value = (await authService.isUserSPEditor()) === true;
  metrics.value = await auditEventsService.getAgreementMetrics(
    serviceProviderId.value,
    "SUBSCRIPTION",
  );
});

const buttons = computed(() => [
  {
    key: "new_subscription",
    isDisabled: uiStore.isSPViewerOnly,
    action: () => (isAllocateSubscriptionDialogOpen.value = true),
  },
  {
    key: "actions_button",
    isDropdown: true,
    isOnlyIcon: true,
    isDisabled: uiStore.isSPViewerOnly,
    dropdownItems: mainHeaderDropdownItems.value,
  },
]);
</script>

<template>
  <m-m-overview-page
    resource-id="subscriptions.subscriptions"
    :buttons="buttons"
    :show-config-banner="false"
  >
    <div v-if="metrics" class="totals-card-container">
      <m-m-totals-card
        title="Active subscriptions"
        :time-based-values="activeSubscriptionsTimeBasedValues"
        tooltip-content="Current number of active subscriptions"
        more-is-positive
        cy="total-active-licenses-card"
      />
      <m-m-totals-card
        title="New subscriptions"
        more-is-positive
        :time-based-values="newSubscriptionsTimeBasedValues"
        tooltip-content="Amount sold in the last 30 days"
        cy="total-new-subscriptions-card"
      />
      <m-m-totals-card
        title="Cancelled subscriptions"
        :time-based-values="cancelledSubscriptionsTimeBasedValues"
        tooltip-content="Subscriptions cancelled in the last 30 days"
        cy="total-cancelled-subscriptions-card"
      />
    </div>
    <m-m-table
      :key="forceRefresh"
      cy="subscriptions-table"
      :is-loading="isLoading"
      :headers="headers"
      :rows="licenses?.results"
      :total-rows="licenses?.total"
      :empty-state="emptyState"
      show-search
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          prepend-icon="plus-white"
          cy="empty-state-button-new-subscription"
          variant="elevated"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="isAllocateSubscriptionDialogOpen = true"
        >
          New subscription
        </m-m-button>
      </template>
      <template #agreement_name="{ row }">
        <m-m-link
          v-if="licenseDetailsEnabled"
          :to="detailedView(row)"
          font-weigth="500"
          :cy="`name-${row?.id}`"
        >
          {{ row.agreement_name }}
        </m-m-link>
        <div v-else>
          {{ row.agreement_name }}
        </div>
      </template>
      <template #service_consumer_name="{ row }">
        <span>
          {{ row.service_consumer_name }}
        </span>
      </template>
      <template #created_date="{ row }">
        <m-m-formatted-date :raw-date="row.created_date" />
      </template>
      <template #effective_from_date="{ row }">
        <m-m-formatted-date :raw-date="row.effective_from_date" />
      </template>
      <template #valid_until="{ row }">
        <m-m-formatted-date :raw-date="row.valid_until" />
      </template>
      <template #cancelled="{ row }">
        <span>
          {{ row.status }}
        </span>
        <m-m-badge
          :status="badgeStatus(row)"
          :text="badgeText(row)"
          indicator
        />
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="getDropdownItems(row)"
            :cy="`actions-dropdown-${row.service_consumer_id}`"
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
  <DialogCancelLicense
    :is-open="isCancelLicenseDialogOpen"
    @close-dialog="isCancelLicenseDialogOpen = false"
    @submit-dialog="
      dialogCancelLicenseData && handleLicenseCancel(dialogCancelLicenseData)
    "
  />
  <DialogAllocateSubscription
    :is-open="isAllocateSubscriptionDialogOpen"
    :is-access-license="false"
    @close-dialog="isAllocateSubscriptionDialogOpen = false"
    @update-list="handleSuccessfulAllocation"
    @update-selected-customer="allocationSuccessfulDialogData = $event"
  />
  <DialogAllocationSuccessful
    v-if="isSuccessfulAllocationDialogOpen"
    :data="allocationSuccessfulDialogData"
    :is-open="isSuccessfulAllocationDialogOpen"
    @close="isSuccessfulAllocationDialogOpen = false"
  />
</template>

<style lang="scss" scoped>
.licenses-header-controls {
  display: flex;
  gap: 12px;
  align-items: end;

  @media (max-width: $breakpoint-sm) {
    flex-direction: column;
    gap: 8px;
  }
}
.totals-card-container {
  display: flex;
  flex-direction: row;
  align-items: stretch;
  justify-content: flex-start;
  gap: 24px;
  margin: 0 0 24px 0;
  @media (max-width: $breakpoint-xs) {
    flex-direction: column;
  }
}
</style>
