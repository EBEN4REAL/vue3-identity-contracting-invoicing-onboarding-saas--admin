<script setup lang="ts">
import { computed, onMounted, ref, Ref, ComputedRef, watch } from "vue";
import {
  NavigationGuardNext,
  onBeforeRouteLeave,
  useRoute,
  useRouter,
} from "vue-router";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  TypeValidatorFilterCondition,
  TypeFilterBasicInformationData,
} from "~/service-providers/Filters/Filter/Tabs/types";
import { TypeComparisonOperator } from "~/service-providers/filters.type";
import {
  FilterItem,
  FilterCreate,
  FilterRead,
  SettingsTabComponentType,
} from "~/service-providers/Filters/filters.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { filtersService } from "~/configuration/filters.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import Settings from "../Settings/Settings.vue";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";

const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
];
const route = useRoute();
const router = useRouter();
const serviceProviderId: Ref<string> = ref(
  route.params.service_provider_id.toString(),
);
const settingsComponentRef: Ref<SettingsTabComponentType | null> = ref(null);
const isServiceProvider: Ref<boolean> = ref(false);
const currentTabName: Ref<string> = ref(TABS[0].name);
const filterPlaceholder = "New Filter";
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isFilterConditionsOpen: Ref<boolean> = ref(true);
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

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "filters",
    label: "Filters",
    to: "/sp/config/filters",
  },
  {
    id: settingsComponentRef.value?.basicInformationEditRef?.form.name || "",
    label:
      settingsComponentRef.value?.basicInformationEditRef?.form.name ||
      filterPlaceholder,
  },
]);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isLoading: Ref<boolean> = ref(false);

const filterName = computed(
  () =>
    settingsComponentRef.value?.basicInformationEditRef?.form.name ||
    filterPlaceholder,
);

const basicInformationData = computed(
  (): TypeFilterBasicInformationData => ({
    name: filtersService.state.filter?.name || "",
    description: filtersService.state.filter?.description || null,
  }),
);
const initialPayload: ComputedRef<FilterCreate> = computed(() => ({
  name: "",
  operator: "AND",
  filters: [],
  filter_items: [
    {
      value: null,
      attribute_source: null,
      attribute_type: "",
      operator: null,
    },
  ],
}));

const payload: ComputedRef<FilterCreate> = computed(() => {
  const filterConditionData: FilterCreate = {
    name: settingsComponentRef.value?.basicInformationEditRef?.form.name || "",
    description:
      settingsComponentRef.value?.basicInformationEditRef?.form.description ||
      null,
    operator:
      settingsComponentRef.value?.filterConditionsEditRef?.operator ||
      TypeComparisonOperator.AND,
    filters: settingsComponentRef.value?.filterConditionsEditRef?.filters.map(
      (filter: FilterRead) => filter.id,
    ),
    filter_items: [],
  };

  if (!filterConditionData.description) delete filterConditionData.description;

  if (
    settingsComponentRef.value?.filterConditionsEditRef?.filter_items.length
  ) {
    filterConditionData.filter_items =
      settingsComponentRef.value?.filterConditionsEditRef.filter_items.map(
        (filterConditionItem: FilterItem) => ({
          value: filterConditionItem.value,
          attribute_source: filterConditionItem.attribute_source,
          attribute_type: filterConditionItem.attribute_type,
          operator: filterConditionItem.operator,
        }),
      );
  }

  return filterConditionData;
});

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  }
  router.push({
    name: "Filters",
  });
};

const submitForm = async () => {
  hasUnsavedChanges.value = false;
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
  try {
    isLoading.value = true;
    const filter: FilterRead = await filtersService.postFilter(
      filterEmptyPropertiesFromObject(payload.value),
      serviceProviderId.value,
    );
    isLoading.value = false;
    router.push({
      name: "FilterDetails",
      params: {
        service_provider_id: serviceProviderId.value,
        filter_id: filter.id,
      },
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
    isLoading.value = false;
  }
};

onMounted(async () => {
  const serviceProvider = await serviceProvidersService.getServiceProvider(
    serviceProviderId.value,
  );
  isServiceProvider.value = !!serviceProvider.id;
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

watch(
  () => payload.value,
  () => {
    hasUnsavedChanges.value =
      JSON.stringify(initialPayload.value) !== JSON.stringify(payload.value);
  },
);
</script>

<template>
  <div v-if="isServiceProvider">
    <m-m-page-header
      base-key="configuration.filters.filter_new"
      :params="{
        filterName,
        filterDescription:
          settingsComponentRef?.basicInformationEditRef?.form?.description,
      }"
      icon="filter"
      :breadcrumbs="breadcrumbs"
    >
      <template #header-controls>
        <div class="mm-flex mm-flex-gap-6">
          <m-m-button
            cy="button-save-filter"
            :is-disabled="isConfigPublishing"
            :loading="isLoading"
            @click="submitForm"
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
      <m-m-tabs
        v-model="currentTabName"
        :items="TABS"
        :is-in-edit-mode="true"
      />
    </m-m-teleport>
    <m-m-tab-items :current-tab="currentTabName">
      <m-m-tab-item keep-alive :name="TABS[0].name">
        <Settings
          ref="settingsComponentRef"
          :data="basicInformationData"
          mode="create"
          :items="filtersService.state.filter?.filter_items"
          :nested-filters-ids="filtersService.state.filter?.filters"
          :comparison-operator="filtersService.state.filter?.operator"
          :filter="filtersService.state?.filter"
          :service-provider-id="serviceProviderId"
          :is-expandable-basic-info-open="isBasicInfoOpen"
          :is-expandable-filters-conditions-open="isFilterConditionsOpen"
          @update:basic-info-open="isBasicInfoOpen = $event"
          @update:filters-conditions-open="isFilterConditionsOpen = $event"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </div>
  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="confirmLeave(nextRef)"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>
