<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { authService } from "~/auth/auth.service";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import DialogDeleteResourceType from "./DialogDeleteResourceType.vue";
import { useRouter } from "vue-router";
import { ResourceTypeRead } from "~/policies/policies.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { resourceTypesService } from "~/configuration/resource-types.service";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const serviceProviderId: Ref<string | null> = ref(null);
const isSPAdmin: Ref<boolean> = ref(false);
const isResourcesDeleteModalOpen: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const selectedResource: Ref<unknown | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);
const router = useRouter();
const resources: Ref<TableResponse<ResourceTypeRead>> = ref(null);
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);
const emptyState: EmptyStateType = {
  icon: sectionIcons["configuration"],
  title: "Create your first resource",
  description:
    "A resource is any asset, data, system, or functionality that requires access control.",
};
const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isButtonCreateResourceDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const onDeleteResource = async () => {
  await fetchResourceTypes({ limit: "10", offset: "0" });
  toggleDeleteDialog();
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};
const fetchResourceTypes = async (params: TableRequestParams) => {
  try {
    isLoading.value = true;
    const userProfile = await authService.getProfile();

    serviceProviderId.value = userProfile?.sp_org || null;

    const response = await resourceTypesService.getResourcesTypes(
      serviceProviderId.value as string,
      params ? params : { limit: ITEMS_PER_PAGE[0], offset: "0" },
    );
    if (response?.results?.length) {
      response?.results.forEach((resource) => {
        resource.hidden = resource?.wizard?.hidden || false;
      });
    }
    resources.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching resources",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};
const toggleDeleteDialog = () => {
  isResourcesDeleteModalOpen.value = !isResourcesDeleteModalOpen.value;
};

const detailedViewLink = (row: ResourceTypeRead) =>
  `/sp/${serviceProviderId.value}/resources/${row?.id}`;

onMounted(async () => {
  isSPAdmin.value = await authService.isUserSPAdmin();
  isSPEditor.value = await authService.isUserSPEditor();
  // await unpublishedChangesStore.getUnpublishedConfig();
  // await unpublishedChangesStore.getConfigDetails();
});

const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Resource name",
    key: "name",
    sortIcon: true,
    order: "asc",
    sortName: "name",
    sortable: true,
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "Used in",
    key: "used_in",
  },
  {
    label: "Attributes",
    key: "number_of_attributes",
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
  },
];

const deleteResourceHint: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this resource as config is currently being published"
    : "",
);

const isResourceDeletable = (resource: ResourceTypeRead): boolean =>
  resource?.deletable ?? true;

const isResourceEditable = (resource: ResourceTypeRead): boolean =>
  resource?.editable ?? true;

const dropdownItems = (resource: ResourceTypeRead): TypeDropdownItem[] => [
  {
    label: "View",
    type: "button",
    onClick: () =>
      router.push(`/sp/${serviceProviderId.value}/resources/${resource.id}`),
  },
  {
    label: "Edit",
    type: "button",
    hint: isConfigPublishing.value
      ? "You cannot edit this resource as config is currently being published"
      : "",
    isDisabled:
      !isResourceEditable(resource) ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly,
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/resources/${resource.id}`,
        query: { editMode: "true" },
      });
    },
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    onClick: toggleDeleteDialog,
    isDisabled:
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly ||
      !isResourceDeletable(resource),
    hint: deleteResourceHint.value,
  },
];

const onCreateResource = () => {
  resourceTypesService.state.resourceType = null;
  router.push({
    name: "ResourceDetailsNew",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_resource",
    action: () => onCreateResource(),
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="resources.overview"
    :config-banner-cmp="ConfigPublishBanner"
    :buttons="buttons"
  >
    <div class="mm-resources">
      <m-m-table
        :is-loading="isLoading"
        :headers="TABLE_HEADERS"
        cy="resources-table"
        :rows="resources?.results || []"
        :total-rows="resources?.total"
        show-search
        :empty-state="emptyState"
        @update-params="fetchResourceTypes"
      >
        <template #empty-state-button>
          <m-m-button
            variant="elevated"
            size="small"
            cy="empty-state-create-resource-button"
            prepend-icon="plus-white"
            :is-disabled="isButtonCreateResourceDisabled"
            @click="onCreateResource"
          >
            Create resource
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
        </template>
        <template #created_date="{ row }">
          <m-m-formatted-date
            :raw-date="row.created_date"
            format="D MMM YYYY, HH:mm"
          />
        </template>
        <template #name="{ row }">
          <m-m-link
            :to="detailedViewLink(row)"
            font-weigth="500"
            :cy="`name-${row?.id}`"
          >
            {{ row.name }}
          </m-m-link>
        </template>
        <template #actions="{ row }">
          <div class="mm-flex mm-flex-justify-end">
            <m-m-dropdown
              list-side="left"
              :items="dropdownItems(row)"
              :cy="`actions-dropdown-${row.id}`"
              max-width="218px"
            >
              <template #activator>
                <m-m-button
                  prepend-icon="dots-vertical"
                  variant="text"
                  :cy="`actions-${row.id}`"
                  @click="selectedResource = row"
                />
              </template>
            </m-m-dropdown>
          </div>
        </template>
      </m-m-table></div
  ></m-m-overview-page>

  <m-m-config-banner />

  <dialog-delete-resource-type
    :service-provider-id="serviceProviderId"
    :resource-id="selectedResource?.id"
    :resource-name="selectedResource?.name"
    :is-open="isResourcesDeleteModalOpen"
    @close="toggleDeleteDialog"
    @delete="onDeleteResource"
  />
</template>

<style scoped lang="scss">
.mm-resources {
  &-header {
    display: flex;
    justify-content: space-between;
  }
}
</style>
