<script setup lang="ts">
import { computed, ComputedRef, Ref, ref, watch, onMounted } from "vue";
import {
  NavigationGuardNext,
  onBeforeRouteLeave,
  useRoute,
  useRouter,
} from "vue-router";
import SettingsTab from "./Tabs/Settings/Settings.vue";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import {
  ResourceTypeExtendedRead,
  ResourceTypeRead,
  ResourceTypeUpdate,
} from "~/policies/policies.types";
import {
  SettingsTabComponent,
  TypeResourceBasicInformationForm,
} from "~/service-providers/Resources/ResourceDetails/Tabs/types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { resourceTypesService } from "~/configuration/resource-types.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";

const router = useRouter();
const route = useRoute();

const resourceType: Ref<ResourceTypeExtendedRead | null> = ref(null);
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const resourcesPlaceholder: string = "Create Resource";
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isResourceAttributesOpen: Ref<boolean> = ref(true);
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

const settingsTabRef = ref<SettingsTabComponent | null>(null);
const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
];

const serviceProviderId = computed(
  () => route.params.service_provider_id as string,
);
const currentTabName: Ref<string> = ref(TABS[0].name);

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
    label: "Resources",
    to: "/sp/config/resources",
  },
  {
    id: resourceType.value?.name || "",
    label:
      settingsTabRef.value?.basicInformationEditRef?.form.name ||
      resourcesPlaceholder,
  },
]);

const title: ComputedRef<string> = computed(
  () =>
    settingsTabRef.value?.basicInformationEditRef?.form.name ||
    resourcesPlaceholder,
);

const subtitle: ComputedRef<string> = computed(
  () => settingsTabRef.value?.basicInformationEditRef?.form.description || "",
);

const basicInformationData = computed(
  (): TypeResourceBasicInformationForm => ({
    name: resourceTypesService.state.resourceType?.name || "",
    description: resourceTypesService.state.resourceType?.description || null,
  }),
);

const resourceAttributesData = computed(
  (): string[] =>
    resourceTypesService.state.resourceType?.resource_attribute_types || [],
);

const payload: ComputedRef<ResourceTypeUpdate> = computed(() => ({
  ...settingsTabRef.value?.basicInformationEditRef?.form,
  resource_attribute_types:
    settingsTabRef.value?.resourceAttributesEditRef?.form,
}));

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

    const createdResourceType: ResourceTypeRead =
      await resourceTypesService.postResourceType(
        serviceProviderId.value,
        filterEmptyPropertiesFromObject(payload.value),
      );

    router.push({
      name: "ResourceDetails",
      params: {
        service_provider_id: serviceProviderId.value,
        resource_id: createdResourceType.id,
      },
    });
  } catch (err) {
    isButtonSaveDisabled.value = false;
    isButtonSubmitLoading.value = false;
    hasUnsavedChanges.value = false;

    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  }
};

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

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  }
  router.push({
    path: "/sp/config/resources",
  });
};

watch(
  () => payload.value,
  (newValue, oldValue) => {
    hasUnsavedChanges.value = Boolean(
      Object.values(oldValue).some(Boolean) &&
        Object.values(newValue).some(Boolean),
    );
  },
  {
    deep: true,
  },
);

const updateBasicInfoOpen = (value: boolean) => {
  isBasicInfoOpen.value = value;
};

const updateResourceAttributesOpen = (value: boolean) => {
  isResourceAttributesOpen.value = value;
};

onMounted(async () => {
  await unpublishedChangesStore.getUnpublishedConfig();
  await unpublishedChangesStore.getConfigDetails();
});
</script>

<template>
  <m-m-page-header
    base-key="configuration.resources.resource_new"
    icon="resource"
    :breadcrumbs="breadcrumbs"
    :params="{ title: title, subtitle: subtitle }"
    show-ellipsis
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
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
      </div></template
    ></m-m-page-header
  >
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="currentTabName" :items="TABS" is-in-edit-mode />
  </m-m-teleport>

  <m-m-tab-items :current-tab="currentTabName">
    <m-m-tab-item keep-alive :name="TABS[0].name">
      <SettingsTab
        ref="settingsTabRef"
        :basic-information-data="basicInformationData"
        :resource-attributes-data="resourceAttributesData"
        :service-provider-id="serviceProviderId"
        :is-basic-info-open="isBasicInfoOpen"
        :is-resource-attributes-open="isResourceAttributesOpen"
        :is-in-edit-mode="true"
        @update:basic-info-open="updateBasicInfoOpen"
        @update:resource-attributes-open="updateResourceAttributesOpen"
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
