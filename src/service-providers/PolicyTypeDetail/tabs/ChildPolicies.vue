<script lang="ts" setup>
import { ComputedRef, PropType, computed, ref, Ref, watch } from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import ChildPolicyTypeAdd from "~/service-providers/PolicyTypeDetail/dialogs/ChildPolicyTypeAdd.vue";
import ChildPolicyTypeCreate from "~/service-providers/PolicyTypeDetail/dialogs/ChildPolicyTypeCreate.vue";
import { useRouter } from "vue-router";
import { PolicyTypeDetailMode } from "~/service-providers/PolicyTypeDetail/policyTypeDetail.types";
import { PolicyTypeDetailForm } from "~/service-providers/PolicyTypeDetail/policyTypeDetail.types";
import { POLICY_TYPE_CATEGORY } from "~/service-providers/PolicyTypeDetail/constants";
import { policyTypesService } from "~/configuration/policy-types.service";

const headers = [
  { key: "external_facing_name", label: "Policy name" },
  { key: "external_facing_description", label: "Description" },
  { key: "actions", label: "" },
];

const emit = defineEmits([
  "parentUpdated",
  "updatePreparedChildPolicies",
  "updateIsRemovingPolicyStatus",
  "updateChildPolicyTypesForRemoval",
]);

const emptyState = "No child policies";

