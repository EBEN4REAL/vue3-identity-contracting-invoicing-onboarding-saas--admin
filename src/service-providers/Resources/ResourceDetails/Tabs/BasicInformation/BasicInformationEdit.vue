<script setup lang="ts">
import { PropType, reactive } from "vue";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import {
  TypeCreateResourceBasicInformationFormRules,
  TypeResourceBasicInformationForm,
  TypeValidateResourceBasicInformation,
} from "~/service-providers/Resources/ResourceDetails/Tabs/types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeResourceBasicInformationForm>,
    default: () => ({}),
  },
});

const form: TypeResourceBasicInformationForm = reactive({
  name: props.data?.name || "",
  description: props.data?.description || "",
});

const formRules: TypeCreateResourceBasicInformationFormRules = reactive({
  name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(255)),
  },
});

const v$: TypeValidateResourceBasicInformation = useVuelidate(formRules, form);

defineExpose({
  form,
  v$,
});
</script>

<template>
  <div
    class="mm-grid mm-grid-columns-2 mm-grid-row-gap-12 mm-grid-column-gap-16"
  >
    <div>
      <m-m-input
        v-model="form.name"
        data-cy="input-resource-name"
        label="Resource name"
        placeholder="Resource name"
        required
        :errors="v$.name.$errors"
        @blur="v$.name.$touch"
        @update:model-value="v$.name.$touch"
      />
      <div class="mm-flex mm-flex-align-center mm-flex-gap-2 mm-mt-2">
        <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
        <span class="mm-page-options-hint">
          This is only visible internally on Veriam admin
        </span>
      </div>
    </div>
    <div>
      <m-m-input
        v-model="form.description"
        data-cy="input-resource-description"
        label="Description"
        placeholder="Add a description"
        inputmode="textarea"
        :errors="v$.description.$errors"
        @update:model-value="v$.description.$touch"
        @blur="v$.description.$touch"
      />
      <div class="mm-flex mm-flex-align-center mm-flex-gap-2">
        <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
        <span class="mm-page-options-hint">
          This is only visible internally on Veriam admin
        </span>
      </div>
    </div>
  </div>
</template>
