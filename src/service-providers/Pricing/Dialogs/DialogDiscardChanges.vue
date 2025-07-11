<script lang="ts" setup>
defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["closeDialog", "discardChanges"]);

const onDialogClose = () => {
  emit("closeDialog");
};

const discardOperation = () => {
  onDialogClose();
  emit("discardChanges");
};
</script>
<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Discard Changes"
    subtitle="Are you sure you want to discard any changes?"
    icon="error"
    icon-color="error"
    cy="confirm-discard-dialog"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-discard"
        size="medium"
        @click="onDialogClose"
      >
        No
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-confirm-discard"
        @click="discardOperation"
      >
        Yes, Discard
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
