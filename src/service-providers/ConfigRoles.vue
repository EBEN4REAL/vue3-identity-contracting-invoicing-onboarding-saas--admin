<script setup lang="ts">
import { onMounted, ref, Ref, computed, ComputedRef } from "vue";
import { policyTypesService } from "~/configuration/policy-types.service";
import { TypeDialogPoliciesDeleteData } from "./ConfigurationTabs/Policies/policies.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { usePolicyUxCategoriesStore } from "~/stores/policyUxCategories";
import { useRouter } from "vue-router";
import DialogPoliciesDelete from "~/service-providers/_shared/Dialogs/DialogPoliciesDelete.vue";
import { authService } from "~/auth/auth.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "./ConfigPublish/enums";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";
import { Button, DropdownItem } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const router = useRouter();
const roles: Ref<TableResponse<PolicyTypeRead> | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);
const serviceProviderId: Ref<string> = ref("");
const isPoliciesDeleteDialogOpen: Ref<boolean> = ref(false);
const dialogPoliciesDeleteData: Ref<TypeDialogPoliciesDeleteData | null> =
  ref(null);
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);
const policyUxCategoriesStore = usePolicyUxCategoriesStore();

const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Role Name",
    key: "external_facing_name",
    sortIcon: true,
    order: "asc",
    sortable: true,
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

const emptyState: EmptyStateType = {
  title: "Create your first role",
  description:
    "Roles are used to indicate levels of access to your application, when your application supports roles.",
  icon: "user-circle",
};

const manageRolesPermissionsDropdownItems: ComputedRef<DropdownItem[]> =
  computed(() => [
    {
      key: "manage_roles",
      action: () => {
        router.push(`/sp/${serviceProviderId.value}/roles`);
      },
    },
    {
      key: "manage_permissions",
      action: () => {
        router.push(`/sp/${serviceProviderId.value}/permissions`);
      },
    },
  ]);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_role",
    action: goToCreatePolicyType,
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
  {
    key: "actions_button",
    isDropdown: true,
    isOnlyIcon: true,
    dropdownItems: manageRolesPermissionsDropdownItems.value,
  },
]);

const handleUpdateParams = async (params: TableRequestParams) => {
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getRoles(params);
};

const detailedViewLink = (row: SPPolicyTypeRead) =>
  `/sp/${serviceProviderId.value}/policy-types/${row?.id}`;

const isDeleteRoleDisabled = (policy: SPPolicyTypeRead) => {
  return (
    policy.has_child_or_parent_policy_types ||
    policy.used_in_agreement_type ||
    isConfigPublishing.value
  );
};

const deletePolicyHintText = (policy: SPPolicyTypeRead) => {
  if (isDeleteRoleDisabled(policy)) {
    return "You cannot delete this role as there are active instances of it.";
  }
  if (isConfigPublishing.value) {
    return "You cannot delete this role as config is currently being published.";
  }
  return null;
};

const goToPolicyTypeDetails = (policy_type_id: string) => {
  router.push({
    name: "PolicyTypeDetail",
    params: {
      service_provider_id: serviceProviderId.value,
      policy_type_id,
    },
  });
};

const handleDeleteRole = async (policyId: string) => {
  try {
    await policyTypesService.deletePolicyType(
      serviceProviderId.value,
      policyId,
    );
    await getRoles();
    overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error.message || "Failed to delete role",
      status: "error",
    });
  } finally {
    isPoliciesDeleteDialogOpen.value = false;
  }
};

const handleRolesDeleteDialog = (policy: PolicyTypeRead | string) => {
  isPoliciesDeleteDialogOpen.value = !isPoliciesDeleteDialogOpen.value;
  dialogPoliciesDeleteData.value = {
    policyName: policy.name,
    policyId: policy.id,
  };
};

const isButtonCreateRoleDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const roleUxCategory = computed(() =>
  policyUxCategoriesStore.policyUxCategories.find(
    (category) => category.name === "Role",
  ),
);

const goToCreatePolicyType = () => {
  // set activeCategory in the store
  policyUxCategoriesStore.setActiveCategory(roleUxCategory?.value?.id || "");

  router.push({
    name: "NewPolicyType",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });
};

const isRoleDeletable = (role: SPPolicyTypeRead): boolean =>
  role?.deletable ?? true;

const isRoleEditable = (role: SPPolicyTypeRead): boolean =>
  role?.editable ?? true;

const dropdownItems = (row: SPPolicyTypeRead) => [
  {
    label: "View",
    type: "button",
    onClick: () => {
      goToPolicyTypeDetails(row.id);
    },
  },
  {
    label: "Edit",
    type: "link",
    isDisabled:
      !isRoleEditable(row) ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly,
    hint: isConfigPublishing.value
      ? "You cannot edit this role as config is currently being published"
      : "",
    to: `/sp/${serviceProviderId.value}/policy-types/${row.id}?editMode=true`,
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    hint: deletePolicyHintText(row),
    isDisabled:
      uiStore.isSPViewerOnly ||
      isDeleteRoleDisabled(row) ||
      !isRoleDeletable(row),
    onClick: () => handleRolesDeleteDialog(row),
  },
];

const getRoles = async (params?: TableRequestParams) => {
  isLoading.value = true;

  const updatedParams = {
    ...params,
    category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
  };
  try {
    const response = await policyTypesService.getPolicyTypes(
      serviceProviderId.value,
      updatedParams,
    );
    if (response?.results.length) {
      response?.results.forEach((role) => {
        role.hidden = role.wizard?.hidden || false;
      });
    }
    roles.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "An unknown error occurred while fetching roles",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  await policyUxCategoriesStore.fetchPolicyUxCategories();
});
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="roles.overview"
    :config-banner-cmp="ConfigPublishBanner"
    :buttons="buttons"
  >
    <section>
      <m-m-table
        cy="roles-table"
        :is-loading="isLoading"
        :rows="roles?.results || []"
        :empty-state="emptyState"
        :headers="TABLE_HEADERS"
        :total-rows="roles?.total || 0"
        show-search
        @update-params="handleUpdateParams"
      >
        <template #empty-state-button>
          <m-m-button
            variant="elevated"
            size="small"
            prepend-icon="plus-white"
            cy="empty-state-create-role-button"
            :is-disabled="isButtonCreateRoleDisabled"
            @click="goToCreatePolicyType"
          >
            Create Role
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
        </template>
        <template #external_facing_name="{ row }">
          <m-m-link
            :to="detailedViewLink(row)"
            font-weigth="500"
            :cy="`column-name-${row?.id}`"
          >
            {{ row.external_facing_name }}
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
              :items="dropdownItems(row)"
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
      </m-m-table></section
  ></m-m-overview-page>

  <m-m-config-banner />

  <DialogPoliciesDelete
    :is-open="isPoliciesDeleteDialogOpen"
    :data="dialogPoliciesDeleteData"
    @close-dialog="
      dialogPoliciesDeleteData &&
      handleRolesDeleteDialog(dialogPoliciesDeleteData.policyId as string)
    "
    @submit-dialog="
      dialogPoliciesDeleteData &&
      handleDeleteRole(dialogPoliciesDeleteData.policyId)
    "
  />
</template>
