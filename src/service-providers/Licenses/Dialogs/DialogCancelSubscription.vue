<script setup lang="ts">
import dayjs from "dayjs";
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { billingAndInvoicingService } from "~/billing_and_invoicing/billing_and_invoicing.service";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { AgreementCancelPreviewRead } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  agreementId: {
    type: String,
    default: "",
    required: true,
  },
  serviceProviderId: {
    type: String,
    default: "",
    required: true,
  },
  isUserBasedPricing: {
    type: Boolean,
    default: false,
    required: true,
  },
  isAccessLicense: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["close", "cancel-subscription"]);

const cancellationPreviewDetails: Ref<AgreementCancelPreviewRead | null> =
  ref(null);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const isSubmitButtonDisabled: Ref<boolean> = ref(false);

const formattedDate: ComputedRef<string> = computed(() => {
  const date = cancellationPreviewDetails.value?.effective_date || new Date();
  return dayjs(date).format("D MMM YYYY");
});

const subtitle: ComputedRef<string> = computed(() => {
  const chargeMessage = `You will be charged ${
    convertToMainUnit(
      Number(cancellationPreviewDetails.value?.price?.amount),
      cancellationPreviewDetails.value?.price?.currency || "EUR",
    ).formatted
  } owed for this billing period.`;

  const cancellationMessage = `${props.isAccessLicense ? "Access license" : "Subscription"} will be cancelled effective ${formattedDate.value} at which time access will be revoked.`;

  return props.isUserBasedPricing
    ? `${cancellationMessage} ${chargeMessage}`
    : cancellationMessage;
});

const fetchCancellationPreview = async () => {
  try {
    cancellationPreviewDetails.value =
      await billingAndInvoicingService.getServiceProviderAgreementCancellationPreview(
        props.serviceProviderId,
        props.agreementId,
      );
  } catch {
    eventBus.$emit("onShowToast", {
      text: "There was an error while fetching the preview",
      status: "error",
    });
  }
};

const onSubmit = async () => {
  emit("cancel-subscription");
  isSubmitButtonDisabled.value = false;
  isSubmitButtonLoading.value = false;
};

onMounted(async () => {
  if (!props.isAccessLicense) {
    await fetchCancellationPreview();
  }
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Are you sure you want to cancel?"
    :subtitle="subtitle"
    icon="error"
    icon-color="error"
    cy="dialog-cancel-subscription"
    @close="emit('close')"
  >
    <template #footer>
      <div class="mm-flex mm-justify-flex-end mm-flex-gap-6">
        <m-m-button variant="outlined" color="gray" @click="emit('close')">
          Cancel
        </m-m-button>
        <m-m-button
          cy="button-cancel-subscription"
          variant="danger"
          :loading="isSubmitButtonLoading"
          :disabled="isSubmitButtonDisabled"
          @click="onSubmit"
        >
          Confirm
        </m-m-button>
      </div>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
