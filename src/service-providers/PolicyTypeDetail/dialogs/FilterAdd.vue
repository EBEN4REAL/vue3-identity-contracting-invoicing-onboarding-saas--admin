<script lang="ts" setup>
import { ref, Ref, PropType, computed, watch, ComputedRef } from "vue";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import { FilterRead } from "~/service-providers/Filters/filters.types";
import { filtersService } from "~/configuration/filters.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeComparisonOperator } from "~/service-providers/filters.type";
import Multiselect from "vue-multiselect";
import { useTranslation } from "i18next-vue";

const { t } = useTranslation();

const filters: Ref<FilterRead[]> = ref([]);
const filtersSelected: Ref<FilterRead[]> = ref([]);
const isFiltersLoading: Ref<boolean> = ref(false);
const filtersSearch: Ref<string> = ref("");
const isButtonAddFiltersDisabled: Ref<boolean> = ref(true);
const isButtonAddFiltersLoading: Ref<boolean> = ref(false);
const isButtonCreateFilterDisabled: Ref<boolean> = ref(false);
const isButtonCreateFilterLoading: Ref<boolean> = ref(false);
const totalItems: Ref<number> = ref(0);
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
    required: true,
  },
  parentPolicyType: {
    type: Object as PropType<PolicyTypeRead>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  selectedFilters: {
    type: Array as PropType<FilterRead[]>,
    default: () => [],
  },
});

const emit = defineEmits([
  "close",
  "submit",
  "removeFilter",
  "updatePreparedFilters",
]);

const title: ComputedRef<string> = computed(
  () => `Add filter to ${props.parentPolicyType?.name || "New policy"}`,
);

const filtersForSelect = computed(() =>
  filters.value.map((filter) => ({
    ...filter,
    title: filter.name,
    value: filter.id,
    wizard: filter?.wizard,
    $isDisabled:
      props.selectedFilters.some(
        (selectedFilter) => selectedFilter.id === filter.id,
      ) || Boolean(filter.wizard?.isolated),
  })),
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(filtersSearch.value) &&
    !isFiltersLoading.value &&
    !filtersForSelect.value.find(
      (filter) => filter.name === filtersSearch.value,
    ),
);

const createFilterButtonText: ComputedRef<string> = computed(
  () => `Create filter "${filtersSearch.value}"`,
);

const addFilterButtonText: ComputedRef<string> = computed(
  () =>
    `Add ${filtersSelected.value.length || ""} filter${filtersSelected.value.length > 1 ? "s" : ""}`,
);

const onAddFilters = (): void => {
  emit("updatePreparedFilters", filtersSelected.value);
  emit("close");
};

const getFilters = async (params: TableRequestParams) => {
  try {
    isFiltersLoading.value = true;

    const response = await filtersService.getFilters(
      props.serviceProviderId,
      params,
    );

    filters.value = response?.results || [];
    totalItems.value = response?.total || 0;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isFiltersLoading.value = false;
  }
};

const onCreateFilter = async () => {
  try {
    isButtonCreateFilterDisabled.value = true;
    isButtonCreateFilterLoading.value = true;
    const createdFilter: FilterRead = await filtersService.postFilter(
      {
        name: filtersSearch.value,
        operator: TypeComparisonOperator.AND,
      },
      props.serviceProviderId,
    );

    filtersSelected.value.push(createdFilter);

    multiselectRef.value?.closeMultiselect();

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error creating filter",
      status: "error",
    });
  } finally {
    isButtonCreateFilterDisabled.value = false;
    isButtonCreateFilterLoading.value = false;
  }
};

const onSearchChange = (value: string) => {
  filtersSearch.value = value;
};

watch(
  () => filtersSelected.value,
  () => {
    isButtonAddFiltersDisabled.value = filtersSelected.value.length === 0;
  },
  { immediate: true, deep: true },
);

watch(
  () => props.isOpen,
  () => {
    filtersSelected.value = [];
  },
  { immediate: true },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="title"
    icon="filter-add"
    cy="add-filter-dialog"
    @close="emit('close')"
  >
    <template #default>
      <form v-mm-focus-first class="mm-page-dialog-form">
        <m-m-multiselect
          ref="multiselectRef"
          v-model="filtersSelected"
          :options="filtersForSelect"
          :loading="isFiltersLoading"
          :total="totalItems"
          placeholder="Search child filter"
          label="Search & add child filter(s)"
          item-title="name"
          item-value="value"
          multiple
          searchable
          @search-change="onSearchChange"
          @update-params="getFilters"
        >
          <template v-if="isAfterListContentVisible" #afterListContent>
            <m-m-button
              :loading="isButtonCreateFilterLoading"
              :is-disabled="isButtonCreateFilterDisabled"
              @click="onCreateFilter"
            >
              {{ createFilterButtonText }}
            </m-m-button>
          </template>
          <template #disabled-text="{ option }">
            <span v-if="option.wizard?.isolated">
              {{ t("multiselect.part_of") }}
              <m-m-link :to="`/sp${option.wizard.path}`" class="mm-fs-16">
                {{ option.wizard.name }}
              </m-m-link>
            </span>
            <span v-else-if="option.$isDisabled">
              {{ t("multiselect.already_added") }}
            </span>
          </template>
        </m-m-multiselect>
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" @click="emit('close')">
        Cancel
      </m-m-button>
      <m-m-button
        variant="elevated"
        cy="add-filter-submit-button"
        :is-disabled="isButtonAddFiltersDisabled"
        :loading="isButtonAddFiltersLoading"
        prepend-icon="plus-white"
        @click="onAddFilters"
      >
        {{ addFilterButtonText }}
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
