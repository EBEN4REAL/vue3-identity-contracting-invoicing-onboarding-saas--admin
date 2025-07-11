<script setup lang="ts">
import { computed, ComputedRef, PropType, reactive, ref, Ref } from "vue";
import useVuelidate from "@vuelidate/core";
import { helpers, required, url } from "@vuelidate/validators";
import { copyToClipboard } from "~/mm_ui_kit/src/helpers/copyToClipboard";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import DialogConfirmRemoveClientSecret from "../../Dialogs/DialogConfirmRemoveClientSecret.vue";
import DialogSecretSuccessfullyCreated from "../../Dialogs/DialogSecretSuccessfullyCreated.vue";
import {
  TypeApplicationConnectionConfigurationForm,
  TypeApplicationConnectionConfigurationFormRules,
} from "~/service-providers/ApplicationDetails/types";
import { OauthClientSecretCreateResponse } from "~/configuration/configuration.types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";

const translationKey =
  "configuration.applications.application_details.tab_settings.sections.connection_config.fields";

const emit = defineEmits(["application-update"]);

const props = defineProps({
  openIdUrl: {
    type: String,
    default: "",
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  mode: {
    type: String as PropType<"edit" | "create">,
    default: "",
  },
});

const REGEX_IPv4 =
  /^((https?):\/\/)?(\d+)\.(\d+)\.(\d+)\.(\d+)(:(6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]?\d{1,4}|0))?$/;
const REGEX_VALID_IPv4 =
  /^((https?):\/\/)?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(:(6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]?\d{1,4}|0))?$/;
const REGEX_LOCALHOST = /^https?:\/\/localhost(?::\d+)?(\/.*)?$/i;

const isButtonGenerateNewClientSecretDisabled: Ref<boolean> = ref(false);
const isButtonGenerateNewClientSecretLoading: Ref<boolean> = ref(false);
const isButtonConfirmRemoveClientSecretDisabled: Ref<boolean> = ref(false);
const isButtonConfirmRemoveClientSecretLoading: Ref<boolean> = ref(false);
const isDialogSecretSuccessfullyCreatedOpen: Ref<boolean> = ref(false);
const isDialogConfirmRemoveClientSecretOpen: Ref<boolean> = ref(false);
const clientSecretIdToRemove: Ref<string | null> = ref(null);
const oAuthClientCredentials: Ref<OauthClientSecretCreateResponse | null> =
  ref(null);

const isButtonRemoveClientSecretDisabled: ComputedRef<boolean> = computed(
  () => oAuthClientsService.state.oAuthClient.secrets.length < 2,
);

const isModeCreate: ComputedRef<boolean> = computed(
  () => props.mode === "create",
);

const isNotLocalhostUrl = (str: string): boolean => !REGEX_LOCALHOST.test(str);

