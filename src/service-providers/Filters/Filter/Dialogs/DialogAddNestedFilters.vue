<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { useRoute } from "vue-router";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { filtersService } from "~/configuration/filters.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { FilterRead } from "~/service-providers/Filters/filters.types";
import { TypeComparisonOperator } from "~/service-providers/filters.type";
import Multiselect from "vue-multiselect";
import { TypeNestedFilterForSelect } from "~/service-providers/Filters/Filter/Tabs/types";
import { useTranslation } from "i18next-vue";

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true,
    default: false,
  },
  serviceProviderId: {
    type: String,
    required: true,
    default: "",
  },
  filterName: {
    type: String,
    required: true,
    default: "",
  },
  alreadyAddedNestedFilters: {
    type: Array as PropType<FilterRead[]>,
    default: () => [],
  },
});

const emit = defineEmits(["close", "submit"]);

const route = useRoute();

const { t } = useTranslation();

const isNestedFiltersLoading: Ref<boolean> = ref(false);
const isButtonAddFilterDisabled: Ref<boolean> = ref(false);
const isButtonAddFilterLoading: Ref<boolean> = ref(false);
const selectedNestedFilter: Ref<TypeNestedFilterForSelect | null> = ref(null);
const filters: Ref<TableResponse<FilterRead>> = ref(null);
const filterSearch: Ref<string> = ref("");
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);

const nestedFiltersForSelect: ComputedRef<TypeNestedFilterForSelect[]> =
  computed(() =>
    filters.value?.results
      ? filters.value?.results.reduce((mappedFilters, filter) => {
          if (filter && filter.id !== route.params.filter_id) {
            const isFilterAlreadyAdded = props.alreadyAddedNestedFilters.some(
              (nestedFilter) => nestedFilter.id === filter.id,
            );
            mappedFilters.push({
              title: filter.name,
              value: filter.id,
              wizard: filter?.wizard,
              $isDisabled:
                isFilterAlreadyAdded || Boolean(filter?.wizard?.isolated),
            });
          }
          return mappedFilters;
        }, [] as TypeNestedFilterForSelect[])
      : [],
  );

const isButtonSubmitAddNestedFilterDisabled: ComputedRef<boolean> = computed(
  (): boolean => !Boolean(selectedNestedFilter.value),
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(filterSearch.value) &&
    !isNestedFiltersLoading.value &&
    !nestedFiltersForSelect.value.find(
      (nestedFilterItem) => nestedFilterItem.title === filterSearch.value,
    ),
);

const createFilterButtonText: ComputedRef<string> = computed(
  () => `Create filter "${filterSearch.value}"`,
);

const fetchFilters = async (params: TableRequestParams) => {
  try {
    isNestedFiltersLoading.value = true;

    filters.value = await filtersService.getFilters(
      props.serviceProviderId,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isNestedFiltersLoading.value = false;
  }
};

const onSearchChange = (value: string) => {
  filterSearch.value = value;
};

const onCreateFilter = async () => {
  try {
    isButtonAddFilterDisabled.value = true;
    isButtonAddFilterLoading.value = true;

    const filter: FilterRead = await filtersService.postFilter(
      {
        name: filterSearch.value,
        operator: TypeComparisonOperator.AND,
      },
      props.serviceProviderId,
    );

    selectedNestedFilter.value = {
      value: filter.id,
      title: filter.name,
    };

    multiselectRef.value?.closeMultiselect();

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: err?.response?.data?.detail || err,
      status: "error",
    });
  } finally {
    isButtonAddFilterDisabled.value = false;
    isButtonAddFilterLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Add Filters to ${filterName}`"
    icon="filter-stroke-primary"
    subtitle="Search & add filter:"
    cy="dialog-add-existing-filter"
    @close="emit('close')"
  >
    <m-m-multiselect
      ref="multiselectRef"
      v-model="selectedNestedFilter"
      :options="nestedFiltersForSelect"
      :loading="isNestedFiltersLoading"
      :total="filters?.total"
      searchable
      @search-change="onSearchChange"
      @update-params="fetchFilters"
    >
      <template v-if="isAfterListContentVisible" #afterListContent>
        <m-m-button
          :loading="isButtonAddFilterLoading"
          :is-disabled="isButtonAddFilterDisabled"
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
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-add-existing-filter"
        @click="emit('close')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        :is-disabled="isButtonSubmitAddNestedFilterDisabled"
        data-cy="button-submit-add-existing-filter"
        prepend-icon="plus-white"
        @click="emit('submit', selectedNestedFilter?.value)"
      >
        Add filter
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
