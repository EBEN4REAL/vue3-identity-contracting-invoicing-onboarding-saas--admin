<script setup lang="ts">
const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
    required: true,
  },
  licenseName: { type: String, default: "" },
  documentId: { type: String, default: "" },
});
const emit = defineEmits(["closeDialog", "removeDocument"]);

const onCloseDialog = (): void => {
  emit("closeDialog");
};

const onSubmit = async () => {
  emit("removeDocument", props.documentId);
  emit("closeDialog");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Delete document"
    icon="warning"
    icon-color="error"
    :subtitle="`Are you sure you want to delete the legal document from ${licenseName}? `"
    cy="delete-document-dialog"
    @close="onCloseDialog"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-remove-document"
        @click="onCloseDialog"
      >
        Cancel
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-confirm-remove-document"
        @click="onSubmit"
      >
        Yes, remove
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
