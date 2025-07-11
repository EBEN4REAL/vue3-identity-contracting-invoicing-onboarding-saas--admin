<script setup lang="ts">
import { computed, ComputedRef, onMounted, Ref, ref, watch } from "vue";
import Licenses from "./Licenses.vue";
import DialogPreviewPlan from "./Dialogs/DialogPreviewPlan.vue";
import { authService } from "~/auth/auth.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  AgreementTypePoliciesRead,
  OAuthClientGlobalSettingsRead,
} from "~/configuration/configuration.types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { NavigationGuardNext, onBeforeRouteLeave } from "vue-router";
import { isEqual } from "lodash";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { configurationService } from "~/configuration/configuration.service";
import { AxiosError } from "axios";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

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
const serviceProviderId: Ref<string | null> = ref(null);
const isButtonSaveLoading: Ref<boolean> = ref(false);
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const enablePricingPage: Ref<boolean | null> = ref(null);
const isInEditMode: Ref<boolean> = ref(false);
const selfService: Ref<OAuthClientGlobalSettingsRead | null> = ref(null);
const licensesList: Ref<AgreementTypePoliciesRead[]> = ref([]);
const initialLicensesList: Ref<AgreementTypePoliciesRead[]> = ref([]);
const updateLicensesCmp: Ref<number> = ref(0);
const showPreviewPlanModal: Ref<boolean> = ref(false);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const buttons: ComputedRef<Button[]> = computed(() => {
  if (!isInEditMode.value) {
    return [
      {
        key: "edit_button",
        action: editPricingConfigs,
        isDisabled: isPricingEditablesDisabled.value || uiStore.isSPViewerOnly,
        tooltipText: isConfigPublishing.value
          ? "Config is currently being published"
          : !selfService.value
            ? "Pricing page can only be set up once an application is added on Veriam"
            : "",
      },
      {
        key: "preview_button",
        action: () => (showPreviewPlanModal.value = true),
        isVisible: previewMode.value,
      },
    ];
  } else {
    return [
      {
        key: "save_button",
        action: onSave,
        isDisabled: isButtonSubmitDisabled.value || uiStore.isSPViewerOnly,
        isLoading: isButtonSaveLoading.value,
        tooltipText: isConfigPublishing.value
          ? "Config is currently being published"
          : "",
      },
      {
        key: "discard_button",
        action: onDiscard,
      },
    ];
  }
});

const isCheckboxEnablePricingPageDisabled: ComputedRef<boolean> = computed(
  () => !isInEditMode.value || uiStore.isSPViewerOnly,
);
const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || isButtonSaveDisabled.value,
);

const isPricingEditablesDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || !selfService.value,
);

const editPricingConfigs = () => {
  isInEditMode.value = true;
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  } else isInEditMode.value = false;
};

const previewMode = computed(() => {
  if (licensesList.value === null || enablePricingPage.value === null) {
    return false;
  }
  return licensesList.value.length > 0 && enablePricingPage.value;
});

const planPageData = computed(() => {
  return {
    agreement_types: licensesList.value
      .filter((lic) => lic.include_in_self_service)
      .map((license) => ({
        id: license.id,
        self_service_order: license.self_service_order,
        marketing_features: license.marketing_features,
        description: license.description,
        price: license.price,
      })),
  };
});