// Form validation rules
const formRules: ComputedRef<TypeApplicationConnectionConfigurationFormRules> =
  computed(() => ({
    redirectUrl: form.redirectUrl!.map((urlStr: string) => ({
      // First, check if it's a valid IP address (even if it's part of a URL)
      validIP:
        urlStr.replace(/^https?:\/\//, "").length > 0 && // Check for user's input excluding http:// or https:// prefix
        REGEX_IPv4.test(urlStr) && // First test for is it in IP format, like 4 numbers between 3 dots and optional port...
        !REGEX_VALID_IPv4.test(urlStr) && // ...then test for IPv4 validity
        helpers.withMessage(
          "Invalid IP format",
          helpers.regex(REGEX_VALID_IPv4),
        ),
      url:
        !REGEX_IPv4.test(urlStr) && // If it's not an IP, then validate as a URL
        isNotLocalhostUrl(urlStr) && // Ensure it's not localhost
        helpers.withMessage("URL must be valid", url),
      required:
        form.redirectUrl!.length === 1 &&
        helpers.withMessage("Redirect URL is required", required),
    })),
  }));

const form: TypeApplicationConnectionConfigurationForm = reactive({
  redirectUrl: oAuthClientsService.state.oAuthClient?.authorized_redirect_uris
    ? [...oAuthClientsService.state.oAuthClient?.authorized_redirect_uris]
    : [""],
});

const v$ = useVuelidate(formRules, form);

const addRedirectURL = () => {
  form.redirectUrl?.push("");
};

const deleteRedirectURL = (index: number) => {
  form.redirectUrl?.splice(index, 1);
  v$.value.redirectUrl.$touch();
};

const copyOpenIdUrl = () => {
  copyToClipboard(props.openIdUrl);
  eventBus.$emit("onShowToast", {
    text: "Veriam open ID URL has been copied to your clipboard",
    status: "info",
  });
};

const onRemoveClientSecret = async (id: string) => {
  clientSecretIdToRemove.value = id;
  isDialogConfirmRemoveClientSecretOpen.value = true;
};

const removeClientSecret = async () => {
  try {
    isButtonConfirmRemoveClientSecretDisabled.value = true;
    isButtonConfirmRemoveClientSecretLoading.value = true;

    await oAuthClientsService.deleteServiceProviderOAuthClientSecret(
      oAuthClientsService.state.oAuthClient?.id as string,
      props.serviceProviderId as string,
      clientSecretIdToRemove.value as string,
    );

    clientSecretIdToRemove.value = null;
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  } finally {
    isButtonConfirmRemoveClientSecretDisabled.value = false;
    isButtonConfirmRemoveClientSecretLoading.value = false;
  }
};

const onDialogSecretSuccessfullyCreatedClose = () => {
  isDialogSecretSuccessfullyCreatedOpen.value = false;
};

const onDialogConfirmRemoveClientSecretClose = () => {
  isDialogConfirmRemoveClientSecretOpen.value = false;
};

const onDialogConfirmRemoveClientSecretSubmit = async () => {
  await removeClientSecret();
  isDialogConfirmRemoveClientSecretOpen.value = false;
  emit("application-update");
};

const onGenerateNewClientSecret = async () => {
  if (!oAuthClientsService.state.oAuthClient?.id) {
    eventBus.$emit("onShowToast", {
      text: `Application id is ${oAuthClientsService.state.oAuthClient?.id}`,
      status: "error",
    });

    return;
  }

  try {
    isButtonGenerateNewClientSecretDisabled.value = true;
    isButtonGenerateNewClientSecretLoading.value = true;

    oAuthClientCredentials.value =
      await oAuthClientsService.createServiceProviderOauthClientSecret(
        oAuthClientsService.state.oAuthClient?.id,
        props.serviceProviderId,
      );

    isDialogSecretSuccessfullyCreatedOpen.value = true;

    emit("application-update");
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error generating new client secret",
      status: "error",
    });
  } finally {
    isButtonGenerateNewClientSecretDisabled.value = false;
    isButtonGenerateNewClientSecretLoading.value = false;
  }
};

const onFormRedirectUrlFieldFocus = (index: number) => {
  if (!form.redirectUrl[index]) form.redirectUrl[index] = "https://";
};

defineExpose({
  v$,
  form,
});
</script>

