<script lang="ts" setup>
import { Ref, ref } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: { type: String, default: "" },
  data: { type: String, default: "" },
});

const emit = defineEmits(["close", "submit"]);
const isConfirmDeleteButtonLoading: Ref<boolean> = ref(false);

const onSubmit = async () => {
  try {
    isConfirmDeleteButtonLoading.value = true;
    await legalDocumentTypesService.deleteLegalDocumentType(
      props.serviceProviderId,
      props.data,
    );
    emit("submit");
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  } finally {
    isConfirmDeleteButtonLoading.value = false;
    emit("close");
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Delete document"
    subtitle="Are you sure you want to delete the legal document? You won’t be able to get it back."
    icon="trash"
    icon-color="error"
    cy="dialog-delete-document"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        min-width="100px"
        cy="button-cancel"
        @click="emit('close')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        variant="danger"
        cy="button-submit"
        :loading="isConfirmDeleteButtonLoading"
        :is-disabled="isConfirmDeleteButtonLoading"
        @click="onSubmit"
      >
        Yes, Delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
