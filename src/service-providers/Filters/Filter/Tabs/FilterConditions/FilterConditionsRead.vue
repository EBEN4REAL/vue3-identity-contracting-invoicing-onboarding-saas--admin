<script setup lang="ts">
import { ref, onMounted, PropType, Ref, computed, ComputedRef } from "vue";
import { useRouter } from "vue-router";
import {
  TypeAttribute,
  TypeEnumAttributeSource,
  TypeComparisonOperator,
} from "~/service-providers/filters.type";
import {
  operatorsMappedForSelect,
  attributesMappedForSelect,
  dataPerAttribute,
  CRUD,
  dataMappedForSelect,
} from "../../../constants";
import { selectBooleanItems } from "./constants";
import { INDUSTRIES, JOB_ROLES } from "~/common/constants";
import MMInput from "~/mm_ui_kit/src/components/MMInput.vue";
import MMSelect from "~/mm_ui_kit/src/components/MMSelect.vue";
import {
  FilterItem,
  FilterItemRead,
  FilterRead,
  NestedFilterRead,
} from "~/service-providers/Filters/filters.types";
import FilterNested from "./FilterNested.vue";
import ComparisonOperator from "./ComparisonOperator.vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  ResourceAttributeTypeInUseRead,
  ResourceTypeRead,
} from "~/policies/policies.types";
import { filtersService } from "~/configuration/filters.service";
import { resourceTypesService } from "~/configuration/resource-types.service";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { isValidUUID } from "~/mm_ui_kit/src/helpers/errorIDValidator";
import { attributeTypesService } from "~/service-providers/attributeTypesService";

const router = useRouter();

const props = defineProps({
  items: {
    type: Array as PropType<FilterItemRead[] | null>,
    default: () => [],
  },
  nestedFiltersIds: {
    type: Array as PropType<NestedFilterRead[] | null>,
    default: () => [],
  },
  comparisonOperator: {
    type: String as PropType<TypeComparisonOperator>,
    default: "EMPTY",
  },
  serviceProviderId: {
    type: String,
    default: null,
  },
});

const nestedFilters: Ref<FilterRead[]> = ref([]);
const resourceTypesForSelect = ref([]);
const resourceAttributeTypesForSelect = ref([]);
const attributeTypeAttributesForSelect = ref([]);

const filterConditionItemClassList = (filterConditionItem: FilterItem) => {
  const classList = [
    "filter-condition-item",
    "mm-grid",
    "mm-grid-column-gap-12",
  ];
  if (filterConditionItem.attribute_source === "RESOURCE") {
    if (filterConditionItem.attribute_type === "=OPERATION=") {
      classList.push("mm-grid-columns-3");
      return classList;
    }
    classList.push("mm-grid-columns-4");
    return classList;
  }
  classList.push("mm-grid-columns-3");
  return classList;
};

// Get value based on what MMSelect is rendered
const formattedValue = (filterConditionItem: FilterItem) => {
  if (filterConditionItem.attribute_type === "industry") {
    return INDUSTRIES.find(
      (industry) => industry.value === filterConditionItem.value,
    )?.value;
  }
  if (filterConditionItem.attribute_type === "job_role") {
    return JOB_ROLES.find(
      (jobRole) => jobRole.value === filterConditionItem.value,
    )?.value;
  }
  if (filterConditionItem.attribute_type === "account_verified") {
    return selectBooleanItems.find(
      (booleanItem) => booleanItem.value === filterConditionItem.value,
    )?.value;
  }
  return filterConditionItem.value;
};

// Based on attribute_source and attribute_type different component is being rendered
const componentByAttribute = (
  attribute_source: TypeEnumAttributeSource | null,
  attribute_type: string | null,
) => {
  const attribute = `${attribute_source}__${attribute_type}` as TypeAttribute;
  const component = dataPerAttribute[attribute]?.component;
  if (component === "select-boolean" || component === "select-enum")
    return MMSelect;
  else return MMInput;
};

