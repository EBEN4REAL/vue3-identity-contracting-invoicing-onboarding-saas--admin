<script lang="ts" setup>
import { computed, ComputedRef, ref, Ref } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useRouter } from "vue-router";
import { resourceTypesService } from "~/configuration/resource-types.service";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";

const router = useRouter();

const emit = defineEmits(["close", "delete"]);

const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  resourceId: {
    type: String,
    default: "",
  },
  resourceName: {
    type: String,
    default: "",
  },
});

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isButtonSubmitDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const onSubmit = async () => {
  try {
    isButtonSubmitDisabled.value = true;
    isButtonSubmitLoading.value = true;
    await resourceTypesService.deleteResourceType(
      props.serviceProviderId,
      props.resourceId,
    );
    emit("delete");
    if (isConfigNotPublished.value)
      localStorage.setItem("hideConfigBanner", "false");
    eventBus.$emit("onShowToast", {
      text: "Resource successfully deleted",
      status: "info",
    });
    router.push("/sp/config/resources");
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting resource",
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
    :title="`Delete resource ${resourceName}`"
    subtitle="Are you sure you want to delete this resource?"
    icon="trash"
    icon-color="error"
    cy="dialog-delete-resource-type"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button color="secondary" variant="outlined" @click="emit('close')">
        No
      </m-m-button>
      <m-m-button
        :is-disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        variant="danger"
        data-cy="delete-resource-submit-button"
        @click="onSubmit"
      >
        Yes, delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
