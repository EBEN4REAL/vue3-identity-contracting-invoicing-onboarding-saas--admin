<script setup lang="ts">
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import {
  computed,
  ComputedRef,
  onMounted,
  onUnmounted,
  Ref,
  ref,
  watch,
} from "vue";
import {
  NavigationGuardNext,
  onBeforeRouteLeave,
  useRoute,
  useRouter,
} from "vue-router";
import { attributeSetsService } from "~/configuration/attribute-sets.service";
import {
  AttributeSetUpdate,
  AttributeSetWithAttributeTypesRead,
  OAuthClientBaseRead,
} from "~/onboarding/onboarding.types";
import { authService } from "~/auth/auth.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import TabRelatedItems from "./Tabs/RelatedItems/RelatedItems.vue";
import {
  SettingsTabComponentType,
  TypeAttributeSetBasicInformationForm,
  TypeAttributesRead,
} from "~/service-providers/AttributeSets/AttributeSet/Tabs/types";
import SettingsTabComponent from "./Tabs/Settings/Settings.vue";
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
import { TableResponse } from "~/mm_ui_kit/src/types/table.types";
import DialogDeleteAttributeSet from "./Dialogs/DialogDeleteAttributeSet.vue";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { isEqual } from "lodash";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import MMPageHeader from "~/mm_ui_kit/src/components/MMPageHeader.vue";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const route = useRoute();
const router = useRouter();

const attributeSet: Ref<AttributeSetWithAttributeTypesRead | null> = ref(null);
const attributeSetUsage: Ref<TableResponse<OAuthClientBaseRead> | null> =
  ref(null);
const pageHeaderRef: Ref<InstanceType<typeof MMPageHeader> | null> = ref(null);
const serviceProviderId: Ref<string> = ref("");
const isInEditMode = ref(route.query.editMode || false);
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isButtonConfirmDeleteDisabled: Ref<boolean> = ref(false);
const isButtonConfirmDeleteLoading: Ref<boolean> = ref(false);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isAttributesOpen: Ref<boolean> = ref(true);
const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
  { label: "Related items", name: "Related items", isRequired: false },
];
const currentTabName: Ref<string> = ref(TABS[0].name);
const attributes: Ref<TypeAttributesRead | null> = ref(null);
const isDialogDeleteAttributeSetOpened: Ref<boolean> = ref(false);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const scrimmedClass: ComputedRef<string> = computed(() =>
  attributeSet.value?.wizard?.hidden ? "mm-opacity-40" : "",
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () =>
    isConfigPublishing.value ||
    isButtonSaveDisabled.value ||
    uiStore.isSPViewerOnly,
);
const settingsTabRef: Ref<SettingsTabComponentType | null> = ref(null);
const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "resources",
    label: "Attribute sets",
    to: "/sp/config/attribute-sets",
  },
  {
    id: attributeSet.value?.name || "",
    label: attributeSet.value?.name || "",
  },
]);

const title: ComputedRef<string> = computed(
  () => attributeSet.value?.name || "",
);

const subtitle: ComputedRef<string> = computed(
  () => attributeSet.value?.description || "",
);

const basicInformationData: Ref<TypeAttributeSetBasicInformationForm> =
  computed(() => ({
    name: attributeSet.value?.name || "",
    description: attributeSet.value?.description || null,
  }));

const attributesData: ComputedRef<TypeAttributesRead> = computed(() => ({
  required_attribute_types:
    attributeSet.value?.required_attribute_types || null,
  optional_attribute_types:
    attributeSet.value?.optional_attribute_types || null,
}));

const areAttributesReady: ComputedRef<boolean> = computed(() =>
  Boolean(
    attributesData.value.required_attribute_types &&
      attributesData.value.optional_attribute_types,
  ),
);

const isAttributeSetHasUsages: ComputedRef<boolean> = computed(() =>
  Boolean(attributeSetUsage.value?.total),
);

const isButtonEditAttributeSetDisabled: ComputedRef<boolean> = computed(
  () => !isAttributeSetEditable.value || uiStore.isSPViewerOnly,
);

const deleteAttributeSetHintText: ComputedRef<string | null> = computed(() => {
  if (isAttributeSetHasUsages.value) {
    return `This attribute set is being used by ${attributeSetUsage.value?.total} applications. You can only delete this attribute set if there are no references.`;
  }
  if (isConfigPublishing.value) {
    return `You cannot delete this atrribute set as config is currently being published.`;
  }
  return null;
});

const isAttributeSetDeletable: ComputedRef<boolean> = computed(
  () => attributeSet.value?.deletable ?? true,
);

const dropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => [
  {
    label: "Delete",
    color: "error",
    type: "button",
    isDisabled:
      isAttributeSetHasUsages.value ||
      isConfigPublishing.value ||
      !isAttributeSetDeletable.value,
    hint: deleteAttributeSetHintText.value,
    onClick: onDialogAttributeSetOpen,
  },
]);

const payload: ComputedRef<AttributeSetUpdate> = computed(() => ({
  name: settingsTabRef.value?.basicInformation?.form.name || "",
  description: settingsTabRef.value?.basicInformation?.form.description || "",

  ...settingsTabRef.value?.attributes,
}));

const isAttributeSetEditable: ComputedRef<boolean> = computed(
  () => (attributeSet.value?.editable ?? true) && !isConfigNotPublished.value,
);

const onDialogAttributeSetOpen = () => {
  isDialogDeleteAttributeSetOpened.value = true;
};

const onDialogAttributeSetClose = () => {
  isDialogDeleteAttributeSetOpened.value = false;
  pageHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const getAttributeSet = async () => {
  try {
    attributeSet.value = await attributeSetsService.getAttributeSet(
      serviceProviderId.value,
      route.params.attribute_set_id as string,
    );
    uiStore.isScrimmed = attributeSet.value?.wizard?.hidden ?? false;
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching attribute set",
      status: "error",
    });
  }
};