<template>
  <div class="form-container">
    <div class="mm-flex mm-flex-row mm-w-10">
      <template v-if="isModeCreate">
        <div class="mm-w-8">
          <div class="mm-w-10">
            <m-m-field-label
              :label="$t(`${translationKey}.redirect_url.label`)"
              :tooltip-text="$t(`${translationKey}.redirect_url.label_tooltip`)"
              required
            />
            <div
              v-for="(_, index) in form.redirectUrl"
              :key="index"
              :class="`connection-config-container mm-flex ${index ? 'mm-mt-6' : ''}  mm-flex-direction-row mm-flex-align-start mm-w-10 mm-flex-gap-6`"
              tabindex="0"
            >
              <m-m-input
                v-model="form.redirectUrl[index]"
                class="mm-w-8"
                required
                :errors="v$.redirectUrl[index].$errors"
                :placeholder="$t(`${translationKey}.redirect_url.placeholder`)"
                :cy="`input-application-redirect-url-${index}`"
                @blur="v$.redirectUrl[index].$touch"
                @focus="onFormRedirectUrlFieldFocus(index)"
                @click="onFormRedirectUrlFieldFocus(index)"
              />
              <m-m-button
                v-if="form.redirectUrl?.length > 1"
                variant="tertiary"
                prepend-icon="trash-primary"
                @click="deleteRedirectURL(index)"
              />
            </div>
          </div>
          <div
            v-if="$t(`${translationKey}.redirect_url.info_text`)"
            class="mm-flex mm-flex-row mm-flex-justify-start mm-flex-align-center mm-flex-gap-2 mm-w-8 mm-mt-8"
          >
            <div class="mm-page-options-hint">
              <span
                v-sanitize-html="$t(`${translationKey}.redirect_url.info_text`)"
                class="mm-mr-2"
              ></span>
              <m-m-link
                v-if="$t(`${translationKey}.redirect_url.learn_more_url`)"
                :href="$t(`${translationKey}.redirect_url.learn_more_url`)"
                >Learn more</m-m-link
              >
            </div>
          </div>
          <m-m-button
            size="small"
            variant="outlined"
            prepend-icon="plus"
            cy="button-add-redirect-url"
            class="mm-mt-12 add-redirect-url-button"
            @click="addRedirectURL"
          >
            {{ $t(`${translationKey}.redirect_url.add_button`) }}
          </m-m-button>
        </div>

        <div
          style="align-self: flex-start"
          class="mm-flex mm-flex-column mm-flex-justify-start mm-flex-align-start mm-w-6"
        >
          <div class="mm-mb-4 mm-w-10">
            <m-m-field-label
              :label="$t(`${translationKey}.config_url.label`)"
              :tooltip-text="$t(`${translationKey}.config_url.label_tooltip`)"
            />
            <m-m-input :model-value="openIdUrl" class="mm-w-10" disabled />
          </div>
          <m-m-link
            color="blue-dim"
            text-align="left"
            class="mm-flex-grow mm-flex-shrink-0 mm-mt-2"
            @click.prevent="copyOpenIdUrl"
          >
            <m-m-icon
              icon="clipboard"
              stroke="#1c5d97"
              width="15px"
              height="15px"
              class="mm-mr-2"
              @click.prevent="copyOpenIdUrl"
            />
            <span>Veriam open ID URL</span>
          </m-m-link>
          <div
            v-if="$t(`${translationKey}.config_url.info_text`)"
            class="mm-flex mm-flex-row mm-mt-2 mm-flex-justify-start mm-flex-align-center mm-flex-gap-2"
          >
            <div class="mm-page-options-hint">
              <span
                v-sanitize-html="$t(`${translationKey}.config_url.info_text`)"
                class="mm-mr-2"
              ></span>
              <m-m-link
                v-if="$t(`${translationKey}.config_url.learn_more_url`)"
                :href="$t(`${translationKey}.config_url.learn_more_url`)"
                >Learn more</m-m-link
              >
            </div>
          </div>
        </div>
      </template>
      <template v-if="!isModeCreate">
        <div class="mm-flex mm-flex-row mm-flex-gap-16 mm-w-10">
          <div class="mm-mb-4 mm-w-10">
            <m-m-form-field
              id="client_id"
              :translation-key="translationKey"
              :model-value="oAuthClientsService.state.oAuthClient?.id"
              disabled
              type="input"
            />
          </div>

          <div
            class="mm-flex mm-flex-column mm-flex-justify-start mm-flex-align-start mm-w-10"
          >
            <m-m-form-field
              id="config_url"
              :translation-key="translationKey"
              :model-value="openIdUrl"
              disabled
              type="input"
              class="mm-mb-4 mm-w-10"
            >
              <template #helper-link>
                <m-m-link
                  color="blue-dim"
                  text-align="left"
                  class="mm-flex-grow mm-flex-shrink-0 mm-mt-2"
                  @click.prevent="copyOpenIdUrl"
                >
                  <m-m-icon
                    icon="clipboard"
                    stroke="#1c5d97"
                    width="15px"
                    height="15px"
                    class="mm-mr-2"
                    @click.prevent="copyOpenIdUrl"
                  />
                  <span>Veriam open ID URL</span>
                </m-m-link>
              </template>
            </m-m-form-field>
          </div>
        </div>
      </template>
    </div>

    <div v-if="!isModeCreate" class="mm-flex-align-start mm-w-10">
      <div class="mm-w-10">
        <m-m-field-label
          :label="$t(`${translationKey}.redirect_url.label`)"
          :tooltip-text="$t(`${translationKey}.redirect_url.label_tooltip`)"
          required
        />
        <div
          v-for="(_, index) in form.redirectUrl"
          :key="index"
          :class="`connection-config-container mm-flex ${index ? 'mm-mt-6' : ''}  mm-flex-direction-row mm-flex-align-start mm-w-10 mm-flex-gap-6`"
          tabindex="0"
        >
          <m-m-input
            v-model="form.redirectUrl[index]"
            required
            class="mm-w-4"
            :errors="v$.redirectUrl[index].$errors"
            placeholder="https://"
            :cy="`input-application-redirect-url-${index}`"
            @blur="v$.redirectUrl[index].$touch"
            @focus="onFormRedirectUrlFieldFocus(index)"
            @click="onFormRedirectUrlFieldFocus(index)"
          />
          <m-m-button
            v-if="form.redirectUrl?.length > 1"
            variant="tertiary"
            prepend-icon="trash-primary"
            @click="deleteRedirectURL(index)"
          />
        </div>
      </div>
      <div
        v-if="$t(`${translationKey}.redirect_url.info_text`)"
        class="mm-flex mm-flex-row mm-flex-justify-start mm-flex-align-center mm-flex-gap-2 mm-w-4 mm-mt-8"
      >
        <div class="mm-page-options-hint">
          <span
            v-sanitize-html="$t(`${translationKey}.redirect_url.info_text`)"
            class="mm-mr-2"
          ></span>
          <m-m-link
            v-if="$t(`${translationKey}.redirect_url.learn_more_url`)"
            :href="$t(`${translationKey}.redirect_url.learn_more_url`)"
            >Learn more</m-m-link
          >
        </div>
      </div>
      <m-m-button
        size="small"
        variant="outlined"
        prepend-icon="plus"
        cy="button-add-redirect-url"
        class="mm-mt-12 add-redirect-url-button"
        @click="addRedirectURL"
      >
        {{ $t(`${translationKey}.redirect_url.add_button`) }}
      </m-m-button>
    </div>
  </div>

  <div
    v-if="!isModeCreate"
    class="form-container mm-flex mm-flex-column mm-flex-gap-12"
    data-cy="client-secrets"
  >
    <div
      v-for="clientSecret in oAuthClientsService.state.oAuthClient?.secrets"
      :key="clientSecret.id"
      :data-cy="`client-secret-${clientSecret.id}`"
      class="mm-flex mm-flex-align-center"
    >
      <div class="client-secret-field">
        <div class="mm-page-item-label">
          {{ $t(`${translationKey}.client_secret.label`) }}
        </div>
        <m-m-formatted-date
          :raw-date="clientSecret.created_date"
          format="DD MMM YYYY HH:mm"
          :utc-offset="0"
        />
      </div>
      <m-m-button
        :is-disabled="isButtonRemoveClientSecretDisabled"
        class="button-remove-client-secret"
        variant="text"
        cy="button-remove-client-secret"
        @click="onRemoveClientSecret(clientSecret.id)"
      >
        <m-m-icon icon="trash-black" width="auto" height="auto" />
      </m-m-button>
    </div>
    <m-m-button
      :is-disabled="isButtonGenerateNewClientSecretDisabled"
      :loading="isButtonGenerateNewClientSecretLoading"
      prepend-icon="plus"
      size="small"
      variant="outlined"
      cy="button-generate-new-client-secret"
      class="mm-mr-auto"
      @click="onGenerateNewClientSecret"
    >
      {{ $t(`${translationKey}.client_secret.generate_button`) }}
    </m-m-button>
  </div>

  <dialog-secret-successfully-created
    :is-open="isDialogSecretSuccessfullyCreatedOpen"
    mode="secret-created"
    :secret-key="oAuthClientCredentials?.secret"
    :client-id="oAuthClientCredentials?.id"
    @close="onDialogSecretSuccessfullyCreatedClose"
  />

  <dialog-confirm-remove-client-secret
    :is-open="isDialogConfirmRemoveClientSecretOpen"
    :application-id="oAuthClientsService.state.oAuthClient?.id"
    :application-name="oAuthClientsService.state.oAuthClient?.name"
    :service-provider-id="serviceProviderId"
    :is-submit-button-disabled="isButtonConfirmRemoveClientSecretDisabled"
    :is-submit-button-loading="isButtonConfirmRemoveClientSecretLoading"
    @submit="onDialogConfirmRemoveClientSecretSubmit"
    @close="onDialogConfirmRemoveClientSecretClose"
  />
</template>

<style scoped lang="scss">
.button-remove-client-secret {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background-color: #f3f4f6;
  border-radius: 6px;
}

.client-secret-field {
  width: 160px;
}

.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
.info-icon {
  flex-shrink: 0;
  align-self: center;
}
</style>
