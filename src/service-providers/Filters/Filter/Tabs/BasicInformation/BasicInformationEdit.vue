<script setup lang="ts">
import { onMounted, PropType, reactive, ref, Ref } from "vue";
import { useRoute } from "vue-router";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  TypeFilterBasicInformationForm,
  TypeCreateFilterBasicInformationFormRules,
  TypeValidateFilterBasicInformation,
  TypeFilterBasicInformationData,
} from "~/service-providers/Filters/Filter/Tabs/types";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";

const props = defineProps({
  data: {
    type: Object as PropType<TypeFilterBasicInformationData>,
    default: () => ({}),
  },
});

const route = useRoute();
const isServiceProvider: Ref<boolean | null> = ref(false);
const serviceProviderId: Ref<string> = ref(
  route.params?.service_provider_id.toString(),
);

const form: TypeFilterBasicInformationForm = reactive({
  name: props.data.name,
  description: props.data.description,
});

const formRules: TypeCreateFilterBasicInformationFormRules = reactive({
  name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(256)),
  },
});

const v$: TypeValidateFilterBasicInformation = useVuelidate(formRules, form);

onMounted(async () => {
  const serviceProvider = await serviceProvidersService.getServiceProvider(
    serviceProviderId.value,
  );
  isServiceProvider.value = !!serviceProvider.id;
});

defineExpose({
  form,
  v$,
});
</script>

<template>
  <form
    v-mm-focus-first
    class="mm-grid mm-grid-columns-2 mm-grid-row-gap-12 mm-grid-column-gap-16 basic-information-form"
  >
    <div>
      <m-m-input
        v-model="form.name"
        data-cy="input-filter-name"
        label="Filter name"
        placeholder="Filter name"
        required
        :errors="v$.name.$errors"
        @update:model-value="v$.name.$touch"
        @blur="v$.name.$touch"
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
        data-cy="input-filter-description"
        label="Description"
        placeholder="Add a description"
        inputmode="textarea"
        :errors="v$.description.$errors"
        @blur="v$.description.$touch"
        @update:model-value="v$.description.$touch"
      />
      <div class="mm-flex mm-flex-align-center mm-flex-gap-2">
        <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
        <span class="mm-page-options-hint">
          This is only visible internally on Veriam admin
        </span>
      </div>
    </div>
  </form>
</template>

<style scoped lang="scss">
.basic-information-form {
  width: 97%;
  padding: 0 0 30px 0;
}
</style>