const onSave = async () => {
  try {
    if (
      (!licensesList.value?.length ||
        !licensesList.value?.some((lic) => lic.include_in_self_service)) &&
      enablePricingPage.value
    ) {
      eventBus.$emit("onShowToast", {
        text: "To enable the pricing page you need to add at least one plan",
        status: "error",
      });
      return;
    }

    isButtonSaveLoading.value = true;
    isButtonSaveDisabled.value = true;
    await configurationService.updateGlobalOAuthClientSettings(
      serviceProviderId.value as string,
      {
        plan_page_activated: enablePricingPage.value,
        plan_page_redirect_url: null,
        plan_page_data: planPageData.value,
      },
    );
    if (licensesList.value) {
      await Promise.all(
        licensesList.value.map(async (license) => {
          await agreementTypesService.patchAgreementType(
            serviceProviderId.value as string,
            license.id,
            {
              self_service_order: license.self_service_order,
              include_in_self_service: license.include_in_self_service,
              name: license.name,
              marketing_features: license.marketing_features,
            },
          );
        }),
      );
    }
    isInEditMode.value = false;
    isButtonSaveLoading.value = false;
    updateLicensesCmp.value++;
    isButtonSaveDisabled.value = false;
    hasUnsavedChanges.value = false;
  } catch (error) {
    isButtonSaveLoading.value = false;
    isButtonSaveDisabled.value = false;
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

const getSelfServiceSettings = async () => {
  try {
    const response = await configurationService.getGlobalOAuthClientSettings(
      serviceProviderId.value as string,
    );
    if (response) {
      selfService.value = response;
      enablePricingPage.value = selfService.value?.plan_page_activated ?? false;
    }
  } catch (error) {
    const err = error as AxiosError;
    if (err.response?.status === 404) {
      console.error(error);
    }
  }
};

const handleLicensesList = (data: AgreementTypePoliciesRead[]) => {
  licensesList.value = data;
};

const setInitialLicensesList = (data: AgreementTypePoliciesRead[]) => {
  initialLicensesList.value = data;
};

const onSubmitDialogUnsavedChanges = async () => {
  isInEditMode.value = false;
  hasUnsavedChanges.value = false;
  updateLicensesCmp.value++;
  confirmLeave(nextRef.value);
  await getSelfServiceSettings();
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  await getSelfServiceSettings();
});

watch(
  () => [licensesList.value, enablePricingPage.value],
  () => {
    const initialLicensesIds = initialLicensesList.value.map(
      (license) => license.id,
    );
    const licensesIds = licensesList.value.map((license) => license.id);
    hasUnsavedChanges.value =
      !isEqual(initialLicensesIds, licensesIds) ||
      enablePricingPage.value !== selfService.value?.plan_page_activated;
  },
);

onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value && isInEditMode.value) {
    if (doNotShowNextTime.valueOf()) {
      next();
    } else {
      setTextsForUnsavedChangesDialog("leave");
      nextRef.value = next;
      updateTargetPages(from.path.toString(), to.path.toString());
      warnUnsavedChanges();
    }
  } else {
    next();
  }
});
</script>
<template>
  <m-m-overview-page
    resource-id="pricing_page"
    :is-in-edit-mode="isInEditMode"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <div class="mm-mt-12">
      <m-m-card class="mm-pa-10">
        <div data-cy="checkbox-pricing" class="checkbox">
          <m-m-checkbox
            v-model="enablePricingPage"
            cy="self-service-checkbox"
            class="mm-my-6 mm-flex-align-start"
            value="1"
            :disabled="isCheckboxEnablePricingPageDisabled"
            name="checkbox"
            @change="enablePricingPage"
          >
            <div class="mm-flex mm-flex-column">
              <span class="font-weight-600">Enable Pricing Page</span
              ><span class="mm-page-subtitle"
                >Would you like to use a pricing page to enable self service for
                your users?</span
              >
            </div>
          </m-m-checkbox>
        </div>
      </m-m-card>
    </div>
    <m-m-divider class="mm-mt-18"
  /></m-m-overview-page>
  <Licenses
    v-if="serviceProviderId"
    :key="updateLicensesCmp"
    :is-edit-mode="isInEditMode"
    :show-add-license="enablePricingPage && isInEditMode"
    :service-provider-id="serviceProviderId as string"
    @change-licenses-list="handleLicensesList"
    @load-initial-licenses-list="setInitialLicensesList"
  />
  <DialogPreviewPlan
    v-if="serviceProviderId"
    :is-open="showPreviewPlanModal"
    :licenses="licensesList"
    :service-provider-id="serviceProviderId as string"
    @close-dialog="showPreviewPlanModal = false"
  />
  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
  <m-m-config-banner />
</template>
<style scoped lang="scss"></style>
