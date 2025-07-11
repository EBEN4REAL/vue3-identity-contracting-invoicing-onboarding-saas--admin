<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { AttributeSetWithAttributeTypesRead } from "~/onboarding/onboarding.types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  attributeSet: {
    type: Object as PropType<AttributeSetWithAttributeTypesRead>,
    default: () => ({}),
  },
  serviceProviderId: { type: String, default: "" },
});

const emit = defineEmits(["close", "submit"]);

const isButtonSubmitDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);

const subtitle: ComputedRef<string> = computed(
  () =>
    `Are you sure you want to unassign attribute set ${props.attributeSet.name} from application ${oAuthClientsService.state.oAuthClient?.name}?`,
);

const onSubmit = async () => {
  try {
    isButtonSubmitDisabled.value = true;
    isButtonSubmitLoading.value = true;

    await oAuthClientsService.deleteAttributeSetFromOAuthClient(
      props.serviceProviderId,
      oAuthClientsService.state.oAuthClient?.id as string,
      props.attributeSet.id as string,
    );

    emit("close");
    emit("submit", props.attributeSet.id);
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error removing attribute set",
      status: "error",
    });
  } finally {
    isButtonSubmitDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Unassign ${attributeSet.name}`"
    icon="error"
    icon-color="error"
    :subtitle="subtitle"
    cy="dialog-unassign-attribute-set"
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
        :is-disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        @click="onSubmit"
      >
        Yes, unassign
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
