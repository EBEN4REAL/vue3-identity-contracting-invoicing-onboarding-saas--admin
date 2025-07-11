<script setup lang="ts">
const props = defineProps({
  policyId: {
    type: String,
    required: true,
    default: "",
  },
  isOpen: {
    type: Boolean,
    default: false,
    required: true,
  },
  isOptional: {
    type: Boolean,
    default: false,
    required: true,
  },
});
const emit = defineEmits([
  "removeDefaultPolicy",
  "removeOptionalPolicy",
  "closeDialog",
]);

const onRemoveDefaultPolicy = (): void => {
  emit("removeDefaultPolicy");
};
const onRemoveOptionalPolicy = (): void => {
  emit("removeOptionalPolicy");
};
const onCloseDialog = (): void => {
  emit("closeDialog");
};

const removeAction = (): void => {
  if (props.isOptional) {
    onRemoveOptionalPolicy();
  } else {
    onRemoveDefaultPolicy();
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Remove policy"
    icon="warning"
    icon-color="error"
    :subtitle="`Are you sure you want to remove the policy? `"
    cy="confirm-remove-policy"
    @close="onCloseDialog"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-delete-policy"
        @click="onCloseDialog"
      >
        No
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-confirm-delete-policy"
        @click="removeAction"
      >
        Yes, remove
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
