<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { authService } from "~/auth/auth.service";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  ResourceAttributeTypeInUseRead,
  ResourceAttributeTypeRead,
} from "~/policies/policies.types";
import ResourceAttributesCreateModal from "./ResourceAttributesCreateModal.vue";
import ResourceAttributesEditModal from "./ResourceAttributesEditModal.vue";
import ResourceAttributesDeleteDialog from "./ResourceAttributesDeleteModal.vue";
import { SELECT_OPTIONS_MAP } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { handleResources } from "../handleEnums";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const serviceProviderId: Ref<string | null> = ref(null);
const isSPAdmin: Ref<boolean> = ref(false);
const isResourceAttributesDialog: Ref<boolean> = ref(false);
const isEditDialog: Ref<boolean> = ref(false);
const isDeleteDialog: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const isLoading: Ref<boolean> = ref(true);
const selectedResourceAttribute: Ref<ResourceAttributeTypeRead | null> =
  ref(null);
const resourceAttributes: Ref<TableResponse<ResourceAttributeTypeRead> | null> =
  ref(null);
const tableRequestParams: Ref<TableRequestParams> = ref({
  limit: "10",
  offset: "0",
});

const emptyState: EmptyStateType = {
  icon: sectionIcons["configuration"],
  title: "Create your first resource attribute",
  description:
    "Resources can have associated attributes (e.g., classification level, owner, location) that can be used in making access decisions.",
};

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isButtonCreateResourceAttributeDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const toggleCreateDialog = () => {
  isResourceAttributesDialog.value = !isResourceAttributesDialog.value;
};

const toggleEditDialog = () => {
  isEditDialog.value = !isEditDialog.value;
};

const toggleDeleteDialog = () => {
  isDeleteDialog.value = !isDeleteDialog.value;
};
const handleCreateResourceAttributes = async () => {
  try {
    await getResourceAttributeTypes(tableRequestParams.value);
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error creating resource attribute(s)",
      status: "error",
    });
  }
};

const getResourceAttributeTypes = async (params: TableRequestParams) => {
  isLoading.value = true;
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  try {
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || null;
    }
    tableRequestParams.value = params;
    const response =
      await resourceAttributeTypesService.getResourceAttributeTypes(
        serviceProviderId.value as string,
        params,
      );
    if (response?.results?.length) {
      response?.results.forEach((resourceAttribute) => {
        resourceAttribute.hidden = resourceAttribute?.wizard?.hidden || false;
      });
    }
    resourceAttributes.value = response;
    resourceAttributes.value?.results.map((element) => {
      handleResources(element);
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching resource attributes",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  isSPAdmin.value = await authService.isUserSPAdmin();
  isSPEditor.value = await authService.isUserSPEditor();
});

const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Name",
    key: "name",
    sortIcon: true,
    order: "asc",
    sortable: true,
  },
  {
    label: "Format",
    key: "format_option",
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

const isDeleteResourceAttDisabled = (
  resource: ResourceAttributeTypeInUseRead,
) => {
  return resource.in_use;
};

const isResourceAttributeDeletable = (
  resourceAttribute: ResourceAttributeTypeInUseRead,
): boolean => resourceAttribute?.deletable ?? true;

const isResourceAttributeEditable = (
  resourceAttribute: ResourceAttributeTypeInUseRead,
): boolean => resourceAttribute?.editable ?? true;

const dropdownItems = (row) => [
  {
    label: "Edit",
    type: "button",
    hint: isConfigPublishing.value
      ? "You cannot edit this resource attribute as config is currently being published"
      : "",
    isDisabled:
      !isResourceAttributeEditable(row) ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly,
    onClick: toggleEditDialog,
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    hint: deleteResourceAttHintText.value(row),
    isDisabled:
      isDeleteResourceAttDisabled(row) ||
      uiStore.isSPViewerOnly ||
      isConfigPublishing.value ||
      !isResourceAttributeDeletable(row),
    onClick: toggleDeleteDialog,
  },
];

const deleteResourceAttHintText: ComputedRef<
  () => ResourceAttributeTypeInUseRead
> = computed(
  () =>
    (resource: ResourceAttributeTypeInUseRead): string | null => {
      if (isDeleteResourceAttDisabled(resource)) {
        return "You cannot delete this resource as there are active instances of it";
      }
      if (isConfigPublishing.value) {
        return "You cannot delete this resource as config is currently being published.";
      }
      return null;
    },
);

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_resource_attribute",
    action: () => toggleCreateDialog(),
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);
</script>

<template>
  <m-m-overview-page
    resource-id="resource_attributes.overview"
    :config-banner-cmp="ConfigPublishBanner"
    :buttons="buttons"
  >
    <div class="mm-resource-attributes">
      <m-m-table
        :headers="TABLE_HEADERS"
        :is-loading="isLoading"
        cy="resource-attributes-table"
        :rows="resourceAttributes?.results || []"
        :total-rows="resourceAttributes?.total"
        show-search
        :empty-state="emptyState"
        @update-params="getResourceAttributeTypes"
      >
        <template #empty-state-button>
          <m-m-button
            variant="elevated"
            cy="empty-state-create-resource-attribute-button"
            size="small"
            prepend-icon="plus-white"
            :is-disabled="isButtonCreateResourceAttributeDisabled"
            @click="toggleCreateDialog"
          >
            Create resource attribute
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
        </template>
        <template #name="{ row }">
          <span class="font-weight-500"> {{ row.name }} </span>
        </template>
        <template #format_option="{ row }">
          <span> {{ SELECT_OPTIONS_MAP.get(row.format_option) }} </span>
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
              :items="dropdownItems(row)"
              max-width="218px"
              :cy="`actions-dropdown-${row.id}`"
            >
              <template #activator>
                <m-m-button
                  prepend-icon="dots-vertical"
                  variant="text"
                  :cy="`actions-${row.id}`"
                  @click="selectedResourceAttribute = row"
                />
              </template>
            </m-m-dropdown>
          </div>
        </template>
      </m-m-table></div
  ></m-m-overview-page>

  <m-m-config-banner />

  <ResourceAttributesCreateModal
    :is-open="isResourceAttributesDialog"
    :service-provider-id="serviceProviderId as string"
    :is-config-publishing="isConfigPublishing"
    @close="toggleCreateDialog"
    @submit="handleCreateResourceAttributes"
  />
  <ResourceAttributesEditModal
    :selected-resource-attribute="
      selectedResourceAttribute as ResourceAttributeTypeRead
    "
    :is-open="isEditDialog"
    :service-provider-id="serviceProviderId as string"
    :is-config-publishing="isConfigPublishing"
    @close="toggleEditDialog"
    @submit="getResourceAttributeTypes"
  />
  <ResourceAttributesDeleteDialog
    :is-open="isDeleteDialog"
    :is-config-publishing="isConfigPublishing"
    :data="{
      service_provider_id: serviceProviderId,
      id: selectedResourceAttribute?.id,
      name: selectedResourceAttribute?.name,
    }"
    @close="toggleDeleteDialog"
    @submit="getResourceAttributeTypes"
  />
</template>

<style scoped lang="scss">
.mm-resource-attributes {
  &-header {
    display: flex;
    justify-content: space-between;
  }
}
</style>
