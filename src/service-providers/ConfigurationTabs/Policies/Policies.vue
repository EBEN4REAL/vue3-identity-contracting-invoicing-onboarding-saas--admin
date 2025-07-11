<script setup lang="ts">
import { Ref, computed, onMounted, ref, ComputedRef } from "vue";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "../../../mm_ui_kit/src/types/table.types";
import { authService } from "../../../auth/auth.service";
import { ITEMS_PER_PAGE } from "../../../common/constants";
import { TypeDialogPoliciesDeleteData } from "./policies.types";
import { capitalizeFirstLetter } from "../../../mm_ui_kit/src/helpers/utils";
import DialogPoliciesDelete from "~/service-providers/_shared/Dialogs/DialogPoliciesDelete.vue";
import router from "~/router/index.router";
import { usePolicyUxCategoriesStore } from "~/stores/policyUxCategories";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";
import { POLICY_TYPE_CATEGORY } from "~/service-providers/PolicyTypeDetail/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { Button, DropdownItem } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../../ConfigPublishBanner/ConfigPublishBanner.vue";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const serviceProviderId: Ref<string> = ref("");
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const policies: Ref<TableResponse<SPPolicyTypeRead> | null> = ref(null);
const isPoliciesDeleteDialogOpen: Ref<boolean> = ref(false);
const dialogPoliciesDeleteData: Ref<TypeDialogPoliciesDeleteData | null> =
  ref(null);
const isLoading: Ref<boolean> = ref(false);
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const handlePoliciesDeleteDialog = (policy: SPPolicyTypeRead | string) => {
  isPoliciesDeleteDialogOpen.value = !isPoliciesDeleteDialogOpen.value;
  dialogPoliciesDeleteData.value = {
    policyName: policy.name,
    policyId: policy.id,
  };
};

const handleDeletePolicy = async (policyId: string) => {
  await policyTypesService.deletePolicyType(serviceProviderId.value, policyId);
  await getPolicyTypes({ limit: ITEMS_PER_PAGE[0], offset: "0" });
  isPoliciesDeleteDialogOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const getPolicyTypes = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    const response = await policyTypesService.getPolicyTypes(
      serviceProviderId.value,
      {
        ...params,
        category_id: POLICY_TYPE_CATEGORY,
      },
    );
    if (response?.results?.length) {
      response?.results.forEach((policy) => {
        policy.hidden = policy?.wizard?.hidden || false;
      });
    }
    policies.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "An error while fetching policies",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const policyUxCategoriesStore = usePolicyUxCategoriesStore();

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const policyUxCategories = computed(
  () => policyUxCategoriesStore.policyUxCategories,
);

const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Policy name",
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
  title: "Create your first policy",
  description:
    " Policies are used to define the rules and conditions under which access to resources is granted or denied.",
  learnMoreHref:
    "https://docs.myveriam.com/getting-started/configure-your-access-requirements#policies",
  icon: "shield-check-outline",
};

const isButtonCreatePolicyDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const createDropdownItems = computed(() => {
  // iterate through policyUxCategories and create dropdown items
  const items = policyUxCategories.value.map((category) => {
    return {
      label: `Create new ${capitalizeFirstLetter(category.name)}`,
      type: "button",
      onClick: () => goToCreatePolicyType(category.id),
    };
  });

  return items;
});

const getUxCategoryName = (categoryId: string) => {
  const category = policyUxCategories.value.find(
    (category) => category.id === categoryId,
  );

  return category?.name;
};

const getUxCategoryId = (categoryName: string) => {
  const category = policyUxCategories.value.find(
    (category) => category.name === categoryName,
  );

  return category?.id;
};

const isPolicyDeletable = (policy: SPPolicyTypeRead): boolean =>
  policy?.deletable ?? true;

const isPolicyEditable = (policy: SPPolicyTypeRead): boolean =>
  policy?.editable ?? true;

const getDropdownItems: ComputedRef<
  (row: SPPolicyTypeRead) => TypeDropdownItem[]
