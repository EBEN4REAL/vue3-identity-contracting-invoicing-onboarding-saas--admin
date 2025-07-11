<script setup lang="ts">
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
import DialogDeleteResourceType from "~/service-providers/Resources/DialogDeleteResourceType.vue";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import {
  ResourceTypeExtendedRead,
  ResourceTypeUpdate,
} from "~/policies/policies.types";
import SettingsTab from "./Tabs/Settings/Settings.vue";
import {
  TypeResourceBasicInformationForm,
  SettingsTabComponent,
} from "~/service-providers/Resources/ResourceDetails/Tabs/types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { resourceTypesService } from "~/configuration/resource-types.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import MMPageHeader from "~/mm_ui_kit/src/components/MMPageHeader.vue";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const route = useRoute();
const router = useRouter();

const resourceType: Ref<ResourceTypeExtendedRead | null> = ref(null);
const isInEditMode = ref(route.query.editMode || false);
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isDialogDeleteResourceOpen: Ref<boolean> = ref(false);
const settingsTabRef = ref<SettingsTabComponent | null>(null);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const initialPayload: Ref<ResourceTypeUpdate | null> = ref(null);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isResourceAttributesOpen: Ref<boolean> = ref(true);
const pageHeaderRef: Ref<InstanceType<typeof MMPageHeader> | null> = ref(null);
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

const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
];
const currentTabName: Ref<string> = ref(TABS[0].name);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const scrimmedClass: ComputedRef<string> = computed(() =>
  resourceType.value?.wizard?.hidden ? "mm-opacity-40" : "",
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

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "resources",
    label: "Resources",
    to: "/sp/config/resources",
  },
  {
    id: resourceType.value?.name || "",
    label: resourceType.value?.name || "",
  },
]);

const isResourceDeletable: ComputedRef<boolean> = computed(
  () => resourceType.value?.deletable ?? true,
);

const dropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => [
  {
    label: "Duplicate",
    type: "button",
    isDisabled: uiStore.isSPViewerOnly,
    onClick: onDuplicateResourceType,
  },
  {
    label: "Delete",
    color: "error",
    type: "button",
    hint: isConfigPublishing.value
      ? "You cannot delete this resource as config is currently being published."
      : null,
    isDisabled:
      isConfigPublishing.value ||
      !isResourceDeletable.value ||
      uiStore.isSPViewerOnly,
    onClick: onDeleteResourceDialogOpen,
  },
]);

const isButtonEditResourceDisabled: ComputedRef<boolean> = computed(
  () => !isResourceEditable.value || uiStore.isSPViewerOnly,
);

const resourceName: ComputedRef<string> = computed(
  () => resourceType.value?.name || "",
);

const resourceDescription: ComputedRef<string> = computed(
  () => resourceType.value?.description || "",
);

const basicInformationData: ComputedRef<TypeResourceBasicInformationForm> =
  computed(() => ({
    name: resourceType.value?.name || "",
    description: resourceType.value?.description || null,
  }));

const resourceAttributeTypes: ComputedRef<string[]> = computed(
  () => resourceType.value?.resource_attribute_types || [""],
);

const payload: ComputedRef<ResourceTypeUpdate> = computed(() => ({
  ...settingsTabRef.value?.basicInformationEditRef?.form,
  resource_attribute_types:
    settingsTabRef.value?.resourceAttributesEditRef?.form,
}));

const isResourceEditable: ComputedRef<boolean> = computed(
  () => (resourceType.value?.editable ?? true) && !isConfigPublishing.value,
);

const onDeleteResourceDialogOpen = () => {
  isDialogDeleteResourceOpen.value = true;
};

