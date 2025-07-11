<script setup lang="ts">
import {
  computed,
  ComputedRef,
  defineProps,
  onMounted,
  PropType,
  ref,
  Ref,
} from "vue";
import {
  PaginationSchema_PolicyTypeRead_,
  TypeDialogPoliciesDeleteData,
} from "../../../ConfigurationTabs/Policies/policies.types";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
} from "~/mm_ui_kit/src/types/table.types";
import { usePolicyUxCategoriesStore } from "~/stores/policyUxCategories";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { useRouter } from "vue-router";
import DialogPoliciesDelete from "~/service-providers/_shared/Dialogs/DialogPoliciesDelete.vue";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();
const router = useRouter();

const props = defineProps({
  items: {
    type: Object as PropType<PaginationSchema_PolicyTypeRead_ | null>,
    default: null,
  },
  serviceProviderId: {
    type: String,
    required: true,
    default: "",
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update", "deletePolicy"]);

const emptyState: EmptyStateType = {
  title: "Create your first policy",
  description:
    " Policies are used to define the rules and conditions under which access to resources is granted or denied.",
  learnMoreHref:
    "https://docs.myveriam.com/getting-started/configure-your-access-requirements#policies",
  icon: "shield-check-outline",
};

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
    key: "external_facing_description",
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

const initialQueryParams = ref<TableRequestParams>({
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const manageRolesPermissionsDropdownItems: ComputedRef<TypeDropdownItem[]> =
  computed(() => [
    {
      label: "Manage roles",
      type: "link",
      to: `/sp/${props.serviceProviderId}/roles`,
    },
    {
      label: "Manage permissions",
      type: "link",
      to: `/sp/${props.serviceProviderId}/permissions`,
    },
  ]);

const handleUpdateParams = (params: TableRequestParams) => {
  emit("update", {
    ...initialQueryParams.value,
    ...params,
  });
};

const detailedViewLink = (row: SPPolicyTypeRead) =>
  `/sp/${props.serviceProviderId}/policy-types/${row?.id}`;

const isDeletePolicyDisabled = (policy: SPPolicyTypeRead) => {
  return (
    policy.has_child_or_parent_policy_types || policy.used_in_agreement_type
  );
};

const deletePolicyHintText: ComputedRef<
  (policy: SPPolicyTypeRead) => string | null
> = computed(() => {
  return (policy: SPPolicyTypeRead): string | null => {
    if (isDeletePolicyDisabled(policy)) {
      return "You cannot delete this policy as there are active instances of it.";
    }
    if (isConfigPublishing.value) {
      return "You cannot delete this policy as config is currently being published.";
    }
    return null;
  };
});

const goToPolicyTypeDetails = (policy_type_id: string) => {
  router.push({
    name: "PolicyTypeDetail",
    params: {
      service_provider_id: props.serviceProviderId,
      policy_type_id,
    },
  });
};

const handleDeletePolicy = async (policyId: string) => {
  await policyTypesService.deletePolicyType(props.serviceProviderId, policyId);
  isPoliciesDeleteDialogOpen.value = false;
  emit("deletePolicy");
};

const isPoliciesDeleteDialogOpen: Ref<boolean> = ref(false);
const dialogPoliciesDeleteData: Ref<TypeDialogPoliciesDeleteData | null> =
  ref(null);

const handlePoliciesDeleteDialog = (policy: SPPolicyTypeRead | string) => {
  isPoliciesDeleteDialogOpen.value = !isPoliciesDeleteDialogOpen.value;
  dialogPoliciesDeleteData.value = {
    policyName: policy.name,
    policyId: policy.id,
  };
};

const policyUxCategoriesStore = usePolicyUxCategoriesStore();

const isButtonCreatePolicyDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const policyUxCategory = computed(() =>
  policyUxCategoriesStore.policyUxCategories.find(
    (category) => category.name === "Policy",
  ),
);

const isPolicyDeletable = (policy: SPPolicyTypeRead): boolean =>
  policy?.deletable ?? true;

const isPolicyEditable = (policy: SPPolicyTypeRead): boolean =>
  policy?.editable ?? true;

const dropdownItems: ComputedRef<
  (row: SPPolicyTypeRead) => TypeDropdownItem[]
> = computed(() => {
  return (row: SPPolicyTypeRead): TypeDropdownItem[] => [
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
        !!isConfigPublishing.value ||
        uiStore.isSPViewerOnly ||
        !isPolicyEditable(row),
      hint: isConfigPublishing.value
        ? "You cannot edit this policy as config is currently being published"
        : "",
      onClick: () =>
        router.push({
          path: `/sp/${props.serviceProviderId}/policy-types/${row.id}`,
          query: { editMode: "true" },
        }),
    },
    {
      label: "Delete",
      type: "button",
      color: "error",
      hint: deletePolicyHintText.value(row),
      isDisabled:
        isConfigPublishing.value ||
        uiStore.isSPViewerOnly ||
        isDeletePolicyDisabled(row) ||
        !isPolicyDeletable(row),
      onClick: () => handlePoliciesDeleteDialog(row),
    },
  ];
});

const goToCreatePolicyType = () => {
  // set activeCategory in the store
  policyUxCategoriesStore.setActiveCategory(policyUxCategory?.value?.id || "");

  router.push({
    name: "NewPolicyType",
    params: {
      service_provider_id: props.serviceProviderId,
    },
  });
};

onMounted(async () => {
  await policyUxCategoriesStore.fetchPolicyUxCategories();
});
</script>

<template>
  <section class="mm-access-control-policies">
    <m-m-table
      cy="access-control-policies-table"
      :is-loading="isLoading"
      :empty-state="emptyState"
      :rows="items?.results || []"
      :headers="TABLE_HEADERS"
      description="Policies defined to determine whether users can be granted access or not"
      :total-rows="items?.total || 0"
      show-search
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          size="small"
          prepend-icon="plus-white"
          cy="empty-state-create-policy-button"
          :is-disabled="isButtonCreatePolicyDisabled"
          @click="goToCreatePolicyType"
        >
          Create policy
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
      <template #action>
        <div class="mm-flex mm-flex-gap-6">
          <m-m-button
            variant="outlined"
            size="small"
            prepend-icon="plus"
            cy="create-policy-button"
            :is-disabled="isButtonCreatePolicyDisabled"
            @click="goToCreatePolicyType"
          >
            Create policy
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
          <m-m-dropdown
            list-side="left"
            :items="manageRolesPermissionsDropdownItems"
            cy="dropdown-manage-roles-permissions"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="outlined"
                size="small"
                cy="action-manage-roles-permissions"
              />
            </template>
          </m-m-dropdown>
        </div>
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
          >{{ row.external_facing_description }}
        </m-m-text-ellipsis>
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
    </m-m-table>
  </section>

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
</template>
