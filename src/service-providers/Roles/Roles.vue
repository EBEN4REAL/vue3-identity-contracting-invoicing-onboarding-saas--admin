<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { useRolesStore } from "~/service-providers/Roles/roles.service";
import { useRoute } from "vue-router";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  RoleRead,
  RoleWithUsagesRead,
} from "~/service-providers/Roles/roles.type";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import DialogAddRole from "./Dialogs/DialogAddRole.vue";
import DialogEditRole from "./Dialogs/DialogEditRole.vue";
import DialogDeleteRole from "./Dialogs/DialogDeleteRole.vue";
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

const rolesStore = useRolesStore();

const tableHeaders: TableHeader[] = [
  {
    label: "Name",
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
    label: "",
    key: "actions",
  },
];

const isRolesLoading: Ref<boolean> = ref(true);
const isDialogAddRolesOpen: Ref<boolean> = ref(false);
const isDialogEditRoleOpen: Ref<boolean> = ref(false);
const isDialogDeleteRoleOpen: Ref<boolean> = ref(false);
const roles: Ref<TableResponse<RoleRead> | null> = ref(null);
const currentlyEditingRole: Ref<RoleRead | undefined> = ref(undefined);
const currentlyDeletingRole: Ref<RoleRead | undefined> = ref(undefined);
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isRoleEditable = (role: RoleWithUsagesRead): boolean =>
  role?.editable ?? true;

const tableRowActionsDropdownItems = (role: RoleWithUsagesRead) => {
  const dropdownItems: TypeDropdownItem[] = [
    {
      label: "Edit",
      type: "button",
      hint: isConfigPublishing.value
        ? "You cannot edit this role as config is currently being published"
        : "",
      isDisabled:
        !isRoleEditable(role) ||
        isConfigPublishing.value ||
        uiStore.isSPViewerOnly,
      onClick: () => onOpenDialogEditRole(role),
    },
  ];
  if (role.deletable) {
    dropdownItems.push({
      label: "Delete",
      type: "button",
      color: "error",
      onClick: () => onOpenDialogDeleteRole(role),
      hint: deleteRoleHint.value(role.usages),
      isDisabled:
        Boolean(role.usages || isConfigPublishing.value) ||
        uiStore.isSPViewerOnly,
    });
  }

  return dropdownItems;
};

const deleteRoleHint: ComputedRef<(usages: number) => string> = computed(() => {
  return (usages: number): string => {
    if (usages === 1) {
      return "This role is being used by 1 policy. You can only delete this role if there are no references.";
    } else if (usages > 1) {
      return `This role is being used by ${usages} policies. You can only delete this role if there are no references.`;
    } else if (isConfigPublishing.value) {
      return "You cannot delete this role as config is currently being published";
    }
    return "";
  };
});

const fetchRoles = async (params: TableRequestParams) => {
  try {
    isRolesLoading.value = true;
    const response = await rolesStore.fetchRoles(
      route.params.service_provider_id as string,
      params,
    );
    if (response?.results?.length) {
      response?.results.forEach((role) => {
        role.hidden = role?.wizard?.hidden || false;
      });
    }
    roles.value = response;
    await fetchRolesUsages();
  } finally {
    isRolesLoading.value = false;
  }
};

const fetchRolesUsages = async () => {
  if (!roles.value) return;

  try {
    const fetchPromises = roles.value.results.map((role) =>
      policiesService
        .fetchRoleUsage(role.service_provider_id, role.id)
        .then((usages) => ({
          ...role,
          usages: usages.length,
        })),
    );
    roles.value.results = await Promise.all(fetchPromises);
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching roles usages",
      status: "error",
    });
  }
};

const onOpenDialogAddRole = () => {
  isDialogAddRolesOpen.value = true;
};

const onCloseDialogAddRole = async () => {
  isDialogAddRolesOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const onOpenDialogEditRole = (role: RoleRead) => {
  currentlyEditingRole.value = role;
  isDialogEditRoleOpen.value = true;
};

const onCloseDialogEditRole = async () => {
  isDialogEditRoleOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const onOpenDialogDeleteRole = (role: RoleRead) => {
  currentlyDeletingRole.value = role;
  isDialogDeleteRoleOpen.value = true;
};

const onCloseDialogDeleteRole = async () => {
  isDialogDeleteRoleOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "add_role",
    action: onOpenDialogAddRole,
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
    resource-id="oidc_claims.roles"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-table
      :headers="tableHeaders"
      :is-loading="isRolesLoading"
      :rows="roles?.results"
      :total-rows="roles?.total"
      show-search
      cy="table-roles"
      @update-params="fetchRoles"
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

  <dialog-add-role
    :is-open="isDialogAddRolesOpen"
    :is-config-publishing="isConfigPublishing"
    @close="onCloseDialogAddRole"
    @submit="fetchRoles"
  />

  <dialog-edit-role
    :is-open="isDialogEditRoleOpen"
    :role="currentlyEditingRole"
    :is-config-publishing="isConfigPublishing"
    @close="onCloseDialogEditRole"
    @submit="fetchRoles"
  />

  <dialog-delete-role
    :is-open="isDialogDeleteRoleOpen"
    :role="currentlyDeletingRole"
    :is-config-publishing="isConfigPublishing"
    @close="onCloseDialogDeleteRole"
    @submit="fetchRoles"
  />
</template>

<style scoped lang="scss"></style>
