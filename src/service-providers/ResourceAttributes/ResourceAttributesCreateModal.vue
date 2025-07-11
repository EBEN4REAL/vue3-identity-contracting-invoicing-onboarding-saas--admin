<script lang="ts" setup>
import { computed, ComputedRef, ref, Ref, watch } from "vue";
import { ResourceAttributeTypeCreate } from "~/policies/policies.types";
import { RESOURCE_ATTRIBUTES_FORMAT_OPTIONS } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeErrorResponse } from "~/mm_ui_kit/src/types/types";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { getErrorMessage } from "../_shared/helpers/configErrorMessageHelper";
import useVuelidate from "@vuelidate/core";
import { helpers, maxLength } from "@vuelidate/validators";
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
  serviceProviderId: { type: String, default: "" },
});

const unpublishedConfigChanges = useUnpublishedConfigChangesStore();

const isButtonSubmitLoading: Ref<boolean> = ref(false);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => props.isConfigPublishing || isButtonSaveDisabled.value,
);

const isButtonSaveDisabled: ComputedRef<boolean> = computed(
  () =>
    v$.value.$errors?.length > 0 ||
    !resourceAttributesTypes.value[0]?.name ||
    isButtonSubmitLoading.value,
);
const EMPTY_RESOURCE_ATTRIBUTE: ResourceAttributeTypeCreate = {
  name: "",
  format_option: "STRING",
};
const resourceAttributesTypes: Ref<ResourceAttributeTypeCreate[]> = ref([
  { ...EMPTY_RESOURCE_ATTRIBUTE },
]);
const formRules: ComputedRef = computed(() =>
  resourceAttributesTypes.value!.map(() => ({
    name: {
      maxLength: helpers.withMessage("Name is too long", maxLength(64)),
    },
  })),
);
const v$ = useVuelidate(formRules, resourceAttributesTypes);

const deleteResourceAttribute = (index: number) => {
  resourceAttributesTypes.value?.splice(index, 1);
};

const addResourceAttribute = () => {
  const newAttribute = { ...EMPTY_RESOURCE_ATTRIBUTE };
  resourceAttributesTypes.value?.push(newAttribute);
};

const emit = defineEmits(["close", "submit"]);

const submit = async () => {
  try {
    isButtonSubmitLoading.value = true;
    await resourceAttributeTypesService.postResourceAttributeType(
      props.serviceProviderId,
      resourceAttributesTypes.value,
    );
    eventBus.$emit("onShowToast", {
      text: "Resource Attributes created successfully",
      status: "info",
    });
    emit("close");
    emit("submit");
    unpublishedConfigChanges.getUnpublishedConfig();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err as TypeErrorResponse),
      status: "error",
    });
  } finally {
    isButtonSubmitLoading.value = false;
  }
};

watch(
  () => props.isOpen,
  () => {
    resourceAttributesTypes.value = [{ ...EMPTY_RESOURCE_ATTRIBUTE }];
  },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    size="large"
    title="Create Resource Attribute"
    subtitle="Configure your resource attribute by specifying a name and format. These attributes can be used in Filters to determine access."
    icon="resource-attributes-plus"
    cy="dialog-resource-attributes-create"
    @close="emit('close')"
  >
    <div class="mm-w-10">
      <div
        v-for="(resource, index) in resourceAttributesTypes"
        :key="index"
        class="mm-py-4 mm-flex mm-flex-col mm-w-10"
      >
        <div
          class="mm-flex mm-flex-direction-row mm-flex-align-center mm-flex-justify-center mm-w-10 mm-flex-gap-10"
        >
          <m-m-input
            v-model="resource.name"
            :errors="v$[index]?.name?.$errors"
            class="mm-w-5"
            :cy="`resource-attribute-input-${index}`"
            :label="index === 0 ? 'Name' : ''"
            placeholder="Attribute name"
            @update:model-value="v$[index]?.name?.$touch"
            @blur="v$[index]?.name?.$touch"
          />
          <div :class="`mm-mt-${index === 0 ? '12' : '2'}`">
            <m-m-icon
              icon="arrow-right"
              width="12px"
              height="14px"
              fill="#344054"
            />
          </div>
          <m-m-select
            v-model="resource.format_option"
            :items="RESOURCE_ATTRIBUTES_FORMAT_OPTIONS"
            :cy="`resource-attribute-select-${index}`"
            class="mm-w-5 format_option-select"
            :label="index === 0 ? 'Format' : ''"
          />
          <div
            v-if="resourceAttributesTypes?.length > 1"
            :class="`icon-background  mm-mt-${index === 0 ? '12' : '2'}`"
            @click="deleteResourceAttribute(index)"
          >
            <m-m-icon icon="trash2" stroke="#344054" />
          </div>
        </div>
      </div>
      <m-m-button
        size="small"
        variant="outlined"
        prepend-icon="plus"
        class="mm-mt-6"
        @click="addResourceAttribute"
      >
        Add Attribute
      </m-m-button>
    </div>
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="emit('close')">
        Cancel
      </m-m-button>
      <m-m-button
        variant="elevated"
        :disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        cy="button-submit"
        prepend-icon="plus-white"
        @click="submit"
      >
        Add
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss">
.icon-background {
  background-color: #f4f5f7;
  padding: 8px;
  border-radius: 8px;
}
</style>
