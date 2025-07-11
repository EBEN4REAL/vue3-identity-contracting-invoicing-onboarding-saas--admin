<script setup lang="ts">
import { computed, ComputedRef, Ref, ref } from "vue";
import { authService } from "~/auth/auth.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { useRouter } from "vue-router";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import DialogDeleteLicense from "../AccessControl/AccessLicense/Dialogs/DialogDeleteLicense.vue";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();
const router = useRouter();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const serviceProviderId: Ref<string> = ref("");
const isLoading: Ref<boolean> = ref(true);
const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const deleteDialogData: Ref<string> = ref("");
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);
const plans: Ref<TableResponse<AgreementTypePoliciesRead> | null> = ref(null);
const emptyState: EmptyStateType = {
  title: "Create your first plan",
  description:
    "Plans are what you sell to your customers. It can include a once-off or recurring price, legal documents and policies.",
  icon: sectionIcons["plans"],
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/subscription-management/configure-your-plans",
};
const currentTableParams: Ref<TableRequestParams> = ref({
  category: "SUBSCRIPTION",
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});

const TABLE_HEADERS: TableHeader[] = [
  {
    key: "name",
    label: "Name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "agreement_type.name",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    key: "include_in_self_service",
    label: "Available on pricing page?",
  },
  {
    label: "Created date",
    key: "created_date",
    sortIcon: true,
    order: "desc",
    sortable: true,
    sortName: "agreement_type.created_date",
    defaultSortItem: true,
  },
  {
    key: "actions",
    label: "",
  },
];

const isButtonCreatePlanDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const onRedirectToPlanDetails = (id: string) => {
  router.push({
    name: "PlanDetails",
    params: {
      service_provider_id: serviceProviderId.value,
      license_id: id,
    },
  });
};

const isDeletePlanDisabled = (plan: AgreementTypePoliciesRead) =>
  plan.agreements_count > 0 || plan.include_in_self_service;

const deletePlanHintText: ComputedRef<
  (plan: AgreementTypePoliciesRead) => string | null
> = computed(() => {
  return (plan: AgreementTypePoliciesRead): string | null => {
    if (isDeletePlanDisabled(plan)) {
      return "You cannot delete this license as there are active instances of it.";
    }
    if (isConfigPublishing.value) {
      return "You cannot delete this license as config is currently being published.";
    }
    return null;
  };
});

const onDeletePlan = (id: string) => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
  deleteDialogData.value = id;
};

const isPlanEditable = (plan: AgreementTypePoliciesRead): boolean =>
  plan?.editable ?? true;

const isPlanDeletable = (plan: AgreementTypePoliciesRead): boolean =>
  plan?.deletable ?? true;

const dropdownItems = (row: AgreementTypePoliciesRead): TypeDropdownItem[] => [
  {
    label: "View",
    type: "button",
    onClick: () => {
      onRedirectToPlanDetails(row.id);
    },
  },
  {
    label: "Edit",
    type: "button",
    isDisabled:
      !!isConfigPublishing.value ||
      uiStore.isSPViewerOnly ||
      !isPlanEditable(row),
    hint: isConfigPublishing.value
      ? "You cannot edit this plan as config is currently being published"
      : "",
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/plans/${row.id}`,
        query: { editMode: "true" },
      });
    },
  },
  {
    label: "Duplicate",
    type: "button",
    isDisabled: !!isConfigPublishing.value || uiStore.isSPViewerOnly,
    hint: isConfigPublishing.value
      ? "You cannot duplicate this plan as config is currently being published"
      : "",
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/plans/new`,
        query: { duplicateMode: "true" },
      });
      agreementTypesService.state.license = row;
    },
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    hint: deletePlanHintText.value(row),
    isDisabled:
      isDeletePlanDisabled(row) ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly ||
      !isPlanDeletable(row),
    onClick: () => onDeletePlan(row.id),
  },
];

const detailedViewLink = (row: AgreementTypePoliciesRead) =>
  `/sp/${serviceProviderId.value}/plans/${row?.id}`;

const handleUpdateParams = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  currentTableParams.value = { ...currentTableParams.value, ...params };
  await getAgreementTypes(currentTableParams.value);
};

const getAgreementTypes = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || "";
    }
    const response = await agreementTypesService.getAgreementTypes(
      serviceProviderId.value as string,
      params,
    );
    if (response?.results?.length) {
      response?.results.forEach((plan) => {
        plan.hidden = plan?.wizard?.hidden || false;
      });
    }
    plans.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const badgeStatus = (plan: AgreementTypePoliciesRead) => {
  return plan.include_in_self_service ? BadgeTypes.Active : BadgeTypes.Inactive;
};

const handleDeleteDialogClose = async () => {
  isConfirmDeleteDialogOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const onRedirectToPlanCreate = () =>
  router.push({
    name: "PlanDetailsNew",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });

const getBadgeText = (row: AgreementTypePoliciesRead) =>
  row.include_in_self_service ? "Yes" : "No";

const buttons = computed(() => [
  {
    key: "create_plan",
    action: onRedirectToPlanCreate,
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="subscriptions.plans"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
    ><template #tooltip-button="{ tooltipText }">
      <m-m-tooltip v-if="tooltipText" display-position="toLeft">
        {{ tooltipText }}
      </m-m-tooltip>
    </template>
    <m-m-table
      cy="subscriptions-plans-table"
      :is-loading="isLoading"
      :rows="plans?.results || []"
      :headers="TABLE_HEADERS"
      :total-rows="plans?.total || 0"
      show-search
      :empty-state="emptyState"
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          prepend-icon="plus-white"
          cy="empty-state-button-open-licenses"
          :is-disabled="isButtonCreatePlanDisabled"
          @click="onRedirectToPlanCreate"
        >
          Create plan
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </template>
      <template #include_in_self_service="{ row }">
        <m-m-badge :status="badgeStatus(row)" :text="getBadgeText(row)" />
      </template>
      <template #name="{ row }">
        <m-m-link
          :to="detailedViewLink(row)"
          font-weigth="500"
          :data-cy="`column-name-${row.id}`"
        >
          {{ row.external_facing_name }}
        </m-m-link>
      </template>
      <template #created_date="{ row }">
        <m-m-formatted-date
          :raw-date="row.created_date"
          format="D MMM YYYY, HH:mm"
        />
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
  <DialogDeleteLicense
    :is-open="isConfirmDeleteDialogOpen"
    :license-id="deleteDialogData"
    :service-provider-id="serviceProviderId"
    subtitle="Are you sure you want to delete this plan?"
    title="Delete plan"
    @close-dialog="handleDeleteDialogClose"
    @update-licenses="handleUpdateParams(currentTableParams)"
  />
</template>
