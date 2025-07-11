<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { useRouter } from "vue-router";
import { authService } from "~/auth/auth.service";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import DialogDeleteLicense from "./License/Dialogs/DialogDeleteLicense.vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();
const router = useRouter();
const isLoading: Ref<boolean> = ref(true);
const serviceProviderId: Ref<string | null> = ref(null);
const licenses: Ref<TableResponse<AgreementTypePoliciesRead> | null> =
  ref(null);
const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const deleteDialogData: Ref<string> = ref("");
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const emptyState: EmptyStateType = {
  title: "Create your first plan",
  description:
    "Plans are what you sell to your customers. It can include a once-off or recurring price, legal documents and policies.",
  icon: sectionIcons["plans"],
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/subscription-management/configure-your-plans",
};
const headers: TableHeader[] = [
  {
    key: "name",
    label: "Name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "agreement_type.name",
  },
  {
    key: "external_facing_description",
    label: "Description",
  },
  {
    label: "Created date",
    key: "created_date",
    sortIcon: true,
    order: "desc",
    sortable: true,
    defaultSortItem: true,
    sortName: "agreement_type.created_date",
  },
  {
    key: "actions",
    label: "",
  },
];

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isPlanDeletable = (plan: AgreementTypePoliciesRead): boolean =>
  plan?.deletable ?? true;

const isPlanEditable = (plan: AgreementTypePoliciesRead): boolean =>
  plan?.editable ?? true;

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
      !isPlanEditable(row) ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly,
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
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    hint: isConfigPublishing.value
      ? "You cannot duplicate this plan as config is currently being published"
      : "",
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/plans/new`,
        query: { duplicateMode: "true" },
      });
      agreementTypesService.state.license = {
        ...row,
        price: {
          ...row.price,
          amount: convertToMainUnit(row.price?.amount, row.price?.currency)
            ?.amount,
        },
      };
    },
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    hint: isDeletePlanDisabled(row)
      ? deletePlanHintText(row)
      : deletePlanConfigHintText.value,
    isDisabled:
      isDeletePlanDisabled(row) ||
      isConfigPublishing.value ||
      !isPlanDeletable(row) ||
      uiStore.isSPViewerOnly,
    onClick: () => onDeletePlan(row.id),
  },
];
const isDeletePlanDisabled = (plan: AgreementTypePoliciesRead) => {
  return plan.agreements_count > 0 || plan.include_in_self_service;
};

const deletePlanHintText = (plan: AgreementTypePoliciesRead) => {
  return isDeletePlanDisabled(plan)
    ? "You cannot delete this plan as there are active instances of it."
    : null;
};

const isButtonCreatePlanDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const deletePlanConfigHintText: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this plan as config is currently being published"
    : "",
);

const onDeletePlan = (id: string) => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
  deleteDialogData.value = id;
};

const onRedirectToPlanDetails = (id: string) => {
  router.push({
    name: "PlanDetails",
    params: {
      service_provider_id: serviceProviderId.value,
      license_id: id,
    },
  });
};

const onRedirectToPlanCreate = () =>
  router.push({
    name: "PlanDetailsNew",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });

const getAgreementTypes = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || null;
    }
    const response = await agreementTypesService.getAgreementTypes(
      serviceProviderId.value as string,
      params || {
        category: "SUBSCRIPTION",
        limit: ITEMS_PER_PAGE[0],
        offset: "0",
        sort: headers[2].sortName + ":" + headers[2].order,
      },
    );
    if (response?.results?.length) {
      response?.results.forEach((plan) => {
        plan.hidden = plan?.wizard?.hidden || false;
      });
    }
    licenses.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching plans",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const onDialogDeleteLicenseClose = async () => {
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
  isConfirmDeleteDialogOpen.value = false;
};

const handleUpdateParams = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  await getAgreementTypes(params);
};
const detailedViewLink = (row: AgreementTypePoliciesRead) =>
  `/sp/${serviceProviderId.value}/plans/${row?.id}`;

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_plan",
    action: () => onRedirectToPlanCreate(),
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
  >
    <m-m-table
      :headers="headers"
      :is-loading="isLoading"
      :rows="licenses?.results"
      :total-rows="licenses?.total"
      cy="plans-table"
      show-search
      :empty-state="emptyState"
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          size="small"
          prepend-icon="plus-white"
          cy="empty-state-button-create-plan"
          :is-disabled="isButtonCreatePlanDisabled"
          @click="onRedirectToPlanCreate"
        >
          Create plan
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
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

  <m-m-config-banner />

  <DialogDeleteLicense
    :is-open="isConfirmDeleteDialogOpen"
    :license-id="deleteDialogData"
    :service-provider-id="serviceProviderId"
    route-label="Plans"
    @close-dialog="onDialogDeleteLicenseClose"
    @update-licenses="getAgreementTypes"
  />
</template>

<style scoped lang="scss"></style>