const props = defineProps({
  policyTypes: {
    type: Array as PropType<PolicyTypeRead[]>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  policyCategoryId: {
    type: String,
    default: POLICY_TYPE_CATEGORY,
  },
  parentPolicyType: {
    type: Object as PropType<PolicyTypeRead | null>,
    required: true,
  },
  mode: {
    type: String as PropType<PolicyTypeDetailMode>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  isDiscarded: {
    type: Boolean,
    default: false,
  },
});

const router = useRouter();
const isConfirmDeleteDialogOpen = ref(false);
const isAddChildPolicyDialogOpen = ref(false);
const isCreateChildPolicyDialogOpen = ref(false);
const policyTypeToRemove = ref<PolicyTypeRead | null>(null);
const isRemoving = ref(false);
const tempChildPolicyTypes = ref<string[]>([]);
const childPolicies: Ref<PolicyTypeRead[]> = ref([]);
const policiesForRemoval: Ref<PolicyTypeRead[]> = ref([]);

const mergedPolicies = (
  newPolicies: Array<{ id: string; [key: string]: unknown }>,
  existingPolicies: Array<{ id: string; [key: string]: unknown }>,
) => {
  const mergedMap = new Map();

  newPolicies.forEach((item) => mergedMap.set(item.id, item));
  existingPolicies.forEach((item) => mergedMap.set(item.id, item));

  return Array.from(mergedMap.values());
};

const isEditable: ComputedRef<boolean> = computed(() =>
  ["edit", "create"].includes(props.mode),
);

const childPolicyTypes: ComputedRef<PolicyTypeRead[]> = computed(() => {
  let formattedPolicyTypes;

  if (props.isDiscarded) {
    formattedPolicyTypes = props.policyTypes;
  } else {
    formattedPolicyTypes = mergedPolicies(
      childPolicies.value,
      props.policyTypes,
    );
  }

  // Filter out policies marked for removal
  const policyTypeIdsToRemove = new Set(
    policiesForRemoval.value.map((policyType: PolicyTypeRead) => policyType.id),
  );

  formattedPolicyTypes = formattedPolicyTypes.filter(
    (policyType: PolicyTypeRead) => !policyTypeIdsToRemove.has(policyType.id),
  );

  // Additional filtering if a policy is currently being removed
  if (policyTypeToRemove.value && isRemoving.value) {
    formattedPolicyTypes = formattedPolicyTypes.filter(
      (policyType: PolicyTypeRead) =>
        policyType.id !== policyTypeToRemove.value?.id,
    );
  }

  return formattedPolicyTypes;
});

const getDropdownItems = (row: PolicyTypeRead) => {
  const linkItem = {
    label: `Go to ${row.external_facing_name ?? "policy"}`,
    type: "link",
    to: `/sp/${props.serviceProviderId}/policy-types/${row.id}`,
  };

  if (!isEditable.value) return [linkItem];

  const removeItem = {
    label: `Remove ${
      props.parentPolicyType?.external_facing_name
        ? `from ${props.parentPolicyType.external_facing_name}`
        : ""
    }`,
    type: "button",
    color: "error",
    onClick: () => handleRemovePolicy(row),
  };

  return [linkItem, removeItem];
};

watch(
  [policyTypeToRemove, isRemoving],
  ([newPolicyTypeToRemove, newIsRemoving]) => {
    if (newPolicyTypeToRemove && newIsRemoving) {
      policiesForRemoval.value.push(newPolicyTypeToRemove);

      emit("updatePreparedChildPolicies", childPolicyTypes.value);
      emit("updateIsRemovingPolicyStatus", true);
      emit("updateChildPolicyTypesForRemoval", policiesForRemoval.value);

      policyTypeToRemove.value = null;
      isRemoving.value = false;
    }
  },
);

const description: string =
  "All policies added as child policies will be evaluated when this policy applies to the authorization transaction. Child policies that are applicable (based on their filters) will determine the eventual access decision. ";
const isViewing: ComputedRef<boolean> = computed(() => props.mode === "view");

const toggleConfirmDelete = () => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
};

const toggleAddChildPolicyDialog = () => {
  isAddChildPolicyDialogOpen.value = !isAddChildPolicyDialogOpen.value;
};

const toggleCreateChildPolicyDialog = () => {
  isCreateChildPolicyDialogOpen.value = !isCreateChildPolicyDialogOpen.value;
};

const handleRemovePolicy = (policyType: PolicyTypeRead) => {
  policyTypeToRemove.value = policyType;
  toggleConfirmDelete();
};

const gotoCreatePolicyType = async (form: PolicyTypeDetailForm) => {
  toggleCreateChildPolicyDialog();
  const childPolicy = await policyTypesService.postPolicyType(
    props.serviceProviderId as string,
    {
      ...form,
      service_provider_id: props.serviceProviderId as string,
      category_id: props.policyCategoryId,
      outcome: "A",
    },
  );

  if (childPolicy && props.mode !== "create") {
    await policyTypesService.patchPolicyType(
      props.serviceProviderId as string,
      props.parentPolicyType.id,
      {
        ...props.parentPolicyType,
        child_policy_types: [
          ...props.parentPolicyType.child_policy_types,
          childPolicy.id,
        ],
      },
    );

    router.push(
      `/sp/${props.serviceProviderId}/policy-types/${childPolicy.id}?parentPolicyTypeId=${props.parentPolicyType}#Basic-Information`,
    );
  }
};

const removeFromParent = async () => {
  if (!policyTypeToRemove.value) {
    return;
  }

  isRemoving.value = true;
  toggleConfirmDelete();
};

const updatePolicy = ($event: string[]) => {
  tempChildPolicyTypes.value = $event;
  emit("updatePreparedChildPolicies", tempChildPolicyTypes.value);
};

const handlePreparedChildPolicies = (childPolicyTypes: PolicyTypeRead[]) => {
  const childPolicyIdsToFilter = childPolicyTypes.map(
    (policyType: PolicyTypeRead) => policyType.id,
  );
  policiesForRemoval.value = policiesForRemoval.value.filter(
    (item) => !childPolicyIdsToFilter.includes(item.id),
  );
  childPolicies.value.push(...childPolicyTypes);
  emit("updatePreparedChildPolicies", childPolicies.value);
  emit("updateChildPolicyTypesForRemoval", policiesForRemoval.value);
};

watch(
  () => childPolicyTypes.value,
  (newValue) => {
    tempChildPolicyTypes.value = newValue.map((policyType) => policyType.id);
  },
  { deep: true, immediate: true },
);
</script>
<template>
  <div>
    <m-m-table
      :headers="headers"
      :rows="childPolicyTypes"
      cy="child-policy-types"
      :description="description"
      :is-loading="isLoading"
      :empty-state="emptyState"
    >
      <template v-if="!isViewing" #action>
        <m-m-button
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto"
          cy="add-child-policy-button"
          @click="toggleAddChildPolicyDialog"
        >
          Add child policy
        </m-m-button>
      </template>
      <template #empty-state-button>
        <m-m-button
          v-if="!isViewing"
          size="small"
          prepend-icon="plus-white"
          class="mm-ml-auto"
          cy="add-child-policy-button"
          @click="toggleAddChildPolicyDialog"
        >
          Add child policy
        </m-m-button>
      </template>
      <template #actions="{ row }">
        <m-m-dropdown :cy="`dropdown-${row.id}`" :items="getDropdownItems(row)">
          <template #activator>
            <m-m-button
              prepend-icon="dots-vertical"
              variant="text"
              :cy="`actions-button-${row.id}`"
            />
          </template>
        </m-m-dropdown>
      </template>
    </m-m-table>

    <child-policy-type-add
      v-if="isAddChildPolicyDialogOpen"
      :is-open="isAddChildPolicyDialogOpen"
      :service-provider-id="props.serviceProviderId"
      :parent-policy-type="props.parentPolicyType"
      :current-policy-types="tempChildPolicyTypes"
      :assigned-policies="policyTypes"
      @close="toggleAddChildPolicyDialog"
      @submit="updatePolicy"
      @remove-child-policy-type="handleRemovePolicy"
      @update-prepared-child-policies="handlePreparedChildPolicies"
      @create-child-policy-type="
        toggleAddChildPolicyDialog();
        toggleCreateChildPolicyDialog();
      "
    />

    <child-policy-type-create
      :is-open="isCreateChildPolicyDialogOpen"
      :service-provider-id="props.serviceProviderId"
      @close="toggleCreateChildPolicyDialog"
      @submit="gotoCreatePolicyType"
    />

    <m-m-dialog
      :is-open="isConfirmDeleteDialogOpen"
      title="Remove child policy"
      icon="warning"
      icon-color="error"
      :subtitle="`Are you sure you want to remove ${policyTypeToRemove?.external_facing_name} from ${parentPolicyType?.external_facing_name}?`"
      cy="confirm-remove-from-parent"
      @close="toggleConfirmDelete"
    >
      <template #footer>
        <m-m-button
          variant="outlined"
          data-cy="button-cancel-delete-user"
          @click="toggleConfirmDelete"
        >
          No
        </m-m-button>
        <m-m-button
          variant="danger"
          data-cy="button-confirm-delete-user"
          :loading="isRemoving"
          @click="removeFromParent"
        >
          Yes, remove
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
