<script setup lang="ts">
import { ComputedRef, Ref, computed, onMounted, ref } from "vue";
import DialogAddPlan from "./Dialogs/DialogAddPlan.vue";
import DialogRemovePlan from "./Dialogs/DialogRemovePlan.vue";
import { TableHeader, TableResponse } from "~/mm_ui_kit/src/types/table.types";
import {
  AgreementTypePoliciesCountAllocatedRead,
  AgreementTypeRead,
} from "../Licenses/licenses.types";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  PriceModelEnum,
  getBillingPeriod,
  getPriceModel,
} from "../billing-types";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { useUiStore } from "~/stores/useUiStore";

const props = defineProps({
  showAddLicense: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  isEditMode: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["changeLicensesList", "loadInitialLicensesList"]);
const isLoading: Ref<boolean> = ref(true);
const isDialogAddPlanOpen: Ref<boolean> = ref(false);
const isRemovePlanDialogOpen: Ref<boolean> = ref(false);
const removePlanDialogData: Ref<string> = ref("");
const licensesList: Ref<
  TableResponse<AgreementTypePoliciesCountAllocatedRead>
> = ref(null);

const headers: TableHeader[] = [
  {
    key: "self_service_order",
    label: "Order",
  },
  {
    key: "name",
    label: "Plan Name",
  },
  {
    key: "external_facing_description",
    label: "Description",
  },
  {
    key: "currency",
    label: "Currency",
  },
  {
    key: "billing_type",
    label: "Plan Pricing Model",
  },
  {
    key: "billing_period_unit",
    label: "Plan Billing Period",
  },
  {
    key: "amount",
    label: "Plan Price",
  },
  {
    key: "actions",
    label: "",
  },
];

const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const isButtonAddPlanDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const getFormattedCurrency = (row: AgreementTypePoliciesRead) =>
  row.billing_type != PriceModelEnum.FREE ? row?.price?.currency : "-";

const getFormattedAmount = (row: AgreementTypePoliciesRead) =>
  row?.price
    ? `${convertToMainUnit(row?.price?.amount, row?.price?.currency as string).formatted}`
    : row.billing_type != PriceModelEnum.FREE
      ? "-"
      : "Free";

const licenseDescription = (row: AgreementTypePoliciesRead) =>
  row.description || "-";

const licensesFiltered = computed(() => {
  return (
    licensesList.value?.results.filter(
      (item) => item.include_in_self_service,
    ) || []
  );
});

const sortByOrder = (
  list: AgreementTypePoliciesCountAllocatedRead[],
  key: string,
) => {
  return list.sort((firstItem, secondItem) => {
    const orderFirstItem = firstItem[key];
    const orderSecondItem = secondItem[key];
    return orderFirstItem - orderSecondItem;
  });
};

const handleUpdateList = async (
  data: AgreementTypePoliciesCountAllocatedRead[],
) => {
  if (!licensesList.value) {
    licensesList.value = { results: [] };
  }

  const updatedLicenses = await Promise.all(
    data.map(async (item) => {
      const existingLicense = licensesList.value!.results.find(
        (license) => license.id === item.id,
      );
      return {
        ...existingLicense,
        ...item,
        include_in_self_service: true,
      };
    }),
  );

  licensesList.value!.results = [
    ...licensesList.value!.results.filter(
      (license) => !data.some((item) => item.id === license.id),
    ),
    ...updatedLicenses,
  ];

  licensesList
    .value!.results.filter((license) => license.include_in_self_service)
    .forEach((license, index) => {
      license.self_service_order = index + 1;
    });

  licensesList.value!.results = sortByOrder(
    licensesList.value!.results,
    "self_service_order",
  );
  emit("changeLicensesList", licensesList.value!.results);
};
const handleRemoveLicense = (row: AgreementTypeRead) => {
  isRemovePlanDialogOpen.value = true;
  removePlanDialogData.value = row.id;
};

const onRemoveLicense = async (id: string) => {
  if (licensesList.value) {
    const removed = licensesList.value?.results.find((item) => item.id == id);
    if (removed) {
      removed.include_in_self_service = false;
    }
    licensesFiltered.value?.forEach((item, index) => {
      item.self_service_order = index + 1;
    });
    sortByOrder(licensesList.value?.results, "self_service_order");
    await unpublishedChangesStore.getUnpublishedConfig();
    if (isConfigNotPublished.value)
      localStorage.setItem("hideConfigBanner", "false");
    emit("changeLicensesList", licensesList.value?.results);
  }
};

const handleUpdateListOrder = (data: []) => {
  data.forEach((item, index) => {
    const itemInList = licensesList?.value?.results.find(
      (elem) => elem.id === item.id,
    );
    if (itemInList) {
      itemInList.self_service_order = index + 1;
    }
  });
  sortByOrder(licensesList.value?.results, "self_service_order");
  emit("changeLicensesList", licensesList.value?.results);
};

const detailedView = (row: AgreementTypeRead) =>
  `/sp/${props.serviceProviderId}/plans/${row?.id}`;

const getAgreementsIncludedInSelfService = async () => {
  try {
    return await agreementTypesService.getAgreementTypes(
      props.serviceProviderId as string,
      {
        limit: ITEMS_PER_PAGE[0],
        offset: "0",
        include_in_self_service: true,
        sort: "agreement_type.self_service_order:asc",
        disable_pagination: true,
      },
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

const getDropdownItems = (row: AgreementTypePoliciesCountAllocatedRead) => {
  if (props.isEditMode) {
    return [
      {
        label: "Go to Plan",
        type: "link",
        to: detailedView(row),
      },
      {
        label: "Remove Plan",
        type: "button",
        color: "error",
        onClick: () => handleRemoveLicense(row),
      },
    ];
  } else {
    return [
      {
        label: "Go to Plan",
        type: "link",
        to: detailedView(row),
      },
    ];
  }
};

const loadAllData = async () => {
  isLoading.value = true;
  try {
    licensesList.value = await getAgreementsIncludedInSelfService();
    emit("changeLicensesList", licensesList.value.results);
    emit("loadInitialLicensesList", licensesList.value.results);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  if (props.serviceProviderId) {
    loadAllData();
  }
});
</script>
<template>
  <div class="mm-flex mm-flex-justify-between">
    <div class="mm-flex mm-flex-column">
      <div class="mm-page-title mm-page-title--h2 mm-mt-8">Add Plans</div>
      <div class="mm-page-subtitle mm-page-subtitle--h2">
        You can add or remove plan here. These will show up on your pricing
        page.
      </div>
    </div>
    <div class="mm-flex mm-flex-align-end">
      <m-m-button
        v-if="isEditMode && licensesList?.results.length"
        class="mm-mt-8"
        variant="outlined"
        size="small"
        prepend-icon="plus"
        cy="button-add-plan"
        :is-disabled="isButtonAddPlanDisabled"
        @click="isDialogAddPlanOpen = true"
      >
        Add Plan
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </div>
  </div>

  <m-m-card
    v-if="!licensesList?.results.length && !isLoading"
    class="mm-mt-8"
    data-cy="empty-licenses-section"
  >
    <div class="mm-flex mm-flex-align-center mm-flex-column mm-pa-10">
      <m-m-icon icon="documents-outline" width="152" height="100" />
      <div class="mm-page-title--h4 mm-fw-600">No Plans Added</div>
      <div class="mm-page-subtitle mm-page-subtitle--h2">
        Add plans to display on your pricing page
      </div>
      <m-m-button
        v-if="showAddLicense"
        class="mm-mt-8"
        variant="outlined"
        size="small"
        prepend-icon="plus"
        cy="button-add-plan-card"
        :is-disabled="isConfigPublishing"
        @click="isDialogAddPlanOpen = true"
      >
        Add Plan
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </div>
  </m-m-card>
  <m-m-table
    v-else
    class="mm-mt-8"
    :headers="headers"
    :is-loading="isLoading"
    :rows="licensesFiltered"
    :is-draggable="isEditMode"
    cy="plans-table"
    @updated-items="handleUpdateListOrder"
  >
    <template #self_service_order="{ row }">
      <div class="mm-flex mm-flex-align-center mm-flex-gap-8">
        <m-m-icon
          v-if="isEditMode"
          icon="frame"
          width="12px"
          height="8px"
          class="draggable"
        />
        {{ row.self_service_order }}
      </div>
    </template>
    <template #name="{ row }">
      <m-m-link
        :to="detailedView(row)"
        font-weigth="500"
        :cy="`name-${row?.id}`"
      >
        {{ row.name }}
      </m-m-link>
    </template>
    <template #description="{ row }">
      {{ licenseDescription(row) }}
    </template>
    <template #currency="{ row }">{{ getFormattedCurrency(row) }}</template>
    <template #billing_type="{ row }">
      {{ row.billing_type ? getPriceModel(row.billing_type) : "-" }}
    </template>
    <template #billing_period_unit="{ row }">
      {{
        row.billing_period_unit
          ? getBillingPeriod(row.billing_period_unit)
          : "-"
      }}
    </template>
    <template #amount="{ row }">{{ getFormattedAmount(row) }}</template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown
          list-side="left"
          :items="getDropdownItems(row)"
          :cy="`actions-dropdown-${row.id}`"
          list-variant="shadow"
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
  <m-m-divider class="mm-mt-18" />
  <DialogAddPlan
    :is-open="isDialogAddPlanOpen"
    :licenses-added="
      licensesList?.results
        .filter((item) => item.include_in_self_service)
        .map((item) => item.id)
    "
    @close-dialog="isDialogAddPlanOpen = false"
    @update-list="handleUpdateList"
    @remove-item="onRemoveLicense"
  />
  <DialogRemovePlan
    :is-open="isRemovePlanDialogOpen"
    :license-id="removePlanDialogData"
    @close-dialog="isRemovePlanDialogOpen = false"
    @remove-license="onRemoveLicense"
  />
</template>
<style scoped lang="scss">
.draggable {
  cursor: move;
}
</style>
