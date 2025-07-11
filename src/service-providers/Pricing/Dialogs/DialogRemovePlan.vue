<script setup lang="ts">
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
    required: true,
  },
  licenseId: { type: String, default: "" },
});
const emit = defineEmits(["closeDialog", "removeLicense"]);

const onCloseDialog = (): void => {
  emit("closeDialog");
};

const onSubmit = async () => {
  emit("removeLicense", props.licenseId);
  emit("closeDialog");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Remove Plan"
    icon="warning"
    icon-color="error"
    subtitle="Are you sure you want to remove this plan from your pricing page?"
    cy="remove-plan-dialog"
    @close="onCloseDialog"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-remove-plan"
        @click="onCloseDialog"
      >
        Cancel
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-confirm-remove-plan"
        @click="onSubmit"
      >
        Yes, Remove
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