const onDeleteResourceDialogClose = () => {
  isDialogDeleteResourceOpen.value = false;
  pageHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const onDuplicateResourceType = () => {
  resourceTypesService.state.resourceType = resourceType.value;
  router.push({
    name: "ResourceDetailsNew",
  });
};

const onEnterEditMode = () => {
  isInEditMode.value = true;
};

const getResourceType = async () => {
  resourceType.value = await resourceTypesService.getResourceType(
    route.params.service_provider_id as string,
    route.params.resource_id as string,
  );
  uiStore.isScrimmed = resourceType.value?.wizard?.hidden ?? false;
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

const validateForms = async () => {
  if (!settingsTabRef.value) return false;

  const basicInformationForm = settingsTabRef.value.basicInformationEditRef;
  const resourceAttributesForm = settingsTabRef.value.resourceAttributesEditRef;

  await basicInformationForm?.v$.$validate();
  resourceAttributesForm?.checkForErrors();

  let isValid = true;

  if (basicInformationForm?.v$.$invalid) {
    isBasicInfoOpen.value = true;
    isValid = false;
  }

  const resourceAttributesInvalid = resourceAttributesForm?.form.some(
    (attribute) => !attribute,
  );

  if (resourceAttributesInvalid) {
    isResourceAttributesOpen.value = true;
    isValid = false;
  }

  if (basicInformationForm?.v$.$invalid || resourceAttributesInvalid) return;
  return isValid;
};

const onSubmitForm = async () => {
  if (!settingsTabRef.value) return;

  const isValid = await validateForms();

  if (!isValid) return;

  try {
    isButtonSaveDisabled.value = true;
    isButtonSubmitLoading.value = true;
    hasUnsavedChanges.value = false;

    await resourceTypesService.patchResourceType(
      route.params.service_provider_id as string,
      route.params.resource_id as string,
      filterEmptyPropertiesFromObject(payload.value),
    );
    resourceType.value = await resourceTypesService.getResourceType(
      route.params.service_provider_id as string,
      resourceType.value?.id as string,
    );
    isInEditMode.value = false;
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

const setInitialPayload = () => {
  if (!resourceType.value) return;
  initialPayload.value = {
    name: resourceType.value.name,
    description: resourceType.value.description,
    resource_attribute_types: resourceType.value.resource_attribute_types,
  };
};

watch(
  () => payload.value,
  () => {
    if (!initialPayload.value) return false;
    hasUnsavedChanges.value =
      JSON.stringify(initialPayload.value) !== JSON.stringify(payload.value);
  },
  {
    deep: true,
  },
);

onMounted(async () => {
  await getResourceType();
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
    next();
  }
});

const updateBasicInfoOpen = (value: boolean) => {
  isBasicInfoOpen.value = value;
};

const updateResourceAttributesOpen = (value: boolean) => {
  isResourceAttributesOpen.value = value;
};

onUnmounted(() => {
  uiStore.isScrimmed = false;
});
</script>

<template>
  <m-m-teleport to="mm-config-banner-section">
    <wizard-banner
      v-if="resourceType?.wizard"
      :wizard="resourceType?.wizard"
      :item-id="resourceType.id"
      class="mm-mb-8"
    />
  </m-m-teleport>
  <m-m-page-header
    ref="pageHeaderRef"
    base-key="configuration.resources.resource_details"
    icon="resource"
    :params="{ resourceName, resourceDescription }"
    :is-in-edit-mode="isInEditMode"
    :breadcrumbs="breadcrumbs"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <template v-if="isInEditMode">
          <m-m-button
            cy="button-save"
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
        </template>
        <m-m-button
          v-else
          variant="outlined"
          prepend-icon="pen"
          cy="button-edit"
          :is-disabled="isButtonEditResourceDisabled"
          @click="onEnterEditMode"
        >
          Edit
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
        <m-m-dropdown
          cy="resource-type-header-dropdown"
          max-width="218px"
          :items="dropdownItems"
        />
      </div> </template
  ></m-m-page-header>
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs
      v-model="currentTabName"
      :items="TABS"
      :is-in-edit-mode="isInEditMode"
    />
  </m-m-teleport>

  <m-m-tab-items
    v-if="resourceType"
    :current-tab="currentTabName"
    :class="scrimmedClass"
  >
    <m-m-tab-item keep-alive :name="TABS[0]?.name">
      <SettingsTab
        ref="settingsTabRef"
        :is-in-edit-mode="isInEditMode"
        :basic-information-data="basicInformationData"
        :resource-attributes-data="resourceAttributeTypes"
        :service-provider-id="route.params.service_provider_id as string"
        :is-basic-info-open="isBasicInfoOpen"
        :is-resource-attributes-open="isResourceAttributesOpen"
        @update:basic-info-open="updateBasicInfoOpen"
        @update:resource-attributes-open="updateResourceAttributesOpen"
      />
    </m-m-tab-item>
  </m-m-tab-items>

  <dialog-delete-resource-type
    :is-open="isDialogDeleteResourceOpen"
    :service-provider-id="route.params.service_provider_id as string"
    :resource-id="resourceType?.id"
    :resource-name="resourceType?.name"
    @close="onDeleteResourceDialogClose"
  />

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>
