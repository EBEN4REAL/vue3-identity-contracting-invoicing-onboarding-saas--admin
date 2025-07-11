<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { helpers, maxLength, required, url } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { authService } from "~/auth/auth.service";
import { OauthClientRead } from "~/configuration/configuration.types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";
import { TypeToastStatuses } from "~/mm_ui_kit/src/types/toast.types";
import { useApplicationRoleBasedConfigStore } from "~/stores/useApplicationRoleBasedConfigStore";
import { TypeApplicationRoleBasedFormRules } from "~/service-providers/ApplicationDetails/types";
import { TableResponse } from "~/mm_ui_kit/src/types/table.types";
import { useRoute } from "vue-router";

const route = useRoute();

const serviceProviderId: Ref<string | null> = ref(null);
const oauthClients: Ref<TableResponse<OauthClientRead>> = ref(null);
const isApplicationNameValid: Ref<boolean> = ref(false);

const applicationRoleBasedConfigStore = useApplicationRoleBasedConfigStore();

const REGEX_IPv4 =
  /^((https?):\/\/)?(\d+)\.(\d+)\.(\d+)\.(\d+)(:(6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]?\d{1,4}|0))?$/;

const REGEX_VALID_IPv4 =
  /^((https?):\/\/)?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(:(6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]?\d{1,4}|0))?$/;
const REGEX_LOCALHOST = /^https?:\/\/localhost(?::\d+)?(\/.*)?$/i;

const isNotLocalhostUrl = (str: string): boolean => !REGEX_LOCALHOST.test(str);

const isMultipleRedirectUrls: ComputedRef<boolean> = computed(
  () =>
    applicationRoleBasedConfigStore.applicationForm.redirectUrls?.length > 1,
);

const formRules: ComputedRef<TypeApplicationRoleBasedFormRules> = computed(
  () => ({
    name: {
      required: helpers.withMessage("Application name is required", required),
      maxLength: helpers.withMessage(
        "Application name is too long",
        maxLength(64),
      ),
    },
    type: {
      required: helpers.withMessage(
        "Type of application is required",
        required,
      ),
    },
    redirectUrls:
      applicationRoleBasedConfigStore.applicationForm.redirectUrls!.map(
        (urlStr: string) => ({
          validIP:
            urlStr.replace(/^https?:\/\//, "").length > 0 &&
            REGEX_IPv4.test(urlStr) &&
            !REGEX_VALID_IPv4.test(urlStr) &&
            helpers.withMessage(
              "Invalid IP format",
              helpers.regex(REGEX_VALID_IPv4),
            ),
          url:
            !REGEX_IPv4.test(urlStr) &&
            isNotLocalhostUrl(urlStr) &&
            helpers.withMessage("URL must be valid", url),
          required:
            urlStr.length < 1 &&
            helpers.withMessage("Redirect URL is required", required),
        }),
      ),
  }),
);

const v$ = useVuelidate(
  formRules,
  applicationRoleBasedConfigStore.applicationForm,
);

const onFormRedirectUrlFieldFocus = (index: number) => {
  if (!applicationRoleBasedConfigStore.applicationForm.redirectUrls[index])
    applicationRoleBasedConfigStore.$state.applicationForm.redirectUrls[index] =
      "https://";
};

const deleteRedirectURL = (index: number) => {
  applicationRoleBasedConfigStore.applicationForm.redirectUrls?.splice(
    index,
    1,
  );
  v$.value.redirectUrls.$touch();
};

const addRedirectURL = () =>
  applicationRoleBasedConfigStore.applicationForm.redirectUrls?.push("");

const validateApplication = async (): Promise<void> => {
  if (!serviceProviderId.value) {
    return;
  }
  try {
    const response = await oAuthClientsService.getServiceProviderOauthClients(
      serviceProviderId.value,
      { name: applicationRoleBasedConfigStore.applicationForm.name },
    );
    oauthClients.value = {
      ...response,
      total: response.total ?? 0,
    };
    if ((oauthClients.value?.total ?? 0) > 0) {
      isApplicationNameValid.value = false;
      showToast({
        text: "Application name already exists, use a different name",
        status: TypeToastStatuses.Warning,
        duration: 4000,
      });
    } else {
      isApplicationNameValid.value = true;
    }
  } catch (error) {
    showToast({
      text: "An error occurred while fetching list of applications",
      status: TypeToastStatuses.Error,
      duration: 7000,
    });
  }
};

const onBlur = async (key: string) => {
  if (
    key === "name" &&
    applicationRoleBasedConfigStore.applicationForm.name.length
  )
    await validateApplication();
};

const setInitialApplicationFormData = () => {
  applicationRoleBasedConfigStore.applicationForm.name =
    oAuthClientsService.state.oAuthClient?.name || "";
  applicationRoleBasedConfigStore.applicationForm.redirectUrls =
    oAuthClientsService.state.oAuthClient?.authorized_redirect_uris || [];
  applicationRoleBasedConfigStore.applicationForm.type =
    oAuthClientsService.state.oAuthClient?.grant_type.includes(
      "authorization_code",
    )
      ? "Website"
      : "API";
  applicationRoleBasedConfigStore.applicationForm.mfa_required =
    !!oAuthClientsService.state.oAuthClient?.mfa_required;
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  if (route.query.item) {
    setInitialApplicationFormData();
    v$.value.$validate();
  }
});

