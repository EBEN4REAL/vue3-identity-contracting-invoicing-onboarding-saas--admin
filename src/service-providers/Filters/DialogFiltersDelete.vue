<script lang="ts" setup>
import { PropType } from "vue";
import { TypeDialogFiltersDeleteData } from "./filters.types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeDialogFiltersDeleteData>,
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
    :title="`Delete ${props.data?.filterName}`"
    subtitle="Are you sure you want to delete this filter?"
    icon="trash"
    icon-color="error"
    cy="dialog-filter-delete"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="onDialogClose"
        >No</m-m-button
      >
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
