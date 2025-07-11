<script setup lang="ts">
import {
  computed,
  ComputedRef,
  onMounted,
  onUnmounted,
  ref,
  Ref,
  watch,
} from "vue";
import {
  NavigationGuardNext,
  onBeforeRouteLeave,
  useRoute,
  useRouter,
} from "vue-router";
import config from "~/mm.config.json";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import DialogConfirmDeleteApplication from "./Dialogs/DialogConfirmDeleteApplication.vue";
import SettingsTab from "./Tabs/Settings/Settings.vue";
import PoliciesTab from "./Tabs/Policies/Policies.vue";
import { SettingsTabComponent } from "~/service-providers/ApplicationDetails/types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { getErrorMessage } from "../_shared/helpers/configErrorMessageHelper";
import { OauthClientUpdate } from "~/configuration/configuration.types";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { useTranslation } from "i18next-vue";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

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

const { t } = useTranslation();

const router = useRouter();
const route = useRoute();

const openIdURL = `${config.idp.url}/.well-known/openid-configuration`;
const TABS: TypeTab[] = [
  {
    label: t(
      "configuration.applications.application_details.tab_settings.title",
    ),
    name: t(
      "configuration.applications.application_details.tab_settings.title",
    ),
    isRequired: false,
  },
  {
    label: t(
      "configuration.applications.application_details.tab_policies.title",
    ),
    name: t(
      "configuration.applications.application_details.tab_policies.title",
    ),
    isRequired: false,
  },
];

const currentTabName: Ref<string> = ref(TABS[0].name);

const isInEditMode = ref(Boolean(route.query.editMode));
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSaveLoading: Ref<boolean> = ref(false);
const isDialogConfirmDeleteOpen: Ref<boolean> = ref(false);
const settingsTabRef = ref<SettingsTabComponent | null>(null);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isConnectionConfigOpen: Ref<boolean> = ref(true);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const uiStore = useUiStore();

const scrimmedClass: ComputedRef<string> = computed(() =>
  oAuthClientsService.state.oAuthClient?.wizard?.hidden ? "mm-opacity-40" : "",
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () =>
    isConfigPublishing.value ||
    isButtonSaveDisabled.value ||
    uiStore.isSPViewerOnly,
);

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "applications",
    label: "Applications",
    to: "/sp/applications",
  },
  {
    id: oAuthClientsService.state.oAuthClient?.id || "application-id",
    label: oAuthClientsService.state.oAuthClient?.name || "",
  },
]);

const dropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => {
  const items = [
    {
      label: t("configuration.applications.application_details.actions.delete"),
      color: "error",
      type: "button",
      isDisabled:
        isConfigPublishing.value ||
        !isApplicationDeletable.value ||
        uiStore.isSPViewerOnly,
      hint: isConfigPublishing.value
        ? "You cannot delete this application as config is currently being published"
        : "",
      onClick: () => {
        onOpenDialogConfirmDelete();
      },
    },
  ];
  if (isInEditMode.value)
    items.push({
      label: t(
        "configuration.applications.application_details.actions.discard",
      ),
      type: "button",
      color: "black",
      hint: "",
      isDisabled: false,
      onClick: () => {
        onDiscard();
      },
    });
  return items;
});

const serviceProviderId: ComputedRef<string> = computed(
  () => `${route.params.service_provider_id}`,
);

const title: ComputedRef<string> = computed(
  () => oAuthClientsService.state.oAuthClient?.name || "",
);
const subtitle: ComputedRef<string> = computed(
  () => oAuthClientsService.state.oAuthClient?.description || "",
);
const payload: ComputedRef<OauthClientUpdate> = computed(() => {
  const form = {
    name: settingsTabRef.value?.refBasicInformation?.form?.name || "",
    description: settingsTabRef.value?.refBasicInformation?.form?.description,
    grant_type: settingsTabRef.value?.refBasicInformation?.form?.grant_type,
    redirect_uris:
      settingsTabRef.value?.refConnectionConfiguration?.form.redirectUrl,
    mfa_required:
      settingsTabRef.value?.refBasicInformation?.form?.mfa_required || false,
  };

  const url = settingsTabRef.value?.refBasicInformation?.form?.url;
  form.url = !/^(https?:\/\/)?$/i.test(url) ? url : null;

  return form;
});

const initialPayload: Ref<OauthClientUpdate | null> = ref(null);

const isApplicationEditable: ComputedRef<boolean> = computed(
  () =>
    (oAuthClientsService.state.oAuthClient?.editable ?? true) &&
    !isConfigPublishing.value,
);

const isButtonEditApplicationDisabled: ComputedRef<boolean> = computed(
  () => !isApplicationEditable.value || uiStore.isSPViewerOnly,
);

const getServiceProviderOauthClient = async () => {
  try {
    await oAuthClientsService.getServiceProviderOauthClient(
      route.params.application_id as string,
      serviceProviderId.value as string,
    );
    uiStore.isScrimmed =
      oAuthClientsService.state.oAuthClient?.wizard?.hidden ?? false;
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching application details",
      status: "error",
    });
  }
};

const updateServiceProviderOauthClient = async () => {
  if (
    !settingsTabRef.value?.refBasicInformation ||
    !settingsTabRef.value?.refConnectionConfiguration
  )
    return;

  isButtonSaveDisabled.value = true;
  isButtonSaveLoading.value = true;

  try {
    await oAuthClientsService.updateServiceProviderOauthClient(
      route.params.application_id as string,
      serviceProviderId.value as string,
      filterEmptyPropertiesFromObject(payload.value),
    );
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
    await updateServiceProviderOauthClient();
    isInEditMode.value = false;
  }
};

