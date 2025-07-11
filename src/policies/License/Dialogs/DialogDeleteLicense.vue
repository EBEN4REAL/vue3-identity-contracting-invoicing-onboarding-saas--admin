<script setup lang="ts">
import { computed, ComputedRef, Ref, ref } from "vue";
import { useRouter } from "vue-router";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  licenseId: { type: String, default: "" },
  serviceProviderId: { type: String, default: "" },
  isEditView: {
    type: Boolean,
    default: false,
  },
  routeLabel: {
    type: String,
    default: "",
  },
});

const router = useRouter();
const isDisabled: Ref<boolean> = ref(false);
const isLoading: Ref<boolean> = ref(false);
const emit = defineEmits(["closeDialog", "updateLicenses"]);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

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
    if (isConfigNotPublished.value)
      localStorage.setItem("hideConfigBanner", "false");
    isDisabled.value = false;
    isLoading.value = false;
    emit("closeDialog");
    emit("updateLicenses");
    if (props.isEditView) {
      if (props.routeLabel === "Plans") {
        router.push("/sp/plans");
      } else {
        router.push("/sp/config/access-licenses");
      }
    }
  } catch (err) {
    isDisabled.value = false;
    isLoading.value = false;
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
};

const agreementType = computed(() => {
  return props.routeLabel.toLowerCase() === "plans" ? "plan" : "license";
});
</script>
<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Delete ${agreementType}`"
    icon="trash"
    icon-color="error"
    :subtitle="`Are you sure you want to delete this ${agreementType}?`"
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