const getAttributeSetUsage = async () => {
  try {
    attributeSetUsage.value = await attributeSetsService.getAttributeSetUsages(
      serviceProviderId.value,
      attributeSet.value?.id as string,
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching attribute set usage",
      status: "error",
    });
  }
};

const deleteAttributeSet = async () => {
  try {
    isButtonConfirmDeleteDisabled.value = true;
    isButtonConfirmDeleteLoading.value = true;

    await attributeSetsService.deleteAttributeSet(
      serviceProviderId.value,
      attributeSet.value?.id as string,
    );
    if (isConfigNotPublished.value)
      localStorage.setItem("hideConfigBanner", "false");
    router.push(`/sp/config/attribute-sets`);
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting attribute set",
      status: "error",
    });
  } finally {
    isButtonConfirmDeleteDisabled.value = false;
    isButtonConfirmDeleteLoading.value = false;
  }
};

const onEnterEditMode = () => {
  isInEditMode.value = true;
};

const onExitEditMode = () => {
  isInEditMode.value = false;
};

const onSubmitForm = async () => {
  settingsTabRef.value?.basicInformation?.v$.$validate();
  if (settingsTabRef.value?.basicInformation?.v$.$invalid) {
    isBasicInfoOpen.value = true;
    return;
  }
  try {
    isButtonSaveDisabled.value = true;
    isButtonSubmitLoading.value = true;
    await attributeSetsService.updateAttributeSet(
      serviceProviderId.value,
      attributeSet.value?.id as string,
      filterEmptyPropertiesFromObject(payload.value) as AttributeSetUpdate,
    );
    await getAttributeSet();
    onExitEditMode();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error updating attribute set",
      status: "error",
    });
  } finally {
    isButtonSaveDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  } else isInEditMode.value = false;
};

const onConfirmDiscard = () => {
  isInEditMode.value = false;
  hasUnsavedChanges.value = false;
  confirmLeave(nextRef.value);
};

const compareObjects = (obj1, obj2) =>
  Object.keys(obj1).every(
    (key) => obj2.hasOwnProperty(key) && isEqual(obj1[key], obj2[key]),
  );

watch(
  () => payload.value,
  () => {
    if (!isInEditMode.value) return;
    const isBasicInformationHasChanges =
      settingsTabRef.value?.basicInformation?.form &&
      settingsTabRef.value?.basicInformation
        ? !compareObjects(
            settingsTabRef.value?.basicInformation,
            settingsTabRef.value?.basicInformation?.form,
          )
        : false;
    const isAttributesHasChanges = !isEqual(
      attributesData.value,
      attributes.value,
    );
    hasUnsavedChanges.value =
      isBasicInformationHasChanges || isAttributesHasChanges;
  },
  {
    deep: true,
  },
);

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
    await getAttributeSet();
    await getAttributeSetUsage();
  }
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
      v-if="attributeSet?.wizard"
      :wizard="attributeSet?.wizard"
      :item-id="attributeSet.id"
      class="mm-mb-8"
    />
  </m-m-teleport>
  <m-m-page-header
    ref="pageHeaderRef"
    base-key="configuration.attribute_sets.attribute_set_details"
    icon="queue-list"
    :breadcrumbs="breadcrumbs"
    :is-in-edit-mode="isInEditMode"
    :params="{ title, subtitle }"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <template v-if="isInEditMode">
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
          <m-m-button
            cy="button-discard-attribute-set"
            variant="outlined"
            @click="onDiscard"
          >
            Discard
          </m-m-button>
          <m-m-dropdown
            cy="header-dropdown"
            :items="dropdownItems"
            max-width="218px"
          />
        </template>
        <template v-else>
          <m-m-button
            variant="outlined"
            prepend-icon="pen"
            cy="button-edit-attribute-set"
            :is-disabled="isButtonEditAttributeSetDisabled"
            @click="onEnterEditMode"
          >
            Edit
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
        </template>
      </div>
    </template></m-m-page-header
  >
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs
      v-model="currentTabName"
      :items="TABS"
      :is-in-edit-mode="isInEditMode"
    />
  </m-m-teleport>
  <m-m-tab-items :current-tab="currentTabName" :class="scrimmedClass">
    <m-m-tab-item v-if="basicInformationData" keep-alive :name="TABS[0].name">
      <settings-tab-component
        ref="settingsTabRef"
        :mode="isInEditMode ? 'edit' : undefined"
        :data="basicInformationData"
        :are-attributes-ready="areAttributesReady"
        :attributes-data="attributesData"
        :is-expandable-basic-info-open="isBasicInfoOpen"
        :is-expandable-attributes-open="isAttributesOpen"
        @update:basic-info-open="isBasicInfoOpen = $event"
        @update:attributes-open="isAttributesOpen = $event"
      />
    </m-m-tab-item>

    <m-m-tab-item keep-alive :name="TABS[1].name">
      <tab-related-items v-if="attributeSetUsage" :data="attributeSetUsage" />
    </m-m-tab-item>
  </m-m-tab-items>

  <dialog-delete-attribute-set
    v-if="attributeSet"
    :is-open="isDialogDeleteAttributeSetOpened"
    :data="attributeSet"
    :is-button-confirm-delete-disabled="isButtonConfirmDeleteDisabled"
    :is-button-confirm-delete-loading="isButtonConfirmDeleteLoading"
    @submit="deleteAttributeSet"
    @close="onDialogAttributeSetClose"
  />

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onConfirmDiscard"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>

<style scoped lang="scss"></style>
