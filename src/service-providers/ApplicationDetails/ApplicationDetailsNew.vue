<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref, watch } from "vue";
import {
  NavigationGuardNext,
  onBeforeRouteLeave,
  useRoute,
  useRouter,
} from "vue-router";
import config from "~/mm.config.json";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import SettingsTab from "./Tabs/Settings/Settings.vue";
import DialogSecretSuccessfullyCreated from "./Dialogs/DialogSecretSuccessfullyCreated.vue";
import { SettingsTabComponent } from "~/service-providers/ApplicationDetails/types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { getErrorMessage } from "../_shared/helpers/configErrorMessageHelper";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";

const {
  hasUnsavedChanges,
  updateTargetPages,
  warnUnsavedChanges,
  isDialogUnsavedChangesOpen,
  doNotShowNextTime,
  confirmLeave,
  onCancelDialogUnsavedChanges,
  updateDoNotShowNextTime,
  setTextsForUnsavedChangesDialog,
} = useUnsavedChanges();

const route = useRoute();
const router = useRouter();

const openIdURL = `${config.idp.url}/.well-known/openid-configuration`;

const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
];

const currentTabName: Ref<string> = ref(TABS[0].name);

const createdApplicationId: Ref<string> = ref("");
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSaveLoading: Ref<boolean> = ref(false);
const settingsTabRef = ref<SettingsTabComponent | null>(null);
const isDialogSecretSuccessfullyCreatedOpen: Ref<boolean> = ref(false);
const secret: Ref<string> = ref("");
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const isMFARequired: Ref<boolean> = ref(false);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isConnectionConfigOpen: Ref<boolean> = ref(true);

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "applications",
    label: "Applications",
    to: "/sp/applications",
  },
  {
    id: "new-application-id",
    label: title.value,
  },
]);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || isButtonSaveDisabled.value,
);

const serviceProviderId: ComputedRef<string> = computed(
  () => `${route.params.service_provider_id}`,
);

const title = computed(
  () =>
    settingsTabRef.value?.refBasicInformation?.form?.name ||
    "Create Application",
);

const initialPayload = computed(() => ({
  name: "",
  description: "",
  url: null,
  mfa_required: false,
  redirect_uris: [],
}));

const payload = computed(() => {
  const form = {
    name: settingsTabRef.value?.refBasicInformation?.form?.name || "",
    description:
      settingsTabRef.value?.refBasicInformation?.form?.description || "",
    mfa_required: Boolean(isMFARequired.value),
    grant_type: settingsTabRef.value?.refBasicInformation?.form?.grant_type,
    redirect_uris:
      settingsTabRef.value?.refConnectionConfiguration?.form?.redirectUrl?.filter(
        (url: string) => url.length > 0,
      ),
  };

  const url = settingsTabRef.value?.refBasicInformation?.form?.url;
  form.url = !/^(https?:\/\/)?$/i.test(url) ? url : null;

  return form;
});

const createServiceProviderOauthClient = async () => {
  if (
    !settingsTabRef.value?.refBasicInformation ||
    !settingsTabRef.value?.refConnectionConfiguration
  )
    return;

  isButtonSaveDisabled.value = true;
  isButtonSaveLoading.value = true;

  try {
    const response = await oAuthClientsService.createServiceProviderOauthClient(
      serviceProviderId.value as string,
      {
        ...filterEmptyPropertiesFromObject(payload.value),
        response_type: "code",
      },
    );

    createdApplicationId.value = response.id || "";
    secret.value = response.client_secret;

    isDialogSecretSuccessfullyCreatedOpen.value = true;
    hasUnsavedChanges.value = true;
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  } finally {
    isButtonSaveDisabled.value = false;
    isButtonSaveLoading.value = false;
  }
};

const getMFARequiredStatus = (isMfaRequired: boolean) => {
  isMFARequired.value = isMfaRequired;
};

const onSubmitForm = async () => {
  if (settingsTabRef.value) {
    const basicInformationForm = settingsTabRef.value.refBasicInformation;
    const connectionConfigurationForm =
      settingsTabRef.value.refConnectionConfiguration;
    await Promise.all([
      basicInformationForm?.v$.$validate(),
      connectionConfigurationForm?.v$.$validate(),
    ]);

    const isBasicInfoInvalid = basicInformationForm?.v$.$invalid;
    const isConnectionConfigInvalid = connectionConfigurationForm?.v$.$invalid;

    if (isBasicInfoInvalid) isBasicInfoOpen.value = true;
    if (isConnectionConfigInvalid) isConnectionConfigOpen.value = true;
    if (isBasicInfoInvalid || isConnectionConfigInvalid) return;

    await createServiceProviderOauthClient();
  }
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  }
  router.push({
    name: "Applications",
  });
};

const onDialogSecretSuccessfullyCreatedClose = () => {
  isDialogSecretSuccessfullyCreatedOpen.value = false;
  hasUnsavedChanges.value = false;
  router.replace(
    `/sp/${serviceProviderId.value}/applications/${createdApplicationId.value}`,
  );
};

watch(
  () => payload.value,
  () => {
    hasUnsavedChanges.value =
      JSON.stringify(initialPayload.value) !== JSON.stringify(payload.value);
  },
);

onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value) {
    if (doNotShowNextTime.valueOf()) next();
    else {
      setTextsForUnsavedChangesDialog("leave");
      nextRef.value = next;
      updateTargetPages(from.path.toString(), to.path.toString());
      warnUnsavedChanges();
    }
  } else {
    next();
  }
});

onMounted(async () => {
  await unpublishedChangesStore.getUnpublishedConfig();
});
</script>

<template>
  <m-m-page-header
    ref="configBannerRef"
    base-key="configuration.applications.application_new.new_application"
    icon="squares-plus"
    show-ellipsis
    :params="{ title: title }"
    :breadcrumbs="breadcrumbs"
    :banner-settings="{
      showTopBanner: true,
      showTopBannerSecondary: false,
      showHeaderBanner: true,
      showFooterBanner: true,
    }"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <m-m-button
          cy="button-save"
          :is-disabled="isButtonSubmitDisabled"
          :loading="isButtonSaveLoading"
          @click="onSubmitForm"
        >
          Save
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
        <m-m-button variant="outlined" cy="button-discard" @click="onDiscard">
          Discard
        </m-m-button>
      </div>
    </template>
  </m-m-page-header>
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="currentTabName" :items="TABS" is-in-edit-mode />
  </m-m-teleport>

  <m-m-tab-items :current-tab="currentTabName">
    <m-m-tab-item keep-alive :name="TABS[0].name">
      <SettingsTab
        ref="settingsTabRef"
        :open-id-url="openIdURL"
        :service-provider-id="serviceProviderId"
        :is-expandable-basic-info-open="isBasicInfoOpen"
        :is-expandable-connection-config-open="isConnectionConfigOpen"
        mode="create"
        @get-mfa-required-status="getMFARequiredStatus"
        @update:basic-info-open="isBasicInfoOpen = $event"
        @update:connection-config-open="isConnectionConfigOpen = $event"
      />
    </m-m-tab-item>
  </m-m-tab-items>

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="confirmLeave(nextRef)"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />

  <dialog-secret-successfully-created
    :is-open="isDialogSecretSuccessfullyCreatedOpen"
    mode="app-created"
    :secret-key="secret"
    :client-id="createdApplicationId"
    @close="onDialogSecretSuccessfullyCreatedClose"
  />
</template>

<style scoped lang="scss"></style>
