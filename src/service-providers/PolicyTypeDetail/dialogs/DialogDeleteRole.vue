<script lang="ts" setup>
defineProps({
  name: {
    type: String,
    default: null,
  },
  isConfirmDeleteButtonSubmitDisabled: {
    type: Boolean,
    default: false,
  },
  isConfirmDeleteButtonSubmitLoading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["close", "submit"]);

const onDialogClose = () => {
  emit("close");
};
const submit = () => {
  emit("submit");
};
</script>

<template>
  <m-m-dialog
    :title="`Delete ${name}`"
    subtitle="Are you sure you want to remove this role?"
    icon="trash"
    icon-color="error"
    cy="dialog-role-delete"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="onDialogClose">
        No
      </m-m-button>
      <m-m-button
        :is-disabled="isConfirmDeleteButtonSubmitDisabled"
        :loading="isConfirmDeleteButtonSubmitLoading"
        variant="danger"
        cy="button-submit"
        @click="submit"
      >
        Yes, delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
