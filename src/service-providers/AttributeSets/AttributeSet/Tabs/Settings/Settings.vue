<script setup lang="ts">
import {
  PropType,
  reactive,
  ref,
  watch,
  defineEmits,
  ComputedRef,
  computed,
  toRef,
} from "vue";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import {
  TypeAttributeSetBasicInformationForm,
  TypeAttributesRead,
  TypeCreateAttributeSetBasicInformationFormRules,
  TypeValidateAttributeSetBasicInformation,
} from "~/service-providers/AttributeSets/AttributeSet/Tabs/types";
import BasicInformationRead from "../BasicInformation/BasicInformationRead.vue";
import BasicInformationEdit from "../BasicInformation/BasicInformationEdit.vue";
import TabAttributesRead from "../Attributes/AttributesRead.vue";
import TabAttributesEdit from "../Attributes/AttributesEdit.vue";
const props = defineProps({
  data: {
    type: Object as PropType<TypeAttributeSetBasicInformationForm>,
    default: () => ({}),
  },
  areAttributesReady: {
    type: Boolean,
    default: true,
  },
  attributesData: {
    type: Object as PropType<TypeAttributesRead>,
    default: () => ({}),
  },
  mode: {
    type: String as PropType<"create" | "edit">,
    default: "",
  },
  isExpandableBasicInfoOpen: {
    type: Boolean,
    default: true,
  },
  isExpandableAttributesOpen: {
    type: Boolean,
    default: true,
  },
});

const isBasicInformationOpen = toRef(props, "isExpandableBasicInfoOpen");
const isAttributesOpen = toRef(props, "isExpandableAttributesOpen");

const isInEditMode: ComputedRef<boolean> = computed(
  () => props.mode === "edit",
);
const isInCreateMode: ComputedRef<boolean> = computed(
  () => props.mode === "create",
);
const emit = defineEmits([
  "update:modelValue",
  "update:basicInfoOpen",
  "update:attributesOpen",
  "attributes-change",
]);

const form: TypeAttributeSetBasicInformationForm = reactive({
  name: "",
  description: "",
});

const formRules: TypeCreateAttributeSetBasicInformationFormRules = reactive({
  name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(256)),
  },
});

const v$: TypeValidateAttributeSetBasicInformation = useVuelidate(
  formRules,
  form,
);
const basicInformation = ref(null);
const attributes = ref(null);

const onAttributesChange = (_attributes: TypeAttributesRead) => {
  emit("attributes-change", _attributes);
};
const updateFormByField = (value: string) => {
  emit("update:modelValue", value);
};

watch(
  () => props.data,
  () => {
    form.name = props.data.name;
    form.description = props.data.description;
  },
  {
    immediate: true,
  },
);

defineExpose({
  form,
  v$,
  basicInformation,
  attributes,
});
</script>

<template>
  <div>
    <m-m-expandable-card
      title="Basic information"
      :is-opened="isBasicInformationOpen"
      :required="isInEditMode || isInCreateMode"
      @update:is-opened="emit('update:basicInfoOpen', $event)"
    >
      <basic-information-edit
        v-if="isInEditMode || isInCreateMode"
        ref="basicInformation"
        :data="data"
        @update:model-value="updateFormByField"
      />
      <basic-information-read v-else :data="data" />
    </m-m-expandable-card>

    <m-m-expandable-card
      class="mm-mt-10"
      title="Attributes"
      :is-opened="isAttributesOpen"
      :required="isInEditMode || isInCreateMode"
      @update:is-opened="emit('update:attributesOpen', $event)"
    >
      <template v-if="areAttributesReady">
        <tab-attributes-edit
          v-if="isInEditMode || isInCreateMode"
          ref="attributes"
          :data="attributesData"
          @change="onAttributesChange"
        />
        <tab-attributes-read v-else :data="attributesData" />
      </template>
    </m-m-expandable-card>
  </div>
</template>
<style scoped lang="scss">
:deep(.mm-data-iterator .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
</style>
