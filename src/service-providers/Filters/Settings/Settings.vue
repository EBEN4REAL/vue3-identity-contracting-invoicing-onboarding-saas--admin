<script setup lang="ts">
import {
  PropType,
  reactive,
  ref,
  Ref,
  watch,
  defineEmits,
  ComputedRef,
  computed,
  toRef,
} from "vue";
import BasicInformationEdit from "../Filter/Tabs/BasicInformation/BasicInformationEdit.vue";
import BasicInformationRead from "../Filter/Tabs/BasicInformation/BasicInformationRead.vue";
import { FilterItemRead, FilterRead, TypeNestedFilter } from "../filters.types";
import {
  TypeFilterBasicInformationData,
  TypeFilterBasicInformationForm,
  TypeValidationFilterBasicInformation,
  TypeValidatorFilterCondition,
} from "../Filter/Tabs/types";
import FilterConditionsEdit from "../Filter/Tabs/FilterConditions/FilterConditionsEdit.vue";
import FilterConditionsRead from "../Filter/Tabs/FilterConditions/FilterConditionsRead.vue";
import { TypeComparisonOperator } from "~/service-providers/filters.type";
const props = defineProps({
  nestedFiltersIds: {
    type: Array as PropType<TypeNestedFilter[]>,
    default: () => [],
  },
  serviceProviderId: { type: String, default: "" },
  data: {
    type: Object as PropType<TypeFilterBasicInformationData>,
    default: () => ({}),
  },
  mode: {
    type: String as PropType<"create" | "edit">,
    default: "",
  },
  filter: {
    type: Object as PropType<FilterRead>,
    default: () => ({}),
  },
  isExpandableBasicInfoOpen: {
    type: Boolean,
    default: true,
  },
  isExpandableFiltersConditionsOpen: {
    type: Boolean,
    default: true,
  },
});
const basicInformationEditRef: Ref<{
  form: TypeFilterBasicInformationForm;
  v$: TypeValidationFilterBasicInformation;
} | null> = ref(null);
const isBasicInformationOpen = toRef(props, "isExpandableBasicInfoOpen");
const isFiltersConditionsOpen = toRef(
  props,
  "isExpandableFiltersConditionsOpen",
);
const title: ComputedRef<string> = computed(
  () => basicInformationEditRef.value?.form.name || props.filter?.name || "",
);
const basicInformationData: Ref<TypeFilterBasicInformationData> = computed(
  () => ({
    name: props.data?.name || "",
    description: props.data?.description || null,
  }),
);

const filterConditionsEditRef: Ref<{
  filter_items: FilterItemRead[];
  filters: FilterRead[];
  operator: TypeComparisonOperator;
  v$List: TypeValidatorFilterCondition[];
} | null> = ref(null);

const isInEditMode: ComputedRef<boolean> = computed(
  () => props.mode === "edit",
);
const isInCreateMode: ComputedRef<boolean> = computed(
  () => props.mode === "create",
);
const emit = defineEmits([
  "update:basicInfoOpen",
  "update:filtersConditionsOpen",
]);

const form: TypeFilterBasicInformationForm = reactive({
  name: "",
  description: "",
});

watch(
  () => props.data,
  () => {
    form.name = props.data.name;
    form.description = props.data.description;
  },
  {
    immediate: true,
  },
);

defineExpose({
  basicInformationEditRef,
  filterConditionsEditRef,
});
</script>

<template>
  <div>
    <m-m-expandable-card
      title="Basic information"
      :is-opened="isBasicInformationOpen"
      :required="isInEditMode || isInCreateMode"
      @update:is-opened="emit('update:basicInfoOpen', $event)"
    >
      <basic-information-edit
        v-if="isInEditMode || isInCreateMode"
        ref="basicInformationEditRef"
        :data="basicInformationData"
      />
      <basic-information-read v-else :data="data" />
    </m-m-expandable-card>
    <m-m-expandable-card
      class="mm-mt-10"
      title="Filter conditions"
      :is-opened="isFiltersConditionsOpen"
      :required="isInEditMode || isInCreateMode"
      @update:is-opened="emit('update:filtersConditionsOpen', $event)"
    >
      <filter-conditions-edit
        v-if="isInEditMode || isInCreateMode"
        ref="filterConditionsEditRef"
        :items="filter?.filter_items"
        :nested-filters-ids="filter?.filters"
        :comparison-operator="filter?.operator"
        :service-provider-id="serviceProviderId"
        :filter-name="title"
      />
      <filter-conditions-read
        v-else
        :items="filter?.filter_items"
        :nested-filters-ids="filter?.filters"
        :comparison-operator="filter?.operator"
        :service-provider-id="serviceProviderId"
      />
    </m-m-expandable-card>
  </div>
</template>
<style lang="css" scoped>
::v-deep(.mm-expandable-card) {
  overflow: visible;
}
</style>