const onEnterEditMode = () => {
  isInEditMode.value = true;
};

const onOpenDialogConfirmDelete = () => {
  isDialogConfirmDeleteOpen.value = true;
};

const onCloseDialogConfirmDelete = () => {
  isDialogConfirmDeleteOpen.value = false;
};

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const isApplicationDeletable: ComputedRef<boolean> = computed(
  () => oAuthClientsService.state.oAuthClient?.deletable ?? true,
);

const onSubmitDialogConfirmDelete = async () => {
  isDialogConfirmDeleteOpen.value = false;
  if (isConfigNotPublished.value)
    localStorage.setItem("hideConfigBanner", "false");
  router.replace("/sp/config/applications");
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  } else isInEditMode.value = false;
};

const onSubmitDialogUnsavedChanges = () => {
  isInEditMode.value = false;
  hasUnsavedChanges.value = false;
  confirmLeave(nextRef.value);
};

const setInitialPayload = () => {
  if (!oAuthClientsService.state.oAuthClient) return;
  initialPayload.value = {
    name: oAuthClientsService.state.oAuthClient.name,
    description: oAuthClientsService.state.oAuthClient.description,
    url: oAuthClientsService.state.oAuthClient.url,
    grant_type: oAuthClientsService.state.oAuthClient.grant_type,
    redirect_uris:
      oAuthClientsService.state.oAuthClient.authorized_redirect_uris,
    mfa_required: oAuthClientsService.state.oAuthClient.mfa_required,
  };
};

watch(
  () => payload.value,
  () => {
    if (!initialPayload.value) return false;
    hasUnsavedChanges.value =
      JSON.stringify(initialPayload.value) !== JSON.stringify(payload.value);
  },
);

onMounted(async () => {
  oAuthClientsService.state.oAuthClient = null;
  await getServiceProviderOauthClient();
  setInitialPayload();
});

onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value && isInEditMode.value) {
    if (doNotShowNextTime.valueOf()) next();
    else {
      setTextsForUnsavedChangesDialog("leave");
      nextRef.value = next;
      updateTargetPages(from.path.toString(), to.path.toString());
      warnUnsavedChanges();
    }
  } else {
    oAuthClientsService.state.oAuthClient = null;
    next();
  }
});

onUnmounted(() => {
  uiStore.isScrimmed = false;
});
</script>

<template>
  <m-m-teleport to="mm-config-banner-section">
    <wizard-banner
      v-if="oAuthClientsService.state.oAuthClient?.wizard"
      :wizard="oAuthClientsService.state.oAuthClient?.wizard"
      :item-id="oAuthClientsService.state.oAuthClient.id"
      class="mm-mb-8"
    />
  </m-m-teleport>
  <template v-if="oAuthClientsService.state.oAuthClient">
    <m-m-page-header
      base-key="configuration.applications.application_details"
      icon="applications-icon"
      :is-in-edit-mode="isInEditMode"
      :params="{ appName: title, appDescription: subtitle }"
      :breadcrumbs="breadcrumbs"
      :banner-settings="{
        showTopBanner: true,
        showTopBannerSecondary: true,
        showHeaderBanner: true,
        showFooterBanner: true,
      }"
      :config-banner-cmp="ConfigPublishBanner"
    >
      <template #header-controls>
        <div class="mm-flex mm-flex-gap-6">
          <template v-if="isInEditMode">
            <m-m-button
              cy="button-save"
              :is-disabled="isButtonSubmitDisabled"
              :loading="isButtonSaveLoading"
              @click="onSubmitForm"
            >
              <div
                v-sanitize-html="
                  $t(
                    'configuration.applications.application_details.save_button',
                  )
                "
              />
              <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
                Config is currently being published.
              </m-m-tooltip>
            </m-m-button>
          </template>
          <m-m-button
            v-else
            variant="outlined"
            prepend-icon="pen"
            cy="button-edit"
            :is-disabled="isButtonEditApplicationDisabled"
            @click="onEnterEditMode"
          >
            <div
              v-sanitize-html="
                $t('configuration.applications.application_details.edit_button')
              "
            />
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
          <m-m-dropdown
            cy="application-details-header-dropdown"
            :items="dropdownItems"
            max-width="218px"
          />
        </div>
      </template>
    </m-m-page-header>
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs
        v-model="currentTabName"
        :items="TABS"
        :is-in-edit-mode="isInEditMode"
      />
    </m-m-teleport>

    <m-m-tab-items :current-tab="currentTabName" :class="scrimmedClass">
      <m-m-tab-item keep-alive :name="TABS[0].name">
        <SettingsTab
          ref="settingsTabRef"
          :open-id-url="openIdURL"
          :service-provider-id="serviceProviderId"
          :mode="isInEditMode ? 'edit' : undefined"
          :is-expandable-basic-info-open="isBasicInfoOpen"
          :is-expandable-connection-config-open="isConnectionConfigOpen"
          @update:basic-info-open="isBasicInfoOpen = $event"
          @update:connection-config-open="isConnectionConfigOpen = $event"
          @application-update="getServiceProviderOauthClient"
          @get-config-status="getConfigStatus"
        />
      </m-m-tab-item>
      <m-m-tab-item keep-alive :name="TABS[1].name">
        <PoliciesTab
          :is-in-edit-mode="isInEditMode"
          :service-provider-id="serviceProviderId"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </template>

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />

  <dialog-confirm-delete-application
    :is-open="isDialogConfirmDeleteOpen"
    :service-provider-id="serviceProviderId"
    @submit="onSubmitDialogConfirmDelete"
    @close="onCloseDialogConfirmDelete"
  />
</template>

<style scoped lang="scss"></style>
