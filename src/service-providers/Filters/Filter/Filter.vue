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
import RelatedItems from "./Tabs/RelatedItems/RelatedItems.vue";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  TypeFilterBasicInformationData,
  TypeValidatorFilterCondition,
} from "~/service-providers/Filters/Filter/Tabs/types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  FilterItemRead,
  FilterRead,
  FilterUpdate,
  NestedFilterRead,
  ParentFilterPerFilterRead,
  SettingsTabComponentType,
} from "~/service-providers/Filters/filters.types";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { filtersService } from "~/configuration/filters.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import Settings from "../Settings/Settings.vue";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import { isEqual } from "lodash";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const route = useRoute();
const router = useRouter();
const duplicateMode = route.query.duplicateMode;
const serviceProviderId: Ref<string> = ref(
  route.params.service_provider_id.toString(),
);
const isServiceProvider: Ref<boolean> = ref(false);
const filter: Ref<FilterRead | null> = ref(null);
const parent_filters: Ref<FilterRead[] | null> = ref(null);
const isInEditMode: Ref<boolean> = ref(Boolean(route.query.editMode));
const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const isConfirmDeleteButtonSubmitDisabled: Ref<boolean> = ref(false);
const isConfirmDeleteButtonSubmitLoading: Ref<boolean> = ref(false);
const isLoading: Ref<boolean> = ref(false);
const isTableDataLoading: Ref<boolean> = ref(true);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);

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

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(
  (): TypeBreadcrumbItem[] => [
    {
      id: "filters",
      label: "Filters",
      to: "/sp/config/filters",
    },
    {
      id: filter.value?.id || "",
      label: filter.value?.name || "",
    },
  ],
);

const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
  { label: "Related items", name: "Related items", isRequired: false },
];

const settingsComponentRef: Ref<SettingsTabComponentType | null> = ref(null);
const currentTabName: Ref<string> = ref(TABS[0].name);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isFilterConditionsOpen: Ref<boolean> = ref(true);
const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const scrimmedClass: ComputedRef<string> = computed(() =>
  filter.value?.wizard?.hidden ? "mm-opacity-40" : "",
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isButtonEditFilterDisabled: ComputedRef<boolean> = computed(
  () => !isFilterEditable.value || uiStore.isSPViewerOnly,
);

const isFilterDeletable: ComputedRef<boolean> = computed(
  () => filter.value?.deletable ?? true,
);

const dropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => [
  {
    label: "Duplicate",
    type: "button",
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    hint: isConfigPublishing.value
      ? "You cannot duplicate this filter as config is currently being published"
      : "",
    onClick: onDuplicateFilter,
  },
  {
    label: "Delete",
    color: "error",
    type: "button",
    isDisabled:
      isDeleteFilterDisabled.value ||
      isConfigPublishing.value ||
      !isFilterDeletable.value,
    hint: deleteFilterHintText.value,
    onClick: onDeleteFilter,
  },
]);

const isDeleteFilterDisabled = computed(
  () =>
    (filter.value?.parent_filters &&
      filter.value?.parent_filters?.length > 0) ||
    (filter.value?.policy_types && filter.value?.policy_types?.length > 0),
);

const deleteFilterHintText: ComputedRef<string | null> = computed(() => {
  if (isDeleteFilterDisabled.value) {
    return "You cannot delete this filter as there are active instances of it.";
  }
  if (isConfigPublishing.value) {
    return "You cannot delete this filter as config is currently being published.";
  }
  return null;
});
const title: ComputedRef<string> = computed(
  () =>
    settingsComponentRef.value?.basicInformationEditRef?.form.name ||
    filter.value?.name ||
    "",
);
const subtitle: ComputedRef<string> = computed(
  () =>
    settingsComponentRef.value?.basicInformationEditRef?.form.description ||
    filter.value?.description ||
    "",
);
const parentFilterIds: ComputedRef<string[]> = computed((): string[] => {
  const parentFilters = filter.value?.parent_filters;
  if (parentFilters?.length) {
    const isParentFilterPerFilterObject =
      parentFilters[0].hasOwnProperty("child_filter_id") &&
      parentFilters[0].hasOwnProperty("parent_filter_id");

    if (isParentFilterPerFilterObject) {
      return parentFilters.map(
        (parentFilter: ParentFilterPerFilterRead) =>
          parentFilter.parent_filter_id,
      );
    } else return parentFilters; // Will be later refactored to array of strings on API
  } else return [];
});

