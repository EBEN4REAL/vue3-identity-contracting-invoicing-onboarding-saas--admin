<!-- TODO: Remove File after confirming no need for rollback -->

<script lang="ts" setup>
defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["closeDialog", "submitDialog"]);

const onDialogClose = () => {
  emit("closeDialog");
};
const submit = () => {
  emit("submitDialog");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Cancel subscription"
    subtitle="Are you sure you want to cancel this subscription?"
    icon="trash"
    icon-color="error"
    cy="dialog-cancel-subscription"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        min-width="100px"
        cy="button-cancel"
        @click="onDialogClose"
        >No</m-m-button
      >
      <m-m-button variant="danger" cy="button-submit" @click="submit">
        Yes, cancel
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
