<script setup lang="ts">
import { PropType } from "vue";
import { AttributeSetWithAttributeTypesRead } from "~/onboarding/onboarding.types";

defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  data: {
    type: Object as PropType<AttributeSetWithAttributeTypesRead>,
    default: null,
  },
  isButtonConfirmDeleteDisabled: {
    type: Boolean,
    default: false,
  },
  isButtonConfirmDeleteLoading: {
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
    :is-open="isOpen"
    :title="`Delete ${data?.name}`"
    subtitle="Are you sure you want to delete this attribute set? "
    icon="trash"
    icon-color="error"
    cy="dialog-attribute-set-delete"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="onDialogClose">
        No
      </m-m-button>
      <m-m-button
        :is-disabled="isButtonConfirmDeleteDisabled"
        :loading="isButtonConfirmDeleteLoading"
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
