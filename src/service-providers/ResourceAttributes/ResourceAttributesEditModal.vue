<script lang="ts" setup>
import { ref, Ref, PropType, computed, ComputedRef } from "vue";
import { ResourceAttributeTypeRead } from "~/policies/policies.types";
import { watch } from "vue";
import { RESOURCE_ATTRIBUTES_FORMAT_OPTIONS } from "../../common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  isConfigPublishing: {
    type: Boolean,
    default: false,
  },
  selectedResourceAttribute: {
    type: Object as PropType<ResourceAttributeTypeRead>,
    default: () => {},
  },
  serviceProviderId: { type: String, default: "" },
});

const unpublishedConfigChanges = useUnpublishedConfigChangesStore();

const initialResourceAttributeType: Ref<ResourceAttributeTypeRead | null> =
  ref(null);

const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(() =>
  Boolean(
    props.isConfigPublishing ||
      isButtonSaveDisabled.value ||
      !initialResourceAttributeType.value!.name,
  ),
);

const emit = defineEmits(["close", "submit"]);

const formIsUnchanged = computed(
  () =>
    JSON.stringify(props.selectedResourceAttribute) ===
    JSON.stringify(initialResourceAttributeType.value),
);

const submit = async () => {
  try {
    isButtonSaveDisabled.value = true;
    isButtonSubmitLoading.value = true;
    await resourceAttributeTypesService.patchResourceAttributeType(
      props.selectedResourceAttribute.service_provider_id as string,
      { ...initialResourceAttributeType.value },
    );
    emit("close");
    emit("submit");
    unpublishedConfigChanges.getUnpublishedConfig();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error updating resource attribute",
      status: "error",
    });
  } finally {
    isButtonSaveDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

watch(
  () => props.selectedResourceAttribute,
  () => {
    initialResourceAttributeType.value = { ...props.selectedResourceAttribute };
  },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    size="large"
    title="Edit Resource Attribute"
    subtitle="Configure your resource attribute by specifying a name and format. These attributes can be used in Filters to determine access."
    icon="resource-attributes"
    cy="dialog-resource-attributes-create"
    @close="emit('close')"
  >
    <div class="mm-w-10">
      <div
        class="mm-flex mm-flex-direction-row mm-flex-align-center mm-flex-justify-center mm-w-10 mm-flex-gap-10"
      >
        <m-m-input
          v-model="initialResourceAttributeType!.name"
          class="mm-w-5"
          cy="resource-attribute-input-name"
          label="Name"
          placeholder="Enter Attribute Name"
        />
        <div class="mm-mt-12">
          <m-m-icon
            icon="arrow-right"
            width="12px"
            height="14px"
            fill="#344054"
          />
        </div>
        <m-m-select
          v-model="initialResourceAttributeType!.format_option"
          :items="RESOURCE_ATTRIBUTES_FORMAT_OPTIONS"
          :cy="`resource-attribute-select-format`"
          class="mm-w-5 format_option-select"
          label="Format"
        />
      </div>
    </div>
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="emit('close')">
        Cancel
      </m-m-button>
      <m-m-button
        :disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        variant="elevated"
        :is-disabled="formIsUnchanged"
        cy="button-submit"
        @click="submit"
      >
        Save Changes
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
