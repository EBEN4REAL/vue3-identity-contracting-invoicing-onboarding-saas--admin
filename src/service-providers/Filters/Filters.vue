<script setup lang="ts">
import { computed, ComputedRef, onMounted, Ref, ref } from "vue";
import { useRouter } from "vue-router";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { authService } from "~/auth/auth.service";
import DialogFiltersDelete from "./DialogFiltersDelete.vue";
import { FilterRead, TypeDialogFiltersDeleteData } from "./filters.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { filtersService } from "~/configuration/filters.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import MMPageHeader from "~/mm_ui_kit/src/components/MMPageHeader.vue";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();
const router = useRouter();
const serviceProviderId: Ref<string | null> = ref(null);
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const filters: Ref<TableResponse<FilterRead>> = ref(null);
const isFiltersDeleteDialogOpen: Ref<boolean> = ref(false);
const dialogfiltersDeleteData: Ref<TypeDialogFiltersDeleteData | null> =
  ref(null);
const isConfirmDeleteButtonSubmitDisabled: Ref<boolean> = ref(false);
const isConfirmDeleteButtonSubmitLoading: Ref<boolean> = ref(false);
const pageHeaderRef: Ref<InstanceType<typeof MMPageHeader> | null> = ref(null);

const handleFiltersDeleteDialog = (filter: FilterRead | string) => {
  isFiltersDeleteDialogOpen.value = !isFiltersDeleteDialogOpen.value;
  dialogfiltersDeleteData.value = {
    filterId: filter.id,
    filterName: filter.name,
  };
};
const isLoading: Ref<boolean> = ref(true);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isButtonCreateFilterDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const handleDeleteFilter = async (filterId: string) => {
  isConfirmDeleteButtonSubmitDisabled.value = true;
  isConfirmDeleteButtonSubmitLoading.value = true;

  try {
    await filtersService.deleteFilter(
      serviceProviderId.value as string,
      filterId,
    );
    await getFilters({ limit: ITEMS_PER_PAGE[0], offset: "0" });
    isFiltersDeleteDialogOpen.value = false;
    pageHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
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

const getFilters = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || null;
    }
    const response = await filtersService.getFilters(
      serviceProviderId.value as string,
      params,
    );
    if (response?.results?.length) {
      response?.results.forEach((filter) => {
        filter.hidden = filter?.wizard?.hidden || false;
      });
    }
    filters.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "An error occurred while fetching filters",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};
const emptyState: EmptyStateType = {
  icon: sectionIcons["configuration"],
  title: "Create your first filter",
  description:
    "Filters allow for more granular and dynamic access control decisions based on various attributes and contexts.",
  learnMoreHref:
    "https://docs.myveriam.com/getting-started/configure-your-access-requirements#filters",
};
const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Filter name",
    key: "name",
    sortable: true,
    sortIcon: true,
    order: "asc",
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "Created date",
    key: "created_date",
    sortIcon: true,
    order: "desc",
    sortable: true,
    defaultSortItem: true,
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const updateTableParamsHandler = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  await getFilters(params);
};

const onFilterViewDetails = (filter_id: string) => {
  router.push({
    name: "FilterDetails",
    params: {
      service_provider_id: serviceProviderId.value,
      filter_id,
    },
  });
};

const isFilterDeletable = (filter: FilterRead): boolean =>
  filter?.deletable ?? true;

const isFilterEditable = (filter: FilterRead): boolean =>
  filter?.editable ?? true;

const getDropdownItems: ComputedRef<(row: FilterRead) => TypeDropdownItem[]> =
  computed(() => {
    return (row: FilterRead) => [
      {
        label: "View",
        type: "button",
        onClick: () => onFilterViewDetails(row.id),
      },
      {
        label: "Edit",
        type: "button",
        hint: isConfigPublishing.value
          ? "You cannot edit this filter as config is currently being published"
          : "",
        isDisabled:
          isConfigPublishing.value ||
          uiStore.isSPViewerOnly ||
          !isFilterEditable(row),
        onClick: () =>
          router.push({
            path: `/sp/${serviceProviderId.value}/filters/${row.id}`,
            query: { editMode: "true" },
          }),
      },
      {
        label: "Duplicate",
        type: "button",
        hint: isConfigPublishing.value
          ? "You cannot duplicate this filter as config is currently being published"
          : "",
        isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
        onClick: () =>
          router.push({
            path: `/sp/${serviceProviderId.value}/filters/${row.id}`,
            query: { duplicateMode: "true" },
          }),
      },
      {
        label: "Delete",
        type: "button",
        color: "error",
        hint: isDeleteFilterDisabled(row)
          ? deleteFilterHintText(row)
          : deleteFilterConfigHintText.value,
        isDisabled:
          isDeleteFilterDisabled(row) ||
          isConfigPublishing.value ||
          !isFilterDeletable(row) ||
          uiStore.isSPViewerOnly,
        onClick: () => handleFiltersDeleteDialog(row),
      },
    ];
  });

