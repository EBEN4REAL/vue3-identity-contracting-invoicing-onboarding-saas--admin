<script lang="ts" setup>
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { ResourceAttributeTypeRead } from "~/policies/policies.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";

const props = defineProps({
  data: {
    type: Object as PropType<ResourceAttributeTypeRead>,
    default: null,
  },
  isConfigPublishing: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["close", "submit"]);

const unpublishedConfigChanges = useUnpublishedConfigChangesStore();

const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(() =>
  Boolean(props.isConfigPublishing || isButtonSaveDisabled.value),
);

const submit = async () => {
  try {
    isButtonSaveDisabled.value = true;
    isButtonSubmitLoading.value = true;
    await resourceAttributeTypesService.deleteResourceAttributeType(
      props.data.service_provider_id,
      props!.data!.id as string,
    );
    emit("submit");
    emit("close");
    unpublishedConfigChanges.getUnpublishedConfig();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting resource attribute",
      status: "error",
    });
  } finally {
    isButtonSaveDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :title="`Delete ${props.data?.name}`"
    subtitle="Are you sure you want to delete this resource attribute?"
    icon="trash"
    icon-color="error"
    cy="dialog-resource-attribute-delete"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="emit('close')">
        No
      </m-m-button>
      <m-m-button
        variant="danger"
        cy="button-submit"
        :is-disabled="isButtonSubmitDisabled"
        @click="submit"
      >
        Yes, Delete
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