// Based on attribute_source and attribute_type different items for MMSelect
const selectItemsByAttribute = (
  attribute_source: TypeEnumAttributeSource | null,
  attribute_type: string | null,
) => {
  const attribute = `${attribute_source}__${attribute_type}` as TypeAttribute;
  const component = dataPerAttribute[attribute]?.component;
  if (component === "select-enum") {
    if (attribute_type === "job_role") return JOB_ROLES;
    if (attribute_type === "industry") return INDUSTRIES;
    if (attribute_type === "=OPERATION=") return dataMappedForSelect(CRUD);
  } else if (component === "select-boolean") return selectBooleanItems;
  else return null;
};

// Define data-cy attribute based on attribute_type
const valueCyByAttributeType = (attribute_type: string | null) => {
  if (
    attribute_type === "job_role" ||
    attribute_type === "industry" ||
    attribute_type === "account_verified" ||
    attribute_type === "=OPERATION="
  )
    return "select-filter-condition-value";
  return "input-filter-condition-value";
};

// Define data-select attribute based on attribute_type
const dataSelectValueByAttributeType = (filterConditionItem: FilterItem) => {
  if (
    filterConditionItem.attribute_type === "job_role" ||
    filterConditionItem.attribute_type === "industry" ||
    filterConditionItem.attribute_type === "=OPERATION=" ||
    filterConditionItem.attribute_type === "account_verified"
  )
    return formattedValue(filterConditionItem);
  return null;
};

const onGoToFilter = (filter_id: string) => {
  router.push(`/sp/${props.serviceProviderId}/filters/${filter_id}`);
};

// Nested filters are being fetched by id in parallel requests for optimization
// After that they are pushed into nestedFilters array
const setInitialNestedFilters = async () => {
  if (!props.nestedFiltersIds?.length) return;
  const requests = props.nestedFiltersIds.map((child: NestedFilterRead) =>
    filtersService.getFilterById(
      props.serviceProviderId,
      child.child_filter_id,
    ),
  );

  nestedFilters.value = await Promise.all(requests);
};

const generateResourceTypesForSelect = async () => {
  try {
    const promises = props.items?.map((filterCondition) => {
      if (
        filterCondition.attribute_source === "RESOURCE" &&
        filterCondition.attribute_type !== "=OPERATION="
      ) {
        return resourceTypesService.getResourceType(
          props.serviceProviderId,
          filterCondition.attribute_type.split("?=")[0],
        );
      }

      return null;
    });

    const response = await Promise.all(promises);
    resourceTypesForSelect.value = response.map(
      (resourceType: ResourceTypeRead | null) => {
        if (resourceType) {
          return [
            {
              title: resourceType.name,
              value: resourceType.id,
            },
          ];
        }

        return null;
      },
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching resource types",
      status: "error",
    });
  }
};

const resourceTypeValue = (attribute_type: string): string =>
  attribute_type.split("?=")[0];

const generateResourceAttributeTypesForSelect = async () => {
  try {
    const promises = props.items?.map((filterCondition) => {
      if (
        filterCondition.attribute_source === "RESOURCE" &&
        filterCondition.attribute_type !== "=OPERATION="
      ) {
        return resourceAttributeTypesService.getResourceAttributeType(
          props.serviceProviderId,
          filterCondition.attribute_type.split("?=")[1],
        );
      }

      return null;
    });

    const response = await Promise.all(promises);
    resourceAttributeTypesForSelect.value = response.map(
      (resourceAttributeType: ResourceAttributeTypeInUseRead | null) => {
        if (resourceAttributeType) {
          return [
            {
              title: resourceAttributeType.name,
              value: resourceAttributeType.id,
            },
          ];
        }

        return null;
      },
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching resource attribute types",
      status: "error",
    });
  }
};

const generateAttributeTypesForSelect = async () => {
  try {
    const attributeTypes = props.items?.filter((filter) =>
      isValidUUID(filter.attribute_type),
    );

    if (!attributeTypes) return;

    const attributeTypeRes = await Promise.all(
      attributeTypes?.map((attributeType) =>
        attributeTypesService.getAttributeType(
          props.serviceProviderId,
          attributeType.attribute_type,
        ),
      ),
    );

    attributeTypeAttributesForSelect.value = attributeTypeRes.map(
      (attributeType) => ({
        title: attributeType.name,
        value: attributeType.id,
      }),
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching attribute types",
      status: "error",
    });
  }
};

const resourceAttributeTypeValue = (attribute_type: string): string =>
  attribute_type.split("?=")[1];

