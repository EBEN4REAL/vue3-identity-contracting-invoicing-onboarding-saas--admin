<script setup lang="ts">
import { computed, ComputedRef, PropType } from "vue";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
    required: true,
  },
  status: {
    type: String,
    default: "",
    required: true,
  },
  data: {
    type: Object as PropType<{ customer: { name: string }; status: string }>,
    default: () => ({}),
  },
});
const subtitle: ComputedRef<string> = computed(() =>
  props.data.status == "PENDING"
    ? `The subscription is pending until ${props.data.customer.name} has completed payment and/or agreed to any legal terms. They will receive an email to action this.`
    : `The subscription is active and ${props.data.customer.name} will receive an email to inform them they can start using the subscription.`,
);
const emit = defineEmits(["close"]);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Subscription created successfully"
    :subtitle="subtitle"
    icon="payment"
    icon-size="40px"
    cy="dialog-allocation-successful"
    @close="emit('close')"
  >
    <template #footer>
      <div class="mm-flex mm-justify-flex-end mm-flex-gap-6">
        <m-m-button
          cy="button-allocation-successful"
          variant="outlined-light"
          @click="emit('close')"
        >
          Okay
        </m-m-button>
      </div>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
