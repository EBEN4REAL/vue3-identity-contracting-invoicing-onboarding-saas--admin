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
const submit = () => {
  emit("discardChanges");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Are you sure you want to discard your changes?"
    icon="warning"
    icon-color="error"
    cy="dialog-discard-changes"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        cy="button-cancel"
        min-width="100px"
        @click="onDialogClose"
        >No</m-m-button
      >
      <m-m-button variant="danger" cy="button-submit" @click="submit">
        Yes, discard
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