const isResourceFilterCondition = (filter: FilterItem) =>
  filter.attribute_source === "RESOURCE" &&
  filter.attribute_type !== "=OPERATION=";

const isEmptyPlaceholderVisible: ComputedRef<boolean> = computed(
  () => !props.items?.length && !nestedFilters.value.length,
);

onMounted(async () => {
  await setInitialNestedFilters();
  await generateResourceTypesForSelect();
  await generateResourceAttributeTypesForSelect();
  await generateAttributeTypesForSelect();
});
</script>

<template>
  <div class="mm-flex mm-flex-column filters-container">
    <template v-if="items?.length">
      <div
        v-for="(filter, filterIndex) in items"
        :key="filter.id"
        :data-cy="`filter-condition-${filterIndex}`"
        :class="filterConditionItemClassList(filter)"
      >
        <template v-if="isResourceFilterCondition(filter)">
          <m-m-select
            :model-value="resourceTypeValue(filter.attribute_type)"
            :items="resourceTypesForSelect[filterIndex]"
            disabled
            :data-select-value="resourceTypeValue(filter.attribute_type)"
            cy="select-filter-condition-resource-type"
          />
          <m-m-select
            :model-value="resourceAttributeTypeValue(filter.attribute_type)"
            :items="resourceAttributeTypesForSelect[filterIndex]"
            disabled
            :data-select-value="
              resourceAttributeTypeValue(filter.attribute_type)
            "
            cy="select-filter-condition-resource-attribute-type"
          />
        </template>
        <template v-else>
          <!-- is attribute type -->
          <m-m-select
            v-if="isValidUUID(filter.attribute_type)"
            :model-value="filter.attribute_type"
            :items="attributeTypeAttributesForSelect"
            disabled
            :data-select-value="`${filter.attribute_source}__${filter.attribute_type}`"
            cy="select-filter-condition-attribute"
          />
          <m-m-select
            v-else
            :model-value="`${filter.attribute_source}__${filter.attribute_type}`"
            :items="attributesMappedForSelect"
            disabled
            :data-select-value="`${filter.attribute_source}__${filter.attribute_type}`"
            cy="select-filter-condition-attribute"
          />
        </template>
        <m-m-select
          :model-value="filter.operator"
          :items="operatorsMappedForSelect"
          disabled
          :data-select-value="filter.operator"
          cy="select-filter-condition-operator"
        />
        <component
          :is="
            componentByAttribute(filter.attribute_source, filter.attribute_type)
          "
          :model-value="formattedValue(filter)"
          :items="
            selectItemsByAttribute(
              filter.attribute_source,
              filter.attribute_type,
            )
          "
          disabled
          :data-select-value="dataSelectValueByAttributeType(filter)"
          :cy="valueCyByAttributeType(filter.attribute_type)"
        />
        <comparison-operator
          :comparison-operator="comparisonOperator"
          data-cy="filter-condition-comparison-operator"
        />
      </div>
    </template>
    <template v-if="nestedFilters.length">
      <div
        v-for="(nestedFilter, nestedFilterIndex) in nestedFilters"
        :key="nestedFilter.id"
        :data-cy="`filter-condition-existing-${nestedFilterIndex}`"
        class="filter-condition-item mm-flex mm-flex-column"
      >
        <filter-nested
          :filter="nestedFilter"
          no-remove
          @go-to-filter="onGoToFilter(nestedFilter.id)"
        />
        <comparison-operator
          :comparison-operator="comparisonOperator"
          data-cy="filter-condition-comparison-operator"
        />
      </div>
    </template>
    <div v-if="isEmptyPlaceholderVisible" class="mm-page-item-value mm-px-2">
      No filter conditions configured
    </div>
  </div>
</template>

<style scoped lang="scss">
.filters-container {
  width: 97%;
  padding: 0 0 30px 0;
}
.filter-condition-item {
  &:last-child {
    .comparison-operator {
      display: none;
    }
  }
}

.comparison-operator {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 30px;
  font-size: 14px;
  font-weight: 600;
  line-height: 20px;
  text-align: left;
  color: #9da4ae;
  margin-left: 14px;
  text-transform: uppercase;

  &:before,
  &:after {
    content: "";
    width: 1px;
    height: 23px;
    background-color: #9da4ae;
  }
}
</style>