defineExpose({
  v$,
  isApplicationNameValid,
  validateApplication,
});
</script>

<template>
  <div class="mm-config-applications">
    <m-m-input
      v-model="applicationRoleBasedConfigStore.applicationForm.name"
      label="Application name"
      required
      placeholder="Application name"
      data-cy="input-application-name"
      class="mm-mb-10 mm-w-10"
      :errors="v$.name?.$errors"
      @blur="onBlur('name')"
      @input="v$.name.$touch"
      @update:model-value="v$.name.$touch"
    />
    <div class="mm-mt-16">
      <m-m-field-label label="Redirect URLs" required />
      <div
        v-for="(_, index) in applicationRoleBasedConfigStore.applicationForm
          .redirectUrls"
        :key="index"
        class="mm-flex mm-flex-align-center mm-flex-gap-7 mm-mt-4"
        tabindex="0"
      >
        <m-m-input
          v-model="
            applicationRoleBasedConfigStore.applicationForm.redirectUrls[index]
          "
          required
          class="mm-w-10"
          :errors="v$.redirectUrls?.[index]?.$errors"
          placeholder="https://"
          :cy="`input-application-redirect-url-${index}`"
          @input="v$.redirectUrls?.[index]?.$touch"
          @focus="onFormRedirectUrlFieldFocus(index)"
          @click="onFormRedirectUrlFieldFocus(index)"
        />
        <m-m-icon
          v-if="isMultipleRedirectUrls"
          icon="trash2"
          class="mm-cursor-pointer"
          @click="deleteRedirectURL(index)"
        />
      </div>
      <m-m-button
        variant="outlined"
        size="small"
        prepend-icon="plus"
        class="mm-mt-6"
        @click="addRedirectURL"
      >
        Add return URL
      </m-m-button>
    </div>
    <div class="mm-mt-16">
      <m-m-field-label label="Type of application" required />
      <div class="mm-flex mm-flex-row mm-flex-column-gap-16 mm-flex-wrap">
        <m-m-radiobutton
          v-model="applicationRoleBasedConfigStore.applicationForm.type"
          variant="outlined"
          cy="website-radio-button"
          name="grantType-choice"
          value="Website"
          :show-error-message="false"
          :errors="v$.type?.$errors"
        >
          <span class="label">Website</span>
        </m-m-radiobutton>
        <m-m-radiobutton
          v-model="applicationRoleBasedConfigStore.applicationForm.type"
          variant="outlined"
          cy="api-radio-button"
          name="grantType-choice"
          value="API"
          :errors="v$.type?.$errors"
        >
          <span class="label">API</span>
        </m-m-radiobutton>
      </div>
    </div>
    <div class="mm-mt-16">
      <m-m-field-label label="Require MFA on all logins" />
      <m-m-toggle-button
        v-model="applicationRoleBasedConfigStore.applicationForm.mfa_required"
      />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.mm-config-applications {
  max-width: 360px;
}
</style>
