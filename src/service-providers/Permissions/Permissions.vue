<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { usePermissionsStore } from "~/service-providers/Permissions/permissions.service";
import { useRoute } from "vue-router";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  PermissionRead,
  PermissionWithUsagesRead,
} from "~/service-providers/Permissions/permissions.type";
import DialogAddPermission from "./Dialogs/DialogAddPermission.vue";
import DialogEditPermission from "./Dialogs/DialogEditPermission.vue";
import DialogDeletePermission from "./Dialogs/DialogDeletePermission.vue";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { policiesService } from "~/service-providers/policies.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import { useUiStore } from "~/stores/useUiStore";

const route = useRoute();
const uiStore = useUiStore();

const permissionsStore = usePermissionsStore();

const tableHeaders: TableHeader[] = [
  {
    label: "Name",
    key: "name",
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "",
    key: "actions",
  },
];

const isPermissionsLoading: Ref<boolean> = ref(true);
const isLoading: Ref<boolean> = ref(false);
const isDialogAddPermissionsOpen: Ref<boolean> = ref(false);
const isDialogEditPermissionOpen: Ref<boolean> = ref(false);
const isDialogDeletePermissionOpen: Ref<boolean> = ref(false);
const permissions: Ref<TableResponse<PermissionRead> | null> = ref(null);
const currentlyEditingPermission: Ref<PermissionRead | undefined> =
  ref(undefined);
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);
const currentlyDeletingPermission: Ref<PermissionRead | undefined> =
  ref(undefined);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isPermissionsEditable = (permission: PermissionWithUsagesRead): boolean =>
  permission?.editable ?? true;

const tableRowActionsDropdownItems = (permission: PermissionWithUsagesRead) => {
  const dropdownItems: TypeDropdownItem[] = [
    {
      label: "Edit",
      type: "button",
      hint: isConfigPublishing.value
        ? "You cannot edit this permission as config is currently being published"
        : "",
      isDisabled:
        isConfigPublishing.value ||
        uiStore.isSPViewerOnly ||
        !isPermissionsEditable(permission),
      onClick: () => onOpenDialogEditPermission(permission),
    },
  ];
  if (permission.deletable) {
    dropdownItems.push({
      label: "Delete",
      type: "button",
      color: "error",
      onClick: () => onOpenDialogDeletePermission(permission),
      hint: deletePermissionHint.value(permission.usages),
      isDisabled: Boolean(
        permission.usages || isConfigPublishing.value || uiStore.isSPViewerOnly,
      ),
    });
  }

  return dropdownItems;
};

const deletePermissionHint: ComputedRef<(usages: number) => string> = computed(
  () => {
    return (usages: number): string => {
      if (usages === 1) {
        return "This permission is being used by 1 Policy. You can only delete this permission if there are no references.";
      } else if (usages > 1) {
        return `This permission is being used by ${usages} Policies. You can only delete this permission if there are no references.`;
      } else if (isConfigPublishing.value) {
        return "You cannot delete this permission as config currently being published";
      }
      return "";
    };
  },
);

const fetchPermissions = async (params: TableRequestParams) => {
  try {
    isPermissionsLoading.value = true;
    const response = await permissionsStore.fetchPermissions(
      route.params.service_provider_id as string,
      params,
    );
    if (response?.results?.length) {
      response?.results.forEach((permission) => {
        permission.hidden = permission?.wizard?.hidden || false;
      });
    }
    permissions.value = response;
    await fetchPermissionsUsages();
  } finally {
    isPermissionsLoading.value = false;
  }
};

const fetchPermissionsUsages = async () => {
  if (!permissions.value) return;

  try {
    isLoading.value = true;
    const fetchPromises = permissions.value.results.map((permission) =>
      policiesService
        .fetchPermissionUsage(
          route.params.service_provider_id as string,
          permission.id,
        )
        .then((usages) => ({
          ...permission,
          usages: usages.length,
        })),
    );
    permissions.value.results = await Promise.all(fetchPromises);
  } catch (err) {
    isLoading.value = false;
  }
};

const onOpenDialogAddPermission = () => {
  isDialogAddPermissionsOpen.value = true;
};

const onCloseDialogAddPermission = async () => {
  isDialogAddPermissionsOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const onOpenDialogEditPermission = (permission: PermissionRead) => {
  currentlyEditingPermission.value = permission;
  isDialogEditPermissionOpen.value = true;
};

const onCloseDialogEditPermission = async () => {
  isDialogEditPermissionOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const onOpenDialogDeletePermission = (permission: PermissionRead) => {
  currentlyDeletingPermission.value = permission;
  isDialogDeletePermissionOpen.value = true;
};

const onCloseDialogDeletePermission = async () => {
  isDialogDeletePermissionOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "add_permission",
    action: onOpenDialogAddPermission,
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
    resource-id="oidc_claims.permissions"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-table
      :headers="tableHeaders"
      :is-loading="isPermissionsLoading"
      :rows="permissions?.results"
      :total-rows="permissions?.total"
      show-search
      cy="table-permissions"
      @update-params="fetchPermissions"
    >
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            max-width="220px"
            list-side="left"
            :cy="`actions-dropdown-${row.id}`"
            :items="tableRowActionsDropdownItems(row)"
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
      </template> </m-m-table
  ></m-m-overview-page>

  <dialog-add-permission
    :is-open="isDialogAddPermissionsOpen"
    :is-config-publishing="isConfigPublishing"
    @close="onCloseDialogAddPermission"
    @submit="fetchPermissions"
  />

  <dialog-edit-permission
    :is-open="isDialogEditPermissionOpen"
    :permission="currentlyEditingPermission"
    :is-config-publishing="isConfigPublishing"
    @close="onCloseDialogEditPermission"
    @submit="fetchPermissions"
  />

  <dialog-delete-permission
    :is-open="isDialogDeletePermissionOpen"
    :permission="currentlyDeletingPermission"
    :is-config-publishing="isConfigPublishing"
    @close="onCloseDialogDeletePermission"
    @submit="fetchPermissions"
  />
</template>

<style scoped lang="scss"></style>
