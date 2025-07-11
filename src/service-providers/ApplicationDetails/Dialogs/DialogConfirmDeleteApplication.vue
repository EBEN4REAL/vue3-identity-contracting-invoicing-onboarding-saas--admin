<script setup lang="ts">
import { PropType, Ref, ref } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { OauthClientRead } from "~/configuration/configuration.types";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: { type: String, default: "" },
  application: {
    type: Object as PropType<OauthClientRead | null>,
    default: null,
  },
});

const emit = defineEmits(["close", "submit"]);

const isSubmitButtonDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);

const onSubmit = async () => {
  try {
    isSubmitButtonDisabled.value = true;
    isSubmitButtonLoading.value = true;
    await oAuthClientsService.deleteServiceProviderOauthClient(
      oAuthClientsService.state.oAuthClient?.id as string,
      props.serviceProviderId as string,
    );
    emit("close");
    emit("submit");
  } catch {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
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
    :title="`Delete ${oAuthClientsService.state.oAuthClient?.name || application?.name}`"
    icon="error"
    icon-color="error"
    subtitle="Are you sure you want to delete this application? This will affect the end users who have access to this application."
    cy="dialog-confirm-delete-application"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel"
        size="medium"
        @click="emit('close')"
      >
        No
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-submit"
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        @click="onSubmit"
      >
        Yes, delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
