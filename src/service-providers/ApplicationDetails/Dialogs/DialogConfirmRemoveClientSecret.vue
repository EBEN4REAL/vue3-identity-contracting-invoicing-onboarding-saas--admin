<script setup lang="ts">
import { computed, ComputedRef } from "vue";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  applicationId: {
    type: String,
    default: "",
  },
  applicationName: {
    type: String,
    default: "",
  },
  serviceProviderId: { type: String, default: "" },
  isSubmitButtonDisabled: { type: Boolean, default: false },
  isSubmitButtonLoading: { type: Boolean, default: false },
});

const emit = defineEmits(["close", "submit"]);

const title: ComputedRef<string> = computed(
  () =>
    `Are you sure you want to delete this client secret for ${props.applicationName}?`,
);
</script>
<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="title"
    subtitle="This client secret will not work anymore from this moment onwards."
    icon="error"
    icon-color="error"
    cy="dialog-confirm-remove-client-secret"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-delete-app"
        size="medium"
        @click="emit('close')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        variant="danger"
        data-cy="button-submit"
        @click="emit('submit')"
      >
        Yes, delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
