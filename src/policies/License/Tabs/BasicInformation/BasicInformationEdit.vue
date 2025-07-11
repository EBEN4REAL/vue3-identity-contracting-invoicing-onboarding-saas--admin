<script setup lang="ts">
import { PropType, reactive } from "vue";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import {
  TypeCreateLicenseBasicInformationFormRules,
  TypeLicenseBasicInfo,
  TypeValidatorLicenseBasicInformation,
} from "~/policies/License/types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeLicenseBasicInfo>,
    default: () => ({}),
  },
  isCurrentCategoryPlan: { type: Boolean, default: false },
  isEditMode: { type: Boolean, default: false },
});
const form: TypeLicenseBasicInfo = reactive({
  external_facing_name: props.data.external_facing_name,
  name: props.data.name,
  description: props.data.description,
  external_facing_description: props.data.external_facing_description,
});

const formRules: TypeCreateLicenseBasicInformationFormRules = reactive({
  external_facing_name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  name: {
    maxLength: helpers.withMessage("Internal name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(255)),
  },
  external_facing_description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(255)),
  },
});

const emit = defineEmits(["update:modelValue"]);

const updateFormByField = (value) => {
  emit("update:modelValue", value);
};

const onFormFieldBlur = (field: keyof TypeLicenseBasicInfo) => {
  if (form[field]) v$.value[field].$touch();
};

const v$: TypeValidatorLicenseBasicInformation = useVuelidate(formRules, form);

defineExpose({
  form,
  v$,
});
</script>

<template>
  <form
    v-mm-focus-first
    class="mm-grid mm-grid-columns-2 mm-grid-row-gap-12 mm-grid-column-gap-16"
  >
    <div>
      <m-m-input
        v-model="form.external_facing_name"
        data-cy="input-license-external-name"
        label="Name"
        label-tool-tip-text="This will be visible to your customers"
        placeholder="Customer facing name"
        required
        :errors="v$.external_facing_name.$errors"
        @blur="onFormFieldBlur('external_facing_name')"
        @input="updateFormByField($event.target.value)"
        @update:model-value="v$.external_facing_name.$touch"
      />
    </div>
    <div>
      <m-m-input
        v-model="form.name"
        data-cy="input-license-name"
        label="Reference"
        placeholder="Reference"
        label-tool-tip-text="Reference for internal use only"
        :errors="v$.name.$errors"
        @blur="v$.name.$touch"
        @input="updateFormByField($event.target.value)"
        @update:model-value="v$.name.$touch"
      />
    </div>
    <div>
      <m-m-input
        v-model="form.external_facing_description"
        data-cy="input-license-external-description"
        :placeholder="
          isCurrentCategoryPlan ? 'Description' : 'External description'
        "
        label-tool-tip-text="This will be visible to your customers"
        label="Description"
        inputmode="textarea"
        :errors="v$.external_facing_description.$errors"
        @blur="onFormFieldBlur('external_facing_description')"
        @input="updateFormByField($event.target.value)"
      />
    </div>
    <div>
      <m-m-input
        v-model="form.description"
        data-cy="input-license-description"
        label="Remarks"
        placeholder="Add a remark"
        inputmode="textarea"
        label-tool-tip-text="Remarks and notes for internal use only"
        :errors="v$.description.$errors"
        @blur="v$.description.$touch"
        @input="updateFormByField($event.target.value)"
      />
    </div>
  </form>
</template>

<style scoped lang="scss"></style>
