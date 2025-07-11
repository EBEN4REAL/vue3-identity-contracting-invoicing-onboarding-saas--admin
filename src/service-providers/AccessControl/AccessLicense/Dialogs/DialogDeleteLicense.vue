<script setup lang="ts">
import { Ref, ref } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { agreementTypesService } from "~/configuration/agreement-types.service";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  licenseId: { type: String, default: "" },
  subtitle: {
    type: String,
    default: "Are you sure you want to delete this license?",
  },
  title: { type: String, default: "Delete License" },
  serviceProviderId: { type: String, default: "" },
});

const isDisabled: Ref<boolean> = ref(false);
const isLoading: Ref<boolean> = ref(false);
const emit = defineEmits(["closeDialog", "updateLicenses"]);

const onDialogClose = () => {
  emit("closeDialog");
};

const onSubmitDeleteLicense = async () => {
  try {
    isDisabled.value = true;
    isLoading.value = true;
    await agreementTypesService.deleteAgreementType(
      props.serviceProviderId,
      props.licenseId,
    );
    isDisabled.value = false;
    isLoading.value = false;
    emit("closeDialog");
    emit("updateLicenses");
  } catch (err) {
    isDisabled.value = false;
    isLoading.value = false;
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
};
</script>
<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="title"
    icon="trash"
    icon-color="error"
    :subtitle="subtitle"
    cy="confirm-delete-license"
    @close="onDialogClose"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-delete-license"
        @click="onDialogClose"
      >
        Cancel
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-confirm-delete-license"
        :is-disabled="isDisabled"
        :loading="isLoading"
        @click="onSubmitDeleteLicense"
      >
        Delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
<style scoped lang="scss"></style>
