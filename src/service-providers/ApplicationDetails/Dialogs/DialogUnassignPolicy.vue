<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { policiesService } from "~/service-providers/policies.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  applicationId: {
    type: String,
    default: "",
  },
  applicationName: {
    type: String,
    default: "",
  },
  policyId: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["close", "update"]);

const isSubmitButtonDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);

const subtitle: ComputedRef<string> = computed(
  () => `Are you sure you want to remove this from ${props.applicationName}?`,
);
const onSubmit = async () => {
  isSubmitButtonDisabled.value = true;
  isSubmitButtonLoading.value = true;
  try {
    await policiesService.unassignPolicyType(
      props.serviceProviderId,
      props.applicationId,
      props.policyId,
    );
    emit("update");
    emit("close");
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error unassigning policy",
      status: "error",
    });
  } finally {
    isSubmitButtonDisabled.value = false;
    isSubmitButtonLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Remove policy"
    :subtitle="subtitle"
    icon="error"
    icon-color="error"
    cy="dialog-unassign-policies"
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
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        cy="button-submit"
        variant="danger"
        @click="onSubmit"
      >
        Yes, remove
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