> = computed(() => {
  return (row: SPPolicyTypeRead) => [
    {
      label: "View",
      type: "button",
      onClick: () => {
        goToPolicyTypeDetails(row.id);
      },
    },
    {
      label: "Edit",
      type: "button",
      isDisabled:
        !isPolicyEditable(row) ||
        isConfigPublishing.value ||
        uiStore.isSPViewerOnly,
      hint: isConfigPublishing.value
        ? "You cannot edit this policy as config is currently being published"
        : "",
      onClick: () =>
        router.push({
          path: `/sp/${serviceProviderId.value}/policy-types/${row.id}`,
          query: { editMode: "true" },
        }),
    },
    {
      label: "Delete",
      type: "button",
      color: "error",
      hint: isDeletePolicyDisabled(row)
        ? deletePolicyHintText(row)
        : deletePolicyConfigHintText.value,
      isDisabled:
        isDeletePolicyDisabled(row) ||
        isConfigPublishing.value ||
        uiStore.isSPViewerOnly ||
        !isPolicyDeletable(row),
      onClick: () => handlePoliciesDeleteDialog(row),
    },
  ];
});

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

const updateTableParamsHandler = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  await getPolicyTypes(params);
};

const goToCreatePolicyType = (categoryId: string) => {
  // set activeCategory in the store
  policyUxCategoriesStore.setActiveCategory(categoryId);

  router.push({
    name: "NewPolicyType",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });
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

const detailedViewLink = (row: SPPolicyTypeRead) =>
  `/sp/${serviceProviderId.value}/policy-types/${row?.id}`;

const isDeletePolicyDisabled = (policy: SPPolicyTypeRead) => {
  return Boolean(
    policy.has_child_or_parent_policy_types || policy.used_in_agreement_type,
  );
};

const deletePolicyHintText = (policy: SPPolicyTypeRead) => {
  return isDeletePolicyDisabled(policy)
    ? "You cannot delete this policy as there are active instances of it"
    : null;
};

const deletePolicyConfigHintText: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this policy as config is currently being published"
    : "",
);

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_policy",
    action: () => goToCreatePolicyType(getUxCategoryId("Policy") || ""),
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

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  isSPAdmin.value = await authService.isUserSPAdmin();
  isSPEditor.value = await authService.isUserSPEditor();

  await policyUxCategoriesStore.fetchPolicyUxCategories();
});
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="policies.overview"
    :config-banner-cmp="ConfigPublishBanner"
    :buttons="buttons"
  >
    <div>
      <m-m-table
        :headers="TABLE_HEADERS"
        :is-loading="isLoading"
        :rows="policies?.results || []"
        :total-rows="policies?.total"
        show-search
        cy="policies-table"
        :empty-state="emptyState"
        @update-params="updateTableParamsHandler"
      >
        <template #empty-state-button>
          <div class="mm-flex mm-flex-gap-6">
            <m-m-dropdown
              list-side="left"
              :items="createDropdownItems"
              :is-disabled="isButtonCreatePolicyDisabled"
              cy="empty-state-create-policy-dropdown"
            >
              <template #activator>
                <m-m-button
                  size="small"
                  prepend-icon="plus-white"
                  cy="empty-state-create-policy"
                >
                  Create policy
                  <m-m-tooltip
                    v-if="isConfigPublishing"
                    display-position="toLeft"
                  >
                    Config is currently being published.
                  </m-m-tooltip>
                </m-m-button>
              </template>
            </m-m-dropdown>
          </div>
        </template>
        <template #created_date="{ row }">
          <m-m-formatted-date
            :raw-date="row.created_date"
            format="D MMM YYYY, HH:mm"
          />
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
        <template #type="{ row }">
          {{ getUxCategoryName(row.category_id) }}
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

  <DialogPoliciesDelete
    :is-open="isPoliciesDeleteDialogOpen"
    :data="dialogPoliciesDeleteData"
    @close-dialog="
      dialogPoliciesDeleteData &&
      handlePoliciesDeleteDialog(dialogPoliciesDeleteData.policyId as string)
    "
    @submit-dialog="
      dialogPoliciesDeleteData &&
      handleDeletePolicy(dialogPoliciesDeleteData.policyId)
    "
  />
  <m-m-config-banner />
</template>

<style scoped lang="scss">
.policies {
  color: #4d5761;
  font-size: 14px;
  font-weight: 400;
  line-height: 20px;
}
</style>
