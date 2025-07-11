<script setup lang="ts">
import { TableHeader } from "~/mm_ui_kit/src/types/table.types";
import { ComputedRef, Ref, ref } from "vue";
import {
  AgreementTypeExtendedRead,
  AgreementTypeUpdate,
} from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import EditPriceDialog from "./Dialogs/EditPriceDialog.vue";
import {
  SELECT_BILLING_TYPE_OPTIONS,
  SELECT_BILLING_PERIOD_OPTIONS,
} from "./constants";
import { watch, PropType, computed } from "vue";
import { TypePricingDetails } from "~/policies/License/types";
import { DEFAULT_PRICING } from "~/policies/License/Tabs/Pricing/constants";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { useFlag } from "@unleash/proxy-client-vue";
const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  licensePricing: {
    type: Array as PropType<TypePricingDetails[]>,
    default: () => [],
  },
  agreementTypeId: {
    type: String,
    default: "",
  },
  isEditing: {
    type: Boolean,
    default: false,
  },
  isCreating: {
    type: Boolean,
    default: false,
  },
  licenseHasActiveInstances: { type: Boolean, default: false },
});

const multiplePricesEnabled = useFlag("multiple_prices");
const description = computed(() =>
  multiplePricesEnabled.value
    ? "Add one or more prices to your plan."
    : "Add a price to your plan",
);
const addNewPriceEnabled = computed(() => {
  return multiplePricesEnabled.value
    ? props.isCreating || props.isEditing
    : prices.value?.length == 0;
});
const emit = defineEmits(["update-prices", "update-edit-mode"]);
const prices: Ref<AgreementTypeExtendedRead[] | AgreementTypeUpdate[] | null> =
  ref([]);
const selectedPrice: Ref<AgreementTypeUpdate | null> = ref(null);
const isEditPriceDialogOpen: Ref<boolean> = ref(false);
const pricingTableHeaders: ComputedRef<TableHeader[]> = computed(() => [
  { key: "billing_type", label: "Pricing model" },
  { key: "billing_period_unit", label: "Billing period" },
  { key: "currency", label: "Currency" },
  { key: "amount", label: "Price" },
  { key: "description", label: "Billing description" },
  { key: "actions", label: "" },
]);
const addNewPrice = () => {
  selectedPrice.value = { ...DEFAULT_PRICING };
  isEditPriceDialogOpen.value = true;
};
const handleEditPrice = (price: AgreementTypeUpdate) => {
  selectedPrice.value = { ...price };
  isEditPriceDialogOpen.value = true;
};
const getFormattedBillingType = (billing_type: string) => {
  const selectedBillingType = SELECT_BILLING_TYPE_OPTIONS.find(
    (e) => e.value === billing_type,
  );
  return selectedBillingType?.title;
};
const pricingDescription = (row: AgreementTypeExtendedRead) =>
  row?.description || "-";
const getFormattedBillingPeriod = (row: AgreementTypeUpdate) => {
  const selectedBillingType = SELECT_BILLING_PERIOD_OPTIONS.find(
    (e) => e.value === row.billing_period_unit,
  );
  return row.billing_type === "FLAT_FEE_RECURRING" ||
    row.billing_type === "USER_BASED_RECURRING"
    ? selectedBillingType?.title || "-"
    : "-";
};
const getFormattedAmount = (row: AgreementTypeExtendedRead) =>
  convertToMainUnit(row?.amount, row.currency).formatted;

const getFormattedCurrency = (row: AgreementTypeExtendedRead) =>
  row.billing_type != "FREE" ? row?.currency : "-";

const closeDialog = () => {
  isEditPriceDialogOpen.value = false;
};

const handleUpdatePrice = (addedPrice: AgreementTypeExtendedRead) => {
  const newPricesList = prices.value ? [...prices.value] : [];

  if (!addedPrice.id) {
    newPricesList.push(addedPrice);
  } else {
    const existingIndex = newPricesList.findIndex(
      (price) => price.id === addedPrice.id,
    );

    if (existingIndex !== -1) {
      newPricesList[existingIndex] = addedPrice;
    } else {
      newPricesList.push(addedPrice);
    }
  }

  prices.value = newPricesList;
  emit("update-prices", newPricesList);
  closeDialog();
};

watch(
  () => props.licensePricing,
  () => {
    if (props.licensePricing?.length) prices.value = [...props.licensePricing];
  },
  {
    immediate: true,
  },
);
</script>
<template>
  <m-m-table
    :is-loading="false"
    :headers="pricingTableHeaders"
    :rows="prices"
    :total-rows="prices?.length"
    :description="description"
    empty-state="No prices"
    class="pricing"
    cy="table-prices"
  >
    <template #action>
      <m-m-button
        v-if="addNewPriceEnabled"
        color="primary"
        variant="outlined"
        size="small"
        prepend-icon="plus"
        class="mm-ml-auto mm-mb-10"
        data-cy="assign-policy-button"
        @click="addNewPrice"
      >
        Add price
      </m-m-button>
    </template>
    <template #billing_type="{ row }">{{
      getFormattedBillingType(row.billing_type as string)
    }}</template>
    <template #billing_period_unit="{ row }">{{
      getFormattedBillingPeriod(row as AgreementTypeUpdate)
    }}</template>
    <template #currency="{ row }">{{ getFormattedCurrency(row) }}</template>
    <template #amount="{ row }">{{ getFormattedAmount(row) }}</template>
    <template #description="{ row }">{{ pricingDescription(row) }}</template>

    <template #actions="{ row }">
      <div v-if="isEditing" class="mm-flex mm-flex-justify-end">
        <m-m-button
          cy="edit-pricing-button"
          prepend-icon="pen"
          variant="outlined"
          size="small"
          icon-size="18px"
          @click="() => handleEditPrice(row)"
        >
          Edit
        </m-m-button>
      </div>
    </template>
  </m-m-table>
  <edit-price-dialog
    v-if="isEditPriceDialogOpen"
    :is-creating="isCreating"
    :data="selectedPrice as AgreementTypeExtendedRead"
    :all-prices="prices"
    :is-open="isEditPriceDialogOpen"
    @close-dialog="closeDialog"
    @update-price="handleUpdatePrice"
  />
</template>
<style scoped lang="scss">
.pricing.mm-table {
  :deep(.mm-table-actions-cell .mm-button) {
    padding: 5px 10px;
  }
  padding: 15px 20px 20px;
}
</style>
