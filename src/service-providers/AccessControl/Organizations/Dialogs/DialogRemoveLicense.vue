<script lang="ts" setup>
import { PropType, Ref, ref } from "vue";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { SPAgreementRead } from "~/service-providers/Licenses/licenses.types";
import { policiesService } from "~/service-providers/policies.service";

const props = defineProps({
  customer: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    required: true,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  license: {
    type: Object as PropType<SPAgreementRead | null>,
    default: null,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
});

const emit = defineEmits(["closeDialog", "updateLicenses"]);
const isLoading: Ref<boolean> = ref(false);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");

const onDialogClose = () => {
  emit("closeDialog");
};

const removeLicense = async () => {
  try {
    isLoading.value = true;
    await policiesService.cancelAgreements(
      props.serviceProviderId,
      props.license?.id ?? "",
    );
    emit("updateLicenses");
    onDialogClose();
    isLoading.value = false;
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = error.response.data;
    isLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Remove license"
    :subtitle="`Are you sure you want to remove this license assigned to ${customer?.organization.name}?`"
    icon="trash"
    icon-color="error"
    cy="dialog-remove-license"
    @close="onDialogClose"
  >
    <m-m-alert
      v-if="isAlertVisible"
      status="error"
      cy="allocate-license-alert"
      class="mm-mb-12"
      @close="isAlertVisible = false"
    >
      {{ alertText }}
    </m-m-alert>
    <template #footer>
      <m-m-button
        variant="outlined"
        cy="button-cancel"
        min-width="100px"
        @click="onDialogClose"
        >No</m-m-button
      >
      <m-m-button
        variant="danger"
        cy="button-submit"
        :loading="isLoading"
        @click="removeLicense"
      >
        Yes, remove
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
