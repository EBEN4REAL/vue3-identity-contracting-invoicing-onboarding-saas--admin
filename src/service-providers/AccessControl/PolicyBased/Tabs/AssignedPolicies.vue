<script setup lang="ts">
import {
  ref,
  Ref,
  defineEmits,
  PropType,
  ComputedRef,
  computed,
  onMounted,
} from "vue";
import { policiesService } from "~/service-providers/policies.service";
import {
  TableHeader,
  TableRequestParams,
} from "~/mm_ui_kit/src/types/table.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  AllPolicyRead,
  PaginationSchema_AllPolicyRead_,
} from "../../../Policies/policies.types";
import DialogRemovePolicy from "../Dialogs/DialogRemovePolicy.vue";
import DialogAssignPolicies from "../Dialogs/DialogAssignPolicies.vue";
import { PolicyTypeBaseRead } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { policyTypesService } from "~/configuration/policy-types.service";
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

const emit = defineEmits(["update", "deleteAssignedPolicy"]);

const uiStore = useUiStore();

const TABLE_HEADERS: TableHeader[] = [
  {
    key: "name",
    label: "Policy name",
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
const isDialogAssignPoliciesOpen: Ref<boolean> = ref(false);
const policyTypeId: Ref<string | null> = ref(null);
const allPolicies: Ref<PolicyTypeRead | null> = ref(null);
const selectedEntityType: Ref<string | null> = ref(null);
const initialQueryParams = ref<TableRequestParams>({
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});
const assignDropdownItems = computed(() => {
  const items = [
    {
      label: `To account`,
      type: "button",
      onClick: () => goToAssignPolicy("organization"),
    },
    {
      label: `To users`,
      type: "button",
      onClick: () => goToAssignPolicy("user"),
    },
  ];

  return items;
});
const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isButtonAssignPolicyDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const handleUpdateParams = (params: TableRequestParams) => {
  emit("update", {
    ...initialQueryParams.value,
    ...params,
  });
};

const isPolicyDeletable = (policy: AllPolicyRead): boolean =>
  policy?.deletable ?? true;

const dropdownItems: ComputedRef<(row: AllPolicyRead) => TypeDropdownItem[]> =
  computed(() => (row: AllPolicyRead) => [
    {
      label: "Remove policy",
      color: "error",
      type: "button",
      isDisabled: !isPolicyDeletable(row) || isConfigPublishing.value,
      hint: isConfigPublishing.value
        ? "You cannot delete this item as config is currently being published."
        : null,
      onClick: () => handleRemovePoliciesDialog(row),
    },
  ]);

const isPoliciesRemoveDialogOpen: Ref<boolean> = ref(false);
const dialogRemovePoliciesData: Ref<AllPolicyRead | null> = ref(null);

const formattedAssignedPolicies: ComputedRef<AllPolicyRead[]> = computed(
  () =>
    props.items?.results?.map((policy: AllPolicyRead) => ({
      ...policy,
      user:
        policy.policy_assignment !== "ORGANIZATION"
          ? (props.userName?.[policy.assigned_id as string] ?? "-")
          : "-",
      account: policy?.organizationName ?? "-",
    })) ?? [],
);

const onDialogAssignPolicyOpen = () => {
  isDialogAssignPoliciesOpen.value = true;
};

const assigneeType = (row: PolicyTypeRead) =>
  row.policy_assignment === "ORGANIZATION" ? "Account" : "User";
const onDialogAssignPoliciesClose = () => {
  isDialogAssignPoliciesOpen.value = false;
};

const handleRemovePoliciesDialog = (policy: AllPolicyRead) => {
  isPoliciesRemoveDialogOpen.value = true;
  dialogRemovePoliciesData.value = policy;
};

const goToAssignPolicy = (entityType: string) => {
  selectedEntityType.value = entityType;
  onDialogAssignPolicyOpen();
};
const getPolicyTypeCategories = async () => {
  const result = await policiesService.getPolicyTypeCategories();
  const policyTypeCategory = result.find(
    (policyType: PolicyTypeBaseRead) => policyType.name == "Policy",
  );
  policyTypeId.value = policyTypeCategory?.id;
};

const getAllPolicies = async (params?: TableRequestParams) => {
  const result = await policyTypesService.getPolicyTypes(
    props.serviceProviderId,
    {
      category_id: policyTypeId.value,
      ...params,
    },
  );
  allPolicies.value = result;
};

const handleRemovePolicy = async (policy: AllPolicyRead) => {
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
  isPoliciesRemoveDialogOpen.value = false;
  emit("deleteAssignedPolicy");
};
onMounted(async () => {
  await getPolicyTypeCategories();
  await getAllPolicies();
});
</script>

<template>
  <section class="mm-access-control-assigned-policies">
    <m-m-table
      cy="access-control-assigned-policies-table"
      :is-loading="isLoading"
      :rows="formattedAssignedPolicies"
      empty-state="No policies"
      :headers="TABLE_HEADERS"
      description="Policies assigned to users or entire organizations"
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
              :is-disabled="isButtonAssignPolicyDisabled"
              cy="assign-policy-action-button"
            >
              Assign Policy
            </m-m-button>
          </template>
        </m-m-dropdown>
      </template>
      <template #empty-state-button>
        <m-m-dropdown
          list-side="left"
          :items="assignDropdownItems"
          cy="empty-state-assign-policy-dropdown"
        >
          <template #activator>
            <m-m-button
              size="small"
              prepend-icon="plus-white"
              cy="empty-state-assign-policy-button"
              :is-disabled="isButtonAssignPolicyDisabled"
            >
              Assign Policy
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
            max-width="210px"
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
  <DialogRemovePolicy
    :is-open="isPoliciesRemoveDialogOpen"
    :data="dialogRemovePoliciesData"
    :org-name="
      props.organizationName &&
      dialogRemovePoliciesData &&
      props.organizationName[dialogRemovePoliciesData.organization_id]
    "
    :user-name="
      userName &&
      dialogRemovePoliciesData &&
      userName[dialogRemovePoliciesData.assigned_id]
    "
    @close-dialog="isPoliciesRemoveDialogOpen = false"
    @submit-dialog="
      dialogRemovePoliciesData && handleRemovePolicy(dialogRemovePoliciesData)
    "
  />
  <dialog-assign-policies
    v-if="isDialogAssignPoliciesOpen"
    :policy-type-id="policyTypeId"
    :selected-entity-type="selectedEntityType"
    :is-open="isDialogAssignPoliciesOpen"
    :service-provider-id="serviceProviderId"
    :all-policies="allPolicies"
    :assigned-policies="items"
    @update="handleUpdateParams"
    @update-all-policies="getAllPolicies"
    @close="onDialogAssignPoliciesClose"
  />
</template>
