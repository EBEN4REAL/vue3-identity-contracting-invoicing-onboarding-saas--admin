<script setup lang="ts">
import { onMounted, PropType, reactive, ref, Ref, watch } from "vue";
import { useRoute } from "vue-router";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import {
  TypeAttributeSetBasicInformationForm,
  TypeCreateAttributeSetBasicInformationFormRules,
  TypeValidateAttributeSetBasicInformation,
} from "~/service-providers/AttributeSets/AttributeSet/Tabs/types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeAttributeSetBasicInformationForm>,
    default: () => ({}),
  },
});

const route = useRoute();
const isServiceProvider: Ref<boolean | null> = ref(false);
const serviceProviderId: Ref<string> = ref(
  route.params?.service_provider_id.toString(),
);
const emit = defineEmits(["update:modelValue"]);

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

onMounted(async () => {
  const serviceProvider = await serviceProvidersService.getServiceProvider(
    serviceProviderId.value,
  );
  isServiceProvider.value = !!serviceProvider.id;
});

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
});
</script>

<template>
  <form
    v-mm-focus-first
    class="mm-grid mm-grid-columns-2 mm-grid-row-gap-12 mm-grid-column-gap-16 attribute-set-form"
  >
    <m-m-input
      v-model="form.name"
      data-cy="input-attribute-set-name"
      label="Attribute set name"
      placeholder="Attribute set name"
      required
      :errors="v$.name.$errors"
      @blur="v$.name.$touch"
      @update:model-value="v$.name.$touch"
      @input="updateFormByField($event.target.value)"
    />
    <m-m-input
      v-model="form.description"
      data-cy="input-attribute-set-description"
      label="Description"
      placeholder="Add a description"
      inputmode="textarea"
      :errors="v$.description.$errors"
      @blur="v$.description.$touch"
      @update:model-value="v$.description.$touch"
      @input="updateFormByField($event.target.value)"
    />
  </form>
</template>

<style scoped lang="scss">
.attribute-set-form {
  width: 96%;
  margin-bottom: 16px;
  margin-right: 14px;
  margin-top: 17px;
}
</style>
