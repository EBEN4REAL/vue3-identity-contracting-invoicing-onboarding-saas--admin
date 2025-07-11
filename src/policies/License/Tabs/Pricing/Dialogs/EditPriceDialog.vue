<script setup lang="ts">
import useVuelidate from "@vuelidate/core";
import { helpers, maxLength, numeric, required } from "@vuelidate/validators";
import {
  computed,
  ComputedRef,
  onMounted,
  PropType,
  reactive,
  Ref,
  ref,
} from "vue";
import EuroFlagPath from "~/mm_ui_kit/src/assets/images/euro.png";
import {
  AgreementTypeExtendedRead,
  AgreementTypeUpdate,
  PriceRead,
  TypeEditPriceFormRules,
  TypeValidatorEditPrice,
} from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { SELECT_BILLING_TYPE_OPTIONS } from "../constants";
import { useFlag } from "@unleash/proxy-client-vue";
import { EnumBillingPeriod, TypeBillingPeriod } from "~/policies/License/types";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import {
  convertToMainUnit,
  convertToSubUnit,
} from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
const props = defineProps({
  data: {
    type: Object as PropType<AgreementTypeUpdate>,
    default: () => {},
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  isCreating: {
    type: Boolean,
    default: false,
  },
  allPrices: {
    type: Array as PropType<PriceRead[]>,
    default: () => [],
  },
});

const loading = ref(false);
const emit = defineEmits(["closeDialog", "updatePrice"]);
const userBasedEnabled = useFlag("user_based_billing");

const billingPeriodValue: Ref<TypeBillingPeriod> = ref({
  title: "Monthly",
  value: EnumBillingPeriod.Month,
});

const billingPeriodOptions: TypeBillingPeriod[] = [
  { title: "Monthly", value: EnumBillingPeriod.Month },
  { title: "Annually", value: EnumBillingPeriod.Year },
];

const form: Ref<AgreementTypeUpdate | null> = ref(null);

const formRules: TypeEditPriceFormRules = reactive({
  amount: {
    required: helpers.withMessage("Price is required", required),
    numeric: helpers.withMessage("Only numbers allowed", numeric),
  },
  description: {
    required: helpers.withMessage("Description is required", required),
    maxLength: helpers.withMessage("Description too long", maxLength(255)),
  },
});

const v$: TypeValidatorEditPrice = useVuelidate(formRules, form);

const modalTitle: ComputedRef<string> = computed(() =>
  props.isCreating ? "Add price" : "Edit price",
);
const isFlatFeeRecurring: ComputedRef<boolean> = computed(
  () => form.value?.billing_type === "FLAT_FEE_RECURRING",
);
const isUserBasedRecurring: ComputedRef<boolean> = computed(
  () => form.value?.billing_type === "USER_BASED_RECURRING",
);
const displayFormFields: ComputedRef<boolean> = computed(
  () => form.value?.billing_type !== "FREE",
);
const isFormInvalid: ComputedRef<boolean> = computed(
  () =>
    !(
      form.value?.amount > 0 &&
      form.value?.description &&
      form.value?.description?.length > 0
    ),
);
const isSaveDisabled: ComputedRef<boolean> = computed(
  () => isFormInvalid.value && form.value?.billing_type != "FREE",
);
const label = computed(() => {
  return isUserBasedRecurring.value ? "Price per user" : "Price";
});

const labelProps = computed(() => {
  return {
    labelIconAppended: isUserBasedRecurring.value ? "info" : "",
    tooltipText: isUserBasedRecurring.value
      ? "Price per user. Pro-rata charges will apply."
      : "",
  };
});

const onDialogClose = () => {
  emit("closeDialog");
};
const resetForm = () => {
  v$.value.$reset();
};
const submit = () => {
  const { billing_type, amount, description, id, currency } = form.value;
  const formattedPrice: AgreementTypeExtendedRead = {
    billing_type,
    billing_period_unit:
      isFlatFeeRecurring.value || isUserBasedRecurring.value
        ? billingPeriodValue.value.value
        : null,
    billing_period_length:
      isFlatFeeRecurring.value || isUserBasedRecurring.value ? 1 : null,
    amount: convertToSubUnit(amount, currency).amount,
    currency,
    description: billing_type === "FREE" ? null : description,
    id: id || crypto.randomUUID(),
  };

  const isNewPrice = !props.allPrices.some(
    (price) => price.id === formattedPrice.id,
  );
  const billingTypeExists = props.allPrices.some(
    (price) => price.billing_type === billing_type,
  );

  if (isNewPrice && billingTypeExists) {
    eventBus.$emit("onShowToast", {
      text: "Cannot add multiple prices with the same pricing model.",
      status: "error",
    });
    return;
  }
  emit("updatePrice", formattedPrice);
};

const filteredBillingTypeOptions = computed(() => {
  if (userBasedEnabled.value) {
    return SELECT_BILLING_TYPE_OPTIONS;
  } else {
    return SELECT_BILLING_TYPE_OPTIONS.filter(
      (option) => option.value !== "USER_BASED_RECURRING",
    );
  }
});

onMounted(() => {
  form.value = {
    ...props.data,
    amount: convertToMainUnit(props.data.amount, props.data.currency).amount,
  };
});
</script>
<template>
  <div>
    <m-m-dialog
      v-if="form"
      size="small"
      :is-open="isOpen"
      :title="modalTitle"
      icon="credit-card"
      cy="dialog-edit-price"
      @close="onDialogClose"
    >
      <template #default>
        <form v-mm-focus-first class="mm-page-dialog-form mm-mt-10">
          <div class="form-fields">
            <m-m-select
              v-model="form.billing_type"
              cy="select-billing-type"
              :items="filteredBillingTypeOptions"
              label="Pricing model"
              placeholder="Select"
              @update:model-value="resetForm"
            >
              <template #selected-option="{ value }">
                <m-m-badge
                  v-if="value === 'FLAT_FEE_RECURRING' || value === 'ONCE_OFF'"
                  class="mm-ml-3"
                  :status="BadgeTypes.Invited"
                  text="Billed in advance"
                  cy="badge-added"
                />
                <m-m-badge
                  v-if="value === 'USER_BASED_RECURRING'"
                  class="mm-ml-3"
                  :status="BadgeTypes.Invited"
                  text="Billed in arrears"
                  cy="badge-added"
                />
              </template>
            </m-m-select>
            <template v-if="displayFormFields">
              <m-m-multiselect
                v-if="isFlatFeeRecurring || isUserBasedRecurring"
                v-model="billingPeriodValue"
                label="Billing period"
                placeholder="Select billing period"
                :searchable="false"
                :options="billingPeriodOptions"
              />
              <m-m-input label="Currency" disabled placeholder="EUR">
                <template #prepended-icon>
                  <img
                    id="euro-prepended-icon"
                    :src="EuroFlagPath"
                    alt="Uploaded Logo"
                  />
                </template>
              </m-m-input>

              <div>
                <m-m-input
                  v-model="form.amount"
                  :label="label"
                  required
                  icon-prepended="euro"
                  :label-icon-appended="labelProps.labelIconAppended"
                  :label-tool-tip-text="labelProps.tooltipText"
                  placeholder="0.00"
                  type="number"
                  inputmode="numeric"
                  :errors="v$?.amount.$errors"
                  cy="billing-price"
                  @blur="v$?.amount.$touch"
                  @update:model-value="v$?.amount.$touch"
                />
              </div>

              <div>
                <m-m-input
                  v-model="form.description"
                  :errors="v$.description.$errors"
                  inputmode="textarea"
                  text-area-height="88px"
                  cy="billing-description"
                  label="Billing description"
                  required
                  placeholder="Add a description"
                  @blur="v$.description.$touch"
                  @update:model-value="v$.description.$touch"
                />
                <div class="info mm-flex mm-flex-align-center mm-gap-1">
                  <m-m-icon icon="small-info" />
                  <div class="description-information mm-mb-4">
                    This is visible to your customers on invoices. Max 150
                    character limit
                  </div>
                </div>
              </div>
            </template>
          </div>
        </form>
      </template>
      <template #footer>
        <m-m-button variant="outlined" cy="button-cancel" @click="onDialogClose"
          >Cancel</m-m-button
        >
        <m-m-button
          variant="elevated"
          cy="button-submit"
          :loading="loading"
          :is-disabled="isSaveDisabled"
          @click="submit"
        >
          Save
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
<style scoped lang="scss">
.form-fields {
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.description-information {
  font-weight: 400;
  font-size: 14px;
  line-height: 20px;
  color: #6d7480;
}
:deep(.mm-input-icon-prepended + .mm-input-control) {
  padding-left: 30px !important;
}
:deep(.mm-input-icon-prepended) {
  margin-top: 13px;
  margin-left: 5px;
}
</style>