const initialPayload: ComputedRef<FilterUpdate> = computed(() => ({
  name: filter.value?.name,
  description: filter.value?.description,
  filter_items: filter.value?.filter_items
    ? filter.value?.filter_items.map((filterItem: FilterItemRead) => ({
        id: filterItem.id,
        attribute_source: filterItem.attribute_source,
        attribute_type: filterItem.attribute_type,
        operator: filterItem.operator,
        value: filterItem.value,
      }))
    : [],
  operator: filter.value?.operator,
  filters: filter.value?.filters
    ? filter.value?.filters.map(
        (nestedFilter: NestedFilterRead) => nestedFilter.child_filter_id,
      )
    : [],
}));

const payload: ComputedRef<FilterUpdate> = computed(() => ({
  ...settingsComponentRef.value?.basicInformationEditRef?.form,
  filter_items:
    settingsComponentRef.value?.filterConditionsEditRef?.filter_items,
  operator: settingsComponentRef.value?.filterConditionsEditRef?.operator,
  filters: settingsComponentRef.value?.filterConditionsEditRef?.filters.map(
    (filter: FilterRead) => filter.id,
  ),
}));

const onEnterEditMode = () => {
  isInEditMode.value = true;
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  } else isInEditMode.value = false;
};

const toggleConfirmDelete = () => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
};

const onDuplicateFilter = () => {
  router.push({
    name: "FilterDetailsNew",
  });
  filtersService.state.filter = filter.value;
};

const onDeleteFilter = () => {
  toggleConfirmDelete();
};

const basicInformationData: Ref<TypeFilterBasicInformationData> = computed(
  () => ({
    name: filter.value?.name || "",
    description: filter.value?.description || null,
  }),
);

