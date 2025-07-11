<script setup lang="ts">
import {
  computed,
  ComputedRef,
  nextTick,
  PropType,
  reactive,
  ref,
  Ref,
  watch,
} from "vue";
import {
  TypeApplicationBasicInformationForm,
  TypeApplicationBasicInformationFormRules,
} from "~/service-providers/ApplicationDetails/types";
import { useVuelidate } from "@vuelidate/core";
import { helpers, maxLength, required, url } from "@vuelidate/validators";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";

const translationKey =
  "configuration.applications.application_details.tab_settings.sections.basic_info.fields";

const props = defineProps({
  mode: {
    type: String as PropType<"edit" | "create">,
    default: "edit",
  },
});

const emit = defineEmits(["get-mfa-required-status"]);
const lastValue: Ref<string> = ref("");
const isDeleting: Ref<boolean> = ref(false);

const form: TypeApplicationBasicInformationForm = reactive({
  name: oAuthClientsService.state.oAuthClient?.name,
  description: oAuthClientsService.state.oAuthClient?.description,
  url: oAuthClientsService.state.oAuthClient?.url,
  grant_type: oAuthClientsService.state.oAuthClient?.grant_type,
  mfa_required: oAuthClientsService.state.oAuthClient?.mfa_required,
});

const isNotLocalhostUrl = (url: string): boolean => {
  const localhostRegex = /^https?:\/\/localhost(?::\d+)?(\/.*)?$/i;
  return !localhostRegex.test(url);
};

const formRules: ComputedRef<TypeApplicationBasicInformationFormRules> =
  computed(() => ({
    name: {
      required: helpers.withMessage("Application name is required", required),
      maxLength: helpers.withMessage(
        "Application name is too long",
        maxLength(64),
      ),
    },
    url: {
      url:
        isNotLocalhostUrl(form.url as string) &&
        !/^(https?:\/\/)$/i.test(form.url) &&
        helpers.withMessage("URL must be valid", url),
    },
    grant_type: {
      required: helpers.withMessage(
        "Type of application is required",
        required,
      ),
    },
    description: {
      required: helpers.withMessage(
        "Application description is required",
        required,
      ),
      maxLength: helpers.withMessage("Description is too long", maxLength(255)),
    },
  }));

const onUrlInput = (event: Event): void => {
  const inputElement = event.target as HTMLInputElement;
  const inputValue = inputElement.value;
  let cursorPosition: number = inputElement.selectionStart ?? 0;

  // Determine if the user is deleting characters
  const wasDeleting = isDeleting.value;

  if (inputValue.length < lastValue.value.length) {
    isDeleting.value = true;
  } else {
    isDeleting.value = false;
  }

  lastValue.value = inputValue;

  if (!inputValue) {
    form.url = "";
    return;
  }

  const isProtocolInURL = /^https?:\/\//i.test(inputValue);

  // If the user is deleting, do not add 'https://'
  if (isDeleting.value) {
    form.url = inputValue;
    return;
  }

  // If 'https://' is missing, add it
  if (!isProtocolInURL) {
    const formattedVal = wasDeleting
      ? inputValue.slice(inputValue.length - 1)
      : inputValue;
    const newValue = `https://${formattedVal}`;
    form.url = newValue;

    // Adjust the cursor position to account for the added 'https://'
    cursorPosition += 8;

    nextTick(() => {
      inputElement.setSelectionRange(cursorPosition, cursorPosition);
    });
  } else {
    form.url = inputValue;
  }
  v$.value.url.$touch();
};

const v$ = useVuelidate(formRules, form);
const onBlur = (key: string) => {
  if (v$.value[key].$dirty) v$.value[key].$touch();
};

const onFormUrlFieldFocus = () => {
  if (!form.url) form.url = "https://";
};

watch(
  () => form.mfa_required,
  (newMfaRequired) => {
    emit("get-mfa-required-status", newMfaRequired);
  },
  {
    immediate: true,
  },
);

const valueForWebsiteCheckbox = computed(() => {
  if (props.mode === "create") return "authorization_code refresh_token";
  return oAuthClientsService.state.oAuthClient?.grant_type.includes(
    "refresh_token",
  )
    ? "authorization_code refresh_token"
    : "authorization_code";
});

const valueForAPICheckbox = computed(() => {
  if (props.mode === "create") return "client_credentials refresh_token";
  return oAuthClientsService.state.oAuthClient?.grant_type.includes(
    "refresh_token",
  )
    ? "client_credentials refresh_token"
    : "client_credentials";
});
const radioGroupValues = computed(() => [
  { value: valueForWebsiteCheckbox.value, name: "option_website" },
  { value: valueForAPICheckbox.value, name: "option_api" },
]);

defineExpose({
  v$,
  form,
});
</script>

<template>
  <form
    v-mm-focus-first
    class="mm-grid mm-grid-columns-2 mm-grid-row-gap-6 mm-grid-column-gap-16 form-container"
  >
    <m-m-form-field
      id="app_name"
      v-model="form.name"
      :translation-key="translationKey"
      type="input"
      required
      :errors="v$.name.$errors"
      @blur="onBlur('name')"
      @update:model-value="v$.name.$touch"
    />

    <m-m-form-field
      id="description"
      v-model="form.description"
      :translation-key="translationKey"
      type="input"
      :errors="v$.description.$errors"
      input-mode="textarea"
      required
      @update:model-value="v$.description.$touch"
    />

    <m-m-form-field
      id="url"
      v-model="form.url"
      :translation-key="translationKey"
      type="input"
      :errors="v$.url.$errors"
      @blur="onBlur('url')"
      @input="onUrlInput($event)"
      @focus="onFormUrlFieldFocus"
      @click="onFormUrlFieldFocus"
    />

    <m-m-form-field
      id="type"
      v-model="form.grant_type"
      :translation-key="translationKey"
      type="radio-group"
      :errors="v$.grant_type.$errors"
      :radio-group-values="radioGroupValues"
    />
    <m-m-form-field
      id="required_mfa"
      :radio-model-value="form.mfa_required"
      :translation-key="translationKey"
      type="toggle-button"
      class="mm-mt-4"
      @update:model-value="form.mfa_required = $event"
    />
  </form>
</template>

<style scoped lang="scss">
.info-icon {
  flex-shrink: 0;
  align-self: left;
}
</style>
