<script lang="ts" setup>
import {
  PropType,
  ref,
  onMounted,
  ComputedRef,
  computed,
  Ref,
  watch,
} from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import FilterAdd from "~/service-providers/PolicyTypeDetail/dialogs/FilterAdd.vue";
import { FilterRead } from "~/service-providers/Filters/filters.types";
import { PolicyTypeDetailMode } from "../policyTypeDetail.types";

const emptyState: string = "No filters";

const headers = [
  { key: "name", label: "Filter name" },
  { key: "description", label: "Description" },
  { key: "actions", label: "" },
];

const emit = defineEmits([
  "parentUpdated",
  "updatePreparedFilters",
  "updateIsRemovingFilterStatus",
  "updateFiltersForRemoval",
]);

const props = defineProps({
  filters: {
    type: Array as PropType<FilterRead[]>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  parentPolicyType: {
    type: Object as PropType<PolicyTypeRead | null>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    default: true,
  },
  mode: {
    type: String as PropType<PolicyTypeDetailMode>,
    required: true,
  },
  isDiscarded: {
    type: Boolean,
    default: false,
  },
});

const isConfirmDeleteDialogOpen = ref(false);
const isAddFilterDialogOpen = ref(false);
const filterToRemove = ref<FilterRead | null>(null);
const isButtonSubmitDisabled = ref(false);
const isButtonSubmitLoading = ref(false);
const tempFilters = ref<string[]>([]);
const filtersToAdd: Ref<FilterRead[]> = ref([]);
const isRemoving: Ref<boolean> = ref(false);
const filtersForRemoval: Ref<FilterRead[]> = ref([]);
const description: string = `All filter that will determine if the policy is applicable for the authorization situation. When multiple filters are added, all of the filters must pass for the policy to apply to the authorization decision. 
If no filters are added, the policy is considered to always apply.`;
const toggleConfirmDelete = () => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
};
const displayAddButton: ComputedRef<boolean> = computed(
  () => props.mode === "edit" || props.mode === "create",
);
const toggleAddFilterDialog = () => {
  isAddFilterDialogOpen.value = !isAddFilterDialogOpen.value;
};

const tryToRemoveFromParent = (filter: FilterRead) => {
  filterToRemove.value = filter;
  toggleConfirmDelete();
};

const mergedFilters = (
  newFilters: Array<{ id: string; [key: string]: unknown }>,
  existingFilters: Array<{ id: string; [key: string]: unknown }>,
) => {
  const mergedMap = new Map();

  newFilters.forEach((item) => mergedMap.set(item.id, item));
  existingFilters.forEach((item) => mergedMap.set(item.id, item));

  return Array.from(mergedMap.values());
};

const computedFilters: ComputedRef<FilterRead[]> = computed(() => {
  let formattedFilters = props.isDiscarded
    ? props.filters
    : mergedFilters(filtersToAdd.value, props.filters);

  // Filter out the filters that are marked for removal
  const filterIdsToRemove = new Set(
    filtersForRemoval.value.map((filter: FilterRead) => filter.id),
  );

  formattedFilters = formattedFilters.filter(
    (filter: FilterRead) => !filterIdsToRemove.has(filter.id),
  );

  // Additional filtering if a filter is currently being removed
  if (filterToRemove.value && isRemoving.value) {
    formattedFilters = formattedFilters.filter(
      (filter: FilterRead) => filter.id !== filterToRemove.value?.id,
    );
  }

  return formattedFilters;
});

watch([filterToRemove, isRemoving], ([newFilterToRemove, newIsRemoving]) => {
  if (newFilterToRemove && newIsRemoving) {
    filtersForRemoval.value.push(newFilterToRemove);

    emit("updatePreparedFilters", computedFilters.value);
    emit("updateIsRemovingFilterStatus", true);
    emit("updateFiltersForRemoval", filtersForRemoval.value);

    filterToRemove.value = null;
    isRemoving.value = false;
  }
});

const handlePreparedFilters = (newFilters: FilterRead[]) => {
  const filterIds = newFilters.map((filter: FilterRead) => filter.id);
  const filteredFiltersForRemoval = filtersForRemoval.value.filter(
    (item) => !filterIds.includes(item.id),
  );
  filtersForRemoval.value = filteredFiltersForRemoval;
  filtersToAdd.value.push(...newFilters);
  emit("updatePreparedFilters", filtersToAdd.value);
};

const removeFromParent = async () => {
  if (!filterToRemove.value) {
    return;
  }
  isRemoving.value = true;
  toggleConfirmDelete();
};

const updateFilter = ($event: string[]) => {
  tempFilters.value = $event;

  emit("parentUpdated", tempFilters.value);
};

onMounted(async () => {
  tempFilters.value = props.parentPolicyType?.filters ?? [];
});
</script>
<template>
  <div class="mm-mt-8">
    <m-m-table
      :headers="headers"
      :is-loading="isLoading"
      :empty-state="emptyState"
      :rows="computedFilters"
      cy="child-filters"
      :description="description"
    >
      <template #empty-state-button>
        <m-m-button
          v-if="displayAddButton"
          variant="elevated"
          size="small"
          prepend-icon="plus-white"
          class="mm-ml-auto"
          cy="empty-state-add-filter-button"
          @click="toggleAddFilterDialog"
        >
          Add filter
        </m-m-button>
      </template>
      <template v-if="displayAddButton" #action>
        <m-m-button
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto"
          cy="add-filter-button"
          @click="toggleAddFilterDialog"
        >
          Add filter
        </m-m-button>
      </template>
      <template #actions="{ row }">
        <m-m-dropdown
          :cy="`dropdown-${row.id}`"
          :items="
            mode === 'edit' || mode === 'create'
              ? [
                  {
                    label: `Go to ${row?.name ? row.name : 'filter'}`,
                    type: 'link',
                    to: `/sp/${serviceProviderId}/filters/${row.id}`,
                  },
                  {
                    label: `Remove ${parentPolicyType?.name ? 'from ' : ''}${parentPolicyType?.name}`,
                    type: 'button',
                    color: 'error',
                    onClick: () => {
                      tryToRemoveFromParent(row);
                    },
                  },
                ]
              : [
                  {
                    label: `Go to ${row?.name ? row.name : 'filter'}`,
                    type: 'link',
                    to: `/sp/${serviceProviderId}/filters/${row.id}`,
                  },
                ]
          "
        >
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

    <filter-add
      :is-open="isAddFilterDialogOpen"
      :service-provider-id="serviceProviderId"
      :parent-policy-type="parentPolicyType"
      :selected-filters="computedFilters"
      @close="toggleAddFilterDialog"
      @submit="updateFilter"
      @remove-filter="tryToRemoveFromParent"
      @update-prepared-filters="handlePreparedFilters"
    />

    <m-m-dialog
      :is-open="isConfirmDeleteDialogOpen"
      title="Remove filter"
      icon="warning"
      icon-color="error"
      :subtitle="`Are you sure you want to remove ${filterToRemove?.name} from ${parentPolicyType?.name}?`"
      cy="confirm-remove-from-parent"
      @close="toggleConfirmDelete"
    >
      <template #footer>
        <m-m-button
          variant="outlined"
          data-cy="button-cancel-remove-from-parent"
          @click="toggleConfirmDelete"
        >
          No
        </m-m-button>
        <m-m-button
          variant="danger"
          data-cy="button-confirm-remove-from-parent"
          :disabled="isButtonSubmitDisabled"
          :loading="isButtonSubmitLoading"
          @click="removeFromParent"
        >
          Yes, remove
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
