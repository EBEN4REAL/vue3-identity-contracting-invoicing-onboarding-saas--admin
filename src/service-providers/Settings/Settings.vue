<script setup lang="ts">
import { Ref, onMounted, ref } from "vue";
import { TypeTab } from "../../mm_ui_kit/src/types/types";
import {
  BUTTON_DEFAULT_COLOURS,
  isColorDark,
} from "../../mm_ui_kit/src/helpers/utils";
import { serviceProvidersService } from "../service-providers.service";
import { authService } from "../../auth/auth.service";
import DialogDiscardChanges from "./Dialogs/DialogDiscardChanges.vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { ServiceProviderRead } from "~/iam/iam.types";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const serviceProviderId: Ref<string> = ref("");
const TABS: TypeTab[] = [
  { label: "Branding", name: "Branding", isRequired: false },
];
const mainHeaderTab = ref(TABS[0].name);
const selectedColor = ref(BUTTON_DEFAULT_COLOURS.BACKGROUND_COLOUR);
const buttonTextColor = ref(BUTTON_DEFAULT_COLOURS.TEXT_COLOUR);
const logo = ref();
const isLoading: Ref<boolean> = ref(false);
const isSettingsLoading: Ref<boolean> = ref(false);
const isDialogDiscardChangesOpen: Ref<boolean> = ref(false);
const isEditMode: Ref<boolean> = ref(true);
const brandLogoUrl = ref();
const hasLogoChange: Ref<boolean> = ref(false);
const hasButtonColorChange: Ref<boolean> = ref(false);
const response: Ref<ServiceProviderRead> = ref({});

const handleLogoUploaded = (logoFile: Blob, logoUrl: string) => {
  logo.value = logoFile;
  brandLogoUrl.value = logoUrl;
  hasLogoChange.value = true;
};

const handleColorSelected = (color: string) => {
  selectedColor.value = color;
  hasButtonColorChange.value = true;
};

const updateTextColor = () => {
  const isDark = isColorDark(selectedColor.value);
  buttonTextColor.value = isDark ? "white" : "black";
};

const submit = async () => {
  try {
    isLoading.value = true;
    if (logo.value && hasLogoChange.value) {
      const formData = new FormData();
      formData.append("logo", logo.value);
      await serviceProvidersService.uploadLogoForSP(
        serviceProviderId.value,
        formData,
      );
    }
    await serviceProvidersService.updateServiceProvider(
      serviceProviderId.value,
      {
        button_background_color: selectedColor.value.substring(1),
        button_text_color: buttonTextColor.value,
      },
    );
    isLoading.value = false;
    isEditMode.value = true;
    hasLogoChange.value = false;
  } catch (error) {
    isLoading.value = false;
    isEditMode.value = false;
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
};

const handleOpenDialog = () => {
  isDialogDiscardChangesOpen.value = true;
};

const handleDiscardChanges = () => {
  getSettings();
  isDialogDiscardChangesOpen.value = false;
  isEditMode.value = true;
};

const getSettings = () => {
  brandLogoUrl.value = response.value.logo_url;
  const backgroundColor = response.value.button_background_color;
  if (backgroundColor) {
    selectedColor.value = "#" + backgroundColor;
  }

  const textColor = response.value.button_text_color;
  if (textColor) {
    buttonTextColor.value = textColor;
  }

  logo.value = new File([response.value.logo_url], "", { type: "image/*" });
};

const getServiceProvider = async () => {
  try {
    isSettingsLoading.value = true;
    response.value = await serviceProvidersService.getServiceProvider(
      serviceProviderId.value,
    );
    if (!response.value.logo_url) {
      isSettingsLoading.value = false;
    }
    getSettings();
    isSettingsLoading.value = false;
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching service provider",
      status: "error",
    });
    isSettingsLoading.value = false;
    isLoading.value = false;
  }
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
    await getServiceProvider();
  }
});
</script>

<template>
  <m-m-overview-page resource-id="settings" :show-config-banner="false">
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs v-model="mainHeaderTab" :items="TABS" />
    </m-m-teleport>
    <div
      class="settings mm-flex mm-flex-align-center mm-flex-justify-between mm-page-subtitle mm-page-subtitle--h1"
    >
      Set your brand elements to determine the look and feel for your customers.
      <div v-if="!isEditMode" class="mm-flex">
        <m-m-button
          cy="button-save-settings"
          :loading="isLoading"
          @click="submit"
        >
          Save changes
        </m-m-button>
        <m-m-button
          variant="outlined"
          cy="button-cancel-settings"
          :is-disabled="!(hasLogoChange || hasButtonColorChange)"
          @click="handleOpenDialog"
        >
          Cancel
        </m-m-button>
      </div>
      <div v-else class="mm-flex">
        <m-m-button
          variant="outlined"
          cy="button-edit"
          prepend-icon="pencil"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="isEditMode = false"
        >
          Edit
        </m-m-button>
      </div>
    </div>
    <div class="mm-flex mm-flex-gap-6">
      <m-m-logo-uploader
        :is-edit-mode="!isEditMode"
        :logo-url="brandLogoUrl"
        :is-loading="isSettingsLoading"
        @logo-uploaded="handleLogoUploaded"
        @img-fully-loaded="isSettingsLoading = false"
        ><template #logo-uploader-title>
          <div>Upload Brand Logo</div>
        </template>
        <template #logo-uploader-subtitle>
          <div>
            Full size version of your logo. Must be at least 90px by 100px with
            max size of 2MB. Supported formats: SVG, PNG, JPEG.
          </div>
        </template>
      </m-m-logo-uploader>
    </div>
    <m-m-divider class="mm-my-16" />
    <div class="mm-flex">
      <m-m-skeleton-loader v-if="isSettingsLoading" width="50%" />
      <m-m-color-picker
        v-else
        :init-color="selectedColor"
        :is-edit-mode="!isEditMode"
        @color-selected="handleColorSelected"
        @text-color="updateTextColor"
      >
        <template #color-picker-title>
          <div>Button colour</div>
        </template>
        <template #color-picker-subtitle>
          <div>
            This colour will be applied as the background colour on all the
            buttons.
          </div>
        </template>
        <template #color-picker-content>
          <div class="settings-button-container">
            <m-m-button class="button-settings-button" cy="button-settings">
              Button name
            </m-m-button>
            <div class="mm-mt-8 mm-page-item-label">Button preview</div>
          </div>
        </template>
      </m-m-color-picker>
    </div></m-m-overview-page
  >
  <DialogDiscardChanges
    :is-open="isDialogDiscardChangesOpen"
    @close-dialog="isDialogDiscardChangesOpen = false"
    @discard-changes="handleDiscardChanges"
  />
</template>

<style scoped lang="scss">
.button-settings-button {
  background-color: v-bind(selectedColor);
  border: v-bind(selectedColor);
  color: v-bind(buttonTextColor);
}
.settings {
  margin-bottom: 32px;

  & button:first-child {
    margin-left: auto;
    margin-right: 10px;
  }

  &-button-container {
    border-radius: 28px;
    background: #fafbfc;
    width: fit-content;
    text-align: center;
    padding: 20px;
  }
}
</style>