const onSubmitFilterForm = async () => {
  if (settingsComponentRef.value) {
    const basicInformationForm =
      settingsComponentRef.value.basicInformationEditRef;
    const filterConditionsForm =
      settingsComponentRef.value.filterConditionsEditRef;

    await Promise.all([
      basicInformationForm?.v$.$validate(),
      filterConditionsForm.v$List.forEach(
        (v$: TypeValidatorFilterCondition) => {
          v$.value.$validate();
        },
      ),
    ]);

    const isBasicInfoInvalid = basicInformationForm?.v$.$invalid;
    const isFilterConditionsInvalid = filterConditionsForm.v$List.some(
      (v$: TypeValidatorFilterCondition) => v$.value.$invalid,
    );

    if (isBasicInfoInvalid) isBasicInfoOpen.value = true;
    if (isFilterConditionsInvalid) isFilterConditionsOpen.value = true;
    if (isBasicInfoInvalid || isFilterConditionsInvalid) return;
  }
  if (
    settingsComponentRef.value?.filterConditionsEditRef &&
    settingsComponentRef.value?.basicInformationEditRef
  ) {
    try {
      isLoading.value = true;
      filter.value = await filtersService.patchFilter(
        route.params.filter_id.toString(),
        filterEmptyPropertiesFromObject(payload.value),
        serviceProviderId.value,
      );
      isInEditMode.value = false;
    } catch (err) {
      eventBus.$emit("onShowToast", {
        text: getErrorMessage(err),
        status: "error",
      });
    }
    isLoading.value = false;
  } else {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
  hasUnsavedChanges.value = false;
};

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const isFilterEditable: ComputedRef<boolean> = computed(
  () => (filter.value?.editable ?? true) && !isConfigPublishing.value,
);

const onSubmitDeleteFilter = async () => {
  try {
    isConfirmDeleteButtonSubmitDisabled.value = true;
    isConfirmDeleteButtonSubmitLoading.value = true;
    await filtersService.deleteFilter(
      serviceProviderId.value,
      route.params.filter_id.toString(),
    );
    if (isConfigNotPublished.value)
      localStorage.setItem("hideConfigBanner", "false");
    router.push({
      name: "Filters",
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting filter",
      status: "error",
    });
  } finally {
    isConfirmDeleteButtonSubmitDisabled.value = false;
    isConfirmDeleteButtonSubmitLoading.value = false;
  }
};

const fetchParentFiltersByIds = async () => {
  return Promise.all(
    parentFilterIds.value.map((parentFilterId: string) =>
      filtersService.getFilterById(serviceProviderId.value, parentFilterId),
    ),
  );
};

const onSubmitDialogUnsavedChanges = () => {
  isInEditMode.value = false;
  hasUnsavedChanges.value = false;
  confirmLeave(nextRef.value);
};

onMounted(async () => {
  isTableDataLoading.value = true;
  const serviceProvider = await serviceProvidersService.getServiceProvider(
    serviceProviderId.value,
  );
  isServiceProvider.value = !!serviceProvider.id;
  filter.value = await filtersService.getFilterById(
    serviceProviderId.value,
    route.params.filter_id.toString(),
  );
  uiStore.isScrimmed = filter.value?.wizard?.hidden ?? false;
  parent_filters.value = await fetchParentFiltersByIds();
  isTableDataLoading.value = false;
  if (duplicateMode) {
    onDuplicateFilter();
  }
});

watch(
  () => payload.value,
  () => {
    if (!initialPayload.value) return false;
    hasUnsavedChanges.value = !isEqual(initialPayload.value, payload.value);
  },
  {
    deep: true,
  },
);

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
  <div v-if="isServiceProvider">
    <m-m-teleport to="mm-config-banner-section">
      <wizard-banner
        v-if="filter?.wizard"
        :wizard="filter?.wizard"
        :item-id="filter.id"
        class="mm-mb-8"
      />
    </m-m-teleport>
    <m-m-page-header
      base-key="configuration.filters.filter_details"
      :params="{
        filterName: title,
        filterDescription: subtitle,
      }"
      icon="filter"
      :is-in-edit-mode="isInEditMode"
      :breadcrumbs="breadcrumbs"
      :config-banner-cmp="ConfigPublishBanner"
    >
      <template #header-controls>
        <div class="mm-flex mm-flex-gap-6">
          <template v-if="isInEditMode">
            <m-m-button
              cy="button-save-filter"
              :loading="isLoading"
              :is-disabled="isConfigPublishing"
              @click="onSubmitFilterForm"
            >
              Save
              <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
                Config is currently being published.
              </m-m-tooltip>
            </m-m-button>
            <m-m-button
              variant="outlined"
              cy="button-discard"
              @click="onDiscard"
            >
              Discard
            </m-m-button>
          </template>
          <m-m-button
            v-else
            variant="outlined"
            prepend-icon="pen"
            cy="button-edit-filter"
            :is-disabled="isButtonEditFilterDisabled"
            @click="onEnterEditMode"
          >
            Edit
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
          <m-m-dropdown
            cy="filter-header-dropdown"
            :items="dropdownItems"
            max-width="218px"
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
      v-if="filter"
      :current-tab="currentTabName"
      :class="scrimmedClass"
    >
      <m-m-tab-item keep-alive :name="TABS[0].name">
        <Settings
          ref="settingsComponentRef"
          :data="basicInformationData"
          :mode="isInEditMode ? 'edit' : undefined"
          :service-provider-id="serviceProviderId"
          :filter-name="title"
          :filter="filter"
          :is-expandable-basic-info-open="isBasicInfoOpen"
          :is-expandable-filters-conditions-open="isFilterConditionsOpen"
          @update:basic-info-open="isBasicInfoOpen = $event"
          @update:filters-conditions-open="isFilterConditionsOpen = $event"
        />
      </m-m-tab-item>
      <m-m-tab-item keep-alive :name="TABS[1].name">
        <related-items
          v-if="filter.policy_types && parent_filters"
          :is-loading="isTableDataLoading"
          :policy-types="filter.policy_types"
          :parent-filters="parent_filters"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </div>
  <m-m-dialog
    :is-open="isConfirmDeleteDialogOpen"
    title="Delete filter"
    icon="trash"
    icon-color="error"
    subtitle="Are you sure you want to delete this filter?"
    cy="confirm-delete-filter"
    @close="toggleConfirmDelete"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-delete-filter"
        @click="toggleConfirmDelete"
      >
        Cancel
      </m-m-button>
      <m-m-button
        :is-disabled="isConfirmDeleteButtonSubmitDisabled"
        :loading="isConfirmDeleteButtonSubmitLoading"
        variant="danger"
        data-cy="button-confirm-delete-filter"
        @click="onSubmitDeleteFilter"
      >
        Delete
      </m-m-button>
    </template>
  </m-m-dialog>

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>

<style scoped lang="scss"></style>
