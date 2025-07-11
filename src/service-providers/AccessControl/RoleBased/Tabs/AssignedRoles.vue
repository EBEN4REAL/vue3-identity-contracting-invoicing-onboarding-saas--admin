<script setup lang="ts">
import {
  ref,
  Ref,
  defineEmits,
  PropType,
  onMounted,
  computed,
  ComputedRef,
} from "vue";
import { policiesService } from "~/service-providers/policies.service";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
} from "~/mm_ui_kit/src/types/table.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  AllPolicyRead,
  PaginationSchema_AllPolicyRead_,
} from "../../../Policies/policies.types";
import DialogRemoveRole from "../Dialogs/DialogRemoveRole.vue";
import DialogAssignRoles from "../Dialogs/DialogAssignRoles.vue";
import { PolicyTypeBaseRead } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { useUiStore } from "~/stores/useUiStore";
const props = defineProps({
  items: {
    type: Object as PropType<PaginationSchema_AllPolicyRead_ | null>,
    default: null,
  },
  serviceProviderId: {
    type: String,
    required: true,
    default: "",
  },
  organizationName: {
    type: Object as PropType<Record<string, string> | null>,
    default: null,
  },
  userName: {
    type: Object as PropType<Record<string, string> | null>,
    default: null,
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["update", "deleteAssignedRole"]);
const uiStore = useUiStore();

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isButtonAssignRoleDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const emptyState: EmptyStateType = {
  title: "Assign your first role",
  description:
    "You can assign roles to your customer accounts or their users to provide them access.",
  icon: "user-circle",
};

const assignDropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => {
  const items = [
    {
      label: `To account`,
      type: "button",
      onClick: () => goToAssignRole("organization"),
    },
    {
      label: `To users`,
      type: "button",
      onClick: () => goToAssignRole("user"),
    },
  ];

  return items;
});

const TABLE_HEADERS: TableHeader[] = [
  {
    key: "name",
    label: "Role name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "name",
  },
  {
    key: "assigned_to",
    label: "Assigned to",
  },
  {
    key: "account",
    label: "Account",
  },
  {
    key: "user",
    label: "User",
  },
  {
    key: "assigned_on",
    label: "Assigned on",
    sortable: true,
    sortIcon: true,
    order: "desc",
    defaultSortItem: true,
    sortName: "assigned_on",
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
const allRoles: Ref<PolicyTypeRead | null> = ref(null);
const selectedEntityType: Ref<string | null> = ref(null);
const rolePolicyTypeId: Ref<string | null> = ref(null);
const isDialogAssignRolesOpen: Ref<boolean> = ref(false);
const onDialogAssignRolesOpen = () => {
  isDialogAssignRolesOpen.value = true;
};
const onDialogUnassignRolesClose = () => {
  isDialogAssignRolesOpen.value = false;
};

const dropdownItems = (row: AllPolicyRead) => [
  {
    label: "Remove",
    type: "button",
    color: "error",
    onClick: () => handleRemovePoliciesDialog(row),
  },
];

const handleUpdateParams = (params: TableRequestParams) => {
  emit("update", {
    ...initialQueryParams.value,
    ...params,
  });
};
const assigneeType = (row: PolicyTypeRead) =>
  row.policy_assignment === "ORGANIZATION" ? "Account" : "User";

const goToAssignRole = (entityType: string) => {
  selectedEntityType.value = entityType;
  onDialogAssignRolesOpen();
};

const isRolesRemoveDialogOpen: Ref<boolean> = ref(false);
const dialogRemoveRolesData: Ref<AllPolicyRead | null> = ref(null);

const formattedAssignedRoles: ComputedRef<AllPolicyRead[]> = computed(
  () =>
    props.items?.results?.map((item: AllPolicyRead) => ({
      ...item,
      user:
        item.policy_assignment !== "ORGANIZATION"
          ? (props.userName?.[item.assigned_id as string] ?? "-")
          : "-",
      account: item?.organizationName ?? "-",
    })) ?? [],
);

const handleRemovePoliciesDialog = (policy: AllPolicyRead) => {
  isRolesRemoveDialogOpen.value = true;
  dialogRemoveRolesData.value = policy;
};

const getPolicyTypeCategories = async () => {
  const result = await policiesService.getPolicyTypeCategories();
  const rolePolicyTypeCategory = result.find(
    (policyType: PolicyTypeBaseRead) => policyType.name == "Role",
  );
  rolePolicyTypeId.value = rolePolicyTypeCategory?.id;
};

const getAllRoles = async (params?: TableRequestParams) => {
  const result = await policyTypesService.getPolicyTypes(
    props.serviceProviderId,
    {
      category_id: rolePolicyTypeId.value,
      ...params,
    },
  );
  allRoles.value = result;
};

const handleRemoveRole = async (policy: AllPolicyRead) => {
  if (policy.policy_assignment === "ORGANIZATION") {
    await policiesService.removePolicyFromOrganization(
      props.serviceProviderId,
      {
        policy_type_id: policy.type_id,
        organization_id: policy.organization_id,
      },
    );
  } else if (policy.policy_assignment === "ORGANIZATION_USER") {
    await policiesService.removePolicy(props.serviceProviderId, {
      policy_type_id: policy.type_id,
      organization_user_id: policy.assigned_id,
      organization_id: policy.organization_id,
    });
  }
  isRolesRemoveDialogOpen.value = false;
  emit("deleteAssignedRole");
};
onMounted(async () => {
  await getPolicyTypeCategories();
  await getAllRoles();
});
</script>

<template>
  <section class="mm-access-control-assigned-policies">
    <m-m-table
      cy="access-control-assigned-roles-table"
      :is-loading="isLoading"
      :rows="formattedAssignedRoles"
      :headers="TABLE_HEADERS"
      :empty-state="emptyState"
      description="Roles assigned to users or accounts"
      :total-rows="items?.total || 0"
      show-search
      @update-params="handleUpdateParams"
    >
      <template #action>
        <m-m-dropdown
          list-side="left"
          :items="assignDropdownItems"
          cy="assign-policy-dropdown"
        >
          <template #activator>
            <m-m-button
              size="small"
              variant="outlined"
              prepend-icon="plus"
              :is-disabled="isButtonAssignRoleDisabled"
              cy="assign-role-action-button"
            >
              Assign Role
            </m-m-button>
          </template>
        </m-m-dropdown>
      </template>
      <template #empty-state-button>
        <m-m-dropdown
          list-side="left"
          :items="assignDropdownItems"
          cy="empty-state-assign-roles-dropdown"
        >
          <template #activator>
            <m-m-button
              size="small"
              prepend-icon="plus-white"
              cy="empty-state-assign-policy-button"
              :is-disabled="isButtonAssignRoleDisabled"
            >
              Assign Role
              <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
                Config is currently being published.
              </m-m-tooltip>
            </m-m-button>
          </template>
        </m-m-dropdown>
      </template>
      <template #name="{ row }">
        <span class="font-weight-500">
          {{ row.name }}
        </span>
      </template>
      <template #assigned_to="{ row }">
        {{ assigneeType(row) }}
        <span> </span>
      </template>
      <template #assigned_on="{ row }">
        <m-m-formatted-date :raw-date="row.assigned_on" />
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="dropdownItems(row)"
            :cy="`actions-dropdown-${row.id}`"
            max-width="200px"
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
  <DialogRemoveRole
    :is-open="isRolesRemoveDialogOpen"
    :data="dialogRemoveRolesData"
    :org-name="
      props.organizationName &&
      dialogRemoveRolesData &&
      props.organizationName[dialogRemoveRolesData.organization_id]
    "
    :user-name="
      userName &&
      dialogRemoveRolesData &&
      userName[dialogRemoveRolesData.assigned_id]
    "
    @close-dialog="isRolesRemoveDialogOpen = false"
    @submit-dialog="
      dialogRemoveRolesData && handleRemoveRole(dialogRemoveRolesData)
    "
  />
  <dialog-assign-roles
    v-if="isDialogAssignRolesOpen"
    :category-id="rolePolicyTypeId"
    :selected-entity-type="selectedEntityType"
    :all-roles="allRoles"
    :assigned-roles="items"
    :is-open="isDialogAssignRolesOpen"
    :service-provider-id="serviceProviderId"
    @update="handleUpdateParams"
    @update-all-roles="getAllRoles"
    @close="onDialogUnassignRolesClose"
  />
</template>
