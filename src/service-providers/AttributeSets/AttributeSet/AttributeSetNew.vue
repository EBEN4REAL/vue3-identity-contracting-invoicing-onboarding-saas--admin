<script setup lang="ts">
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { computed, ComputedRef, onMounted, Ref, ref, watch } from "vue";
import { attributeSetsService } from "~/configuration/attribute-sets.service";
import { authService } from "~/auth/auth.service";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import SettingsTabComponent from "./Tabs/Settings/Settings.vue";
import {
  AttributeSetCreate,
  AttributeSetWithAttributeTypesRead,
} from "~/onboarding/onboarding.types";
import { transformStringToAttributeOf } from "../attributeSetAttributeOfHelper";
import {
  useRouter,
  useRoute,
  NavigationGuardNext,
  onBeforeRouteLeave,
} from "vue-router";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { TypeAttributesRead, SettingsTabComponentType } from "./Tabs/types";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";

const router = useRouter();
const route = useRoute();
const settingsTabRef: Ref<SettingsTabComponentType | null> = ref(null);
const attributeSetNamePlaceholder = "New Attribute Set";
const serviceProviderId: Ref<string> = ref("");
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
];
const currentTabName: Ref<string> = ref(TABS[0].name);
const attributes: Ref<TypeAttributesRead | null> = ref(null);
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
const nextRef: Ref<NavigationGuardNext | null> = ref(null);

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

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "resources",
    label: "Attribute sets",
    to: "/sp/config/attribute-sets",
  },
  {
    id: settingsTabRef.value?.basicInformation?.form.name || "",
    label:
      settingsTabRef.value?.basicInformation?.form.name ||
      attributeSetNamePlaceholder,
  },
]);

const title: ComputedRef<string> = computed(
  () =>
    settingsTabRef.value?.basicInformation?.form.name ||
    attributeSetNamePlaceholder,
);

const subtitle: ComputedRef<string> = computed(
  () => settingsTabRef.value?.basicInformation?.form.description || "",
);

const isFormInBasicInformationInvalid: ComputedRef<boolean> = computed(() =>
  Boolean(settingsTabRef.value?.basicInformation?.v$.$invalid),
);

const payload: ComputedRef<AttributeSetCreate> = computed(() => ({
  ...(settingsTabRef.value?.basicInformation?.form ?? {}),
  ...attributes.value,
  type: attributeSetsService.state.attributeSetAttributeOf,
}));

const onSubmitForm = async () => {
  try {
    hasUnsavedChanges.value = false;
    isButtonSaveDisabled.value = true;
    isButtonSubmitLoading.value = true;

    if (
      !settingsTabRef.value?.basicInformation?.form ||
      !attributeSetsService.state.attributeSetAttributeOf
    )
      return;

    const attributeSet: AttributeSetWithAttributeTypesRead =
      await attributeSetsService.createAttributeSet(
        serviceProviderId.value,
        filterEmptyPropertiesFromObject(payload.value),
      );

    router.push(
      `/sp/${serviceProviderId.value}/attribute-sets/${attributeSet.id}`,
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  } finally {
    isButtonSaveDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

watch(
  () => payload.value,
  () => {
    const isBasicInformationHasChanges = Object.values(
      settingsTabRef.value?.basicInformation?.form ?? {},
    ).some(Boolean);
    const isAttributesHasChanges =
      Boolean(attributes.value?.required_attribute_types?.length) ||
      Boolean(attributes.value?.optional_attribute_types?.length);
    hasUnsavedChanges.value =
      isBasicInformationHasChanges || isAttributesHasChanges;
  },
  {
    deep: true,
  },
);

watch(
  [isFormInBasicInformationInvalid, attributes],
  () => {
    isButtonSaveDisabled.value =
      isFormInBasicInformationInvalid.value ||
      Boolean(
        attributes.value?.required_attribute_types?.length === 0 &&
          attributes.value?.optional_attribute_types?.length === 0,
      );
  },
  { deep: true },
);

const onAttributesChange = (_attributes: TypeAttributesRead) => {
  attributes.value = _attributes;
};

const setAttributeSetAttributeOf = (attributeOf: string) => {
  attributeSetsService.setAttributeSetAttributeOf(
    transformStringToAttributeOf(attributeOf),
  );
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  }
  router.push({
    path: "/sp/config/attribute-sets",
  });
};

onMounted(async () => {
  setAttributeSetAttributeOf(route.hash.replace("#", ""));
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  await unpublishedChangesStore.getUnpublishedConfig();
  await unpublishedChangesStore.getConfigDetails();
});

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
</script>

<template>
  <m-m-page-header
    base-key="configuration.attribute_sets.attribute_set_new"
    icon="queue-list"
    :breadcrumbs="breadcrumbs"
    :params="{ title, subtitle }"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <m-m-button
          cy="button-save-attribute-set"
          :is-disabled="isButtonSubmitDisabled"
          :loading="isButtonSubmitLoading"
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
    </template></m-m-page-header
  >
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="currentTabName" :items="TABS" is-in-edit-mode />
  </m-m-teleport>
  <m-m-tab-items :current-tab="currentTabName">
    <m-m-tab-item keep-alive :name="TABS[0].name">
      <settings-tab-component
        ref="settingsTabRef"
        mode="create"
        @attributes-change="onAttributesChange"
      />
    </m-m-tab-item>
  </m-m-tab-items>

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="confirmLeave(nextRef)"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>

<style scoped lang="scss"></style>