const onFilterCreate = () => {
  filtersService.state.filter = null;
  router.push({
    name: "FilterDetailsNew",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_filter",
    action: onFilterCreate,
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);

const isDeleteFilterDisabled = (filter: FilterRead) => {
  return filter.parent_filters?.length > 0 || filter.policy_types?.length > 0;
};

const deleteFilterHintText = (filter: FilterRead) => {
  return isDeleteFilterDisabled(filter)
    ? "You cannot delete this filter as there are active instances of it."
    : null;
};

const deleteFilterConfigHintText: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this filter as config is currently being published"
    : "",
);

onMounted(async () => {
  isSPAdmin.value = await authService.isUserSPAdmin();
  isSPEditor.value = await authService.isUserSPEditor();
});
</script>

<template>
  <m-m-overview-page
    ref="pageHeaderRef"
    resource-id="filters.overview"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <div>
      <m-m-table
        :is-loading="isLoading"
        :headers="TABLE_HEADERS"
        :rows="filters?.results"
        :total-rows="filters?.total"
        cy="filters-table"
        show-search
        :empty-state="emptyState"
        @update-params="updateTableParamsHandler"
      >
        <template #empty-state-button>
          <m-m-button
            variant="elevated"
            size="small"
            prepend-icon="plus-white"
            cy="empty-state-create-filter"
            :is-disabled="isButtonCreateFilterDisabled"
            @click="onFilterCreate"
          >
            Create filter
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
        </template>
        <template #name="{ row }">
          <m-m-link
            :to="`/sp/${serviceProviderId}/filters/${row.id}`"
            font-weigth="500"
            :data-cy="`column-name-${row.id}`"
          >
            {{ row.name }}
          </m-m-link>
        </template>
        <template #description="{ row }">
          <m-m-text-ellipsis :data-cy="`column-description-${row.id}`"
            >{{ row.description }}
          </m-m-text-ellipsis>
        </template>
        <template #created_date="{ row }">
          <m-m-formatted-date
            :raw-date="row.created_date"
            format="D MMM YYYY, HH:mm"
          />
        </template>
        <template #actions="{ row }">
          <div class="mm-flex mm-flex-justify-end">
            <m-m-dropdown
              list-side="left"
              :items="getDropdownItems(row)"
              :cy="`actions-dropdown-${row.id}`"
              max-width="218px"
            >
              <template #activator>
                <m-m-button
                  prepend-icon="dots-vertical"
                  variant="text"
                  :cy="`actions-${row.id}`"
                />
              </template>
            </m-m-dropdown>
          </div>
        </template>
      </m-m-table></div
  ></m-m-overview-page>
  <DialogFiltersDelete
    :is-open="isFiltersDeleteDialogOpen"
    :data="dialogfiltersDeleteData"
    :is-confirm-delete-button-submit-disabled="
      isConfirmDeleteButtonSubmitDisabled
    "
    :is-confirm-delete-button-submit-loading="
      isConfirmDeleteButtonSubmitLoading
    "
    @close-dialog="
      dialogfiltersDeleteData &&
      handleFiltersDeleteDialog(dialogfiltersDeleteData.filterId)
    "
    @submit-dialog="
      dialogfiltersDeleteData &&
      handleDeleteFilter(dialogfiltersDeleteData.filterId)
    "
  />
  <!--Can be removed once we have translations -->
  <m-m-config-banner />
</template>

<style scoped lang="scss">
.filters {
  color: #4d5761;
  font-size: 14px;
  font-weight: 400;
  line-height: 20px;
}
</style>
