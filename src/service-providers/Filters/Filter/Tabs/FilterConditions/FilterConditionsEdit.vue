<script setup lang="ts">
import {
  computed,
  onMounted,
  PropType,
  ref,
  reactive,
  Ref,
  ComputedRef,
  Reactive,
} from "vue";
import { useRouter } from "vue-router";
import {
  attributesMappedForSelect,
  CRUD,
  dataMappedForSelect,
  dataPerAttribute,
  operators,
} from "../../../constants";
import { INDUSTRIES, JOB_ROLES } from "~/common/constants";
import {
  selectBooleanItems,
  shortcutsForDatepickers,
  inputPlaceholderByAttribute,
  comparisonOperators,
} from "./constants";
import {
  TypeAttribute,
  TypeComparisonOperator,
  TypeEnumOperator,
} from "~/service-providers/filters.type";
import { useVuelidate } from "@vuelidate/core";
import { helpers, maxLength, minLength, required } from "@vuelidate/validators";
import {
  TypeFilterConditionFormRules,
  TypeValidatorFilterCondition,
} from "~/service-providers/Filters/Filter/Tabs/types";
import { TypeEnumAttributeSource } from "~/service-providers/filters.type";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  FilterItem,
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
import DialogAddNestedFilters from "~/service-providers/Filters/Filter/Dialogs/DialogAddNestedFilters.vue";
import { attributeTypesService } from "~/service-providers/attributeTypesService";
import {
  AttributeSetAttributesOf,
  AttributeTypeRead,
} from "~/onboarding/onboarding.types";
import { isValidUUID } from "~/mm_ui_kit/src/helpers/errorIDValidator";
import cloneDeep from "lodash/cloneDeep";

const router = useRouter();

const props = defineProps({
  items: {
    type: Array as PropType<FilterItem[]>,
    default: () => [],
  },
  nestedFiltersIds: {
    type: Array as PropType<NestedFilterRead[] | null>,
    default: () => [],
  },
  comparisonOperator: {
    type: String as PropType<TypeComparisonOperator>,
    default: null,
  },
  serviceProviderId: {
    type: String,
    default: null,
  },
  filterName: {
    type: String,
    default: "",
  },
});

const comparisonOperatorValue = ref(0);
const nestedFilters: Ref<FilterRead[]> = ref([]);
const filterItemsAttributes: TypeAttribute[] = reactive([]);
const formRulesList: Ref<TypeFilterConditionFormRules[]> = ref([]);
const defaultItemFormRules = reactive({
  attribute_type: {
    required: helpers.withMessage("Attribute is required", required),
  },
  operator: {
    required: helpers.withMessage("Operator is required", required),
  },
  value: {
    required: helpers.withMessage("Value is required", required),
  },
});
const v$List: Ref<TypeValidatorFilterCondition[]> = ref([]);
const isAddNestedFilterDialogOpened: Ref<boolean> = ref(false);
const resourceTypes: Ref<TableResponse<ResourceTypeRead> | null> = ref(null);
const resourceFilterConditionDataResourceTypeIds: Ref<string[]> = ref([]);
const resourceFilterConditionDataAttributeTypeIds: Ref<string[]> = ref([]);
const resourceAttributeTypes: Ref<ResourceAttributeTypeInUseRead[]> = ref([]);
const resourceTypesForSelect = ref([]);
const resourceAttributeTypesForSelect = ref([]);
const filter_items: Ref<FilterItem[]> = ref([]);
const attributesForSelect: Ref<{ title: string; value: string }[]> = ref(
  attributesMappedForSelect,
);
const isAttributesSelectDisabled: Ref<boolean> = ref(true);
const attributeTypesPerServiceProvider: Reactive<AttributeTypeRead[]> =
  reactive([]);

const operator = computed(
  () => comparisonOperators[comparisonOperatorValue.value],
);

const isButtonRemoveFilterDisabled: ComputedRef<boolean> = computed(
  (): boolean => filter_items.value.length + nestedFilters.value.length === 1,
);

// Mapping operators from "dataPerAttribute.operator" for MMSelect
const operatorsByAttributeMappedForSelect = (index: number) => {
  const attribute = filterItemsAttributes[index];

  const generateAttribute = (attributeAsString: string): TypeAttribute => {
    if (!attributeAsString) return attribute;
    let customAttribute = attributeAsString.split("__")[2];
    if (customAttribute === "uuid") customAttribute = "string";
    const customAttributeAsTypeAttribute = customAttribute
      ? (customAttribute.toUpperCase() as TypeAttribute)
      : null;
    return customAttributeAsTypeAttribute || attribute;
  };

  return dataPerAttribute[generateAttribute(attribute)]?.operators.map(
    (operator: TypeEnumOperator) => ({
      title: operators[operator],
      value: operator,
    }),
  );
};

// For different attribute there are different components to render
const componentByAttribute = (attribute: TypeAttribute) => {
  if (!attribute) return "input";
  let generatedAttribute = attribute;
  const [, , dataType] = attribute.split("__");
  if (dataType) {
    generatedAttribute = dataType.toUpperCase() as TypeAttribute;
  }
  return dataPerAttribute[generatedAttribute]?.component || "input";
};

const componentSelectEnumItemsByAttribute = (attribute: TypeAttribute) => {
  const [, attribute_type] = attribute.split("__");

  if (isValidUUID(attribute_type)) {
    const attributeType = attributeTypesPerServiceProvider.find(
      (attributeTypePerServiceProvider) =>
        attributeTypePerServiceProvider.id === attribute_type,
    );

    if (attributeType?.restrictions?.options) {
      return attributeType.restrictions.options.map((option) => ({
        title: option,
        value: option,
      }));
    }
  }

  if (attribute === "ORGANIZATION__industry") return INDUSTRIES;
  if (attribute === "ORGANIZATION_USER__job_role") return JOB_ROLES;
  if (attribute === "RESOURCE__=OPERATION=") return dataMappedForSelect(CRUD);
};

// When user removes filter condition
const onRemoveFilter = (filterIndex: number) => {
  filter_items.value.splice(filterIndex, 1); // remove filter condition from list
  filterItemsAttributes.splice(filterIndex, 1); // remove from values
  resourceFilterConditionDataResourceTypeIds.value.splice(filterIndex, 1);
  resourceFilterConditionDataAttributeTypeIds.value.splice(filterIndex, 1);
  resourceAttributeTypesForSelect.value.splice(filterIndex, 1);
  v$List.value.splice(filterIndex, 1); // remove from list of rules
  formRulesList.value.splice(filterIndex, 1); // remove from list of rules
};

const addFilterCondition = () => {
  filter_items.value.push({
    attribute_source: null,
    attribute_type: "",
    operator: null,
    value: null,
  });
  // Mechanics with last added filter item is needed to avoid creating new object that will lose reference
  const v$: TypeValidatorFilterCondition = useVuelidate(
    defaultItemFormRules,
    filter_items.value[filter_items.value.length - 1],
  );
  formRulesList.value.push(defaultItemFormRules);
  // ...and push it into list to validate later all of them
  v$List.value.push(v$);
};

const addResourceFilterCondition = () => {
  filter_items.value.push({
    attribute_source: "RESOURCE",
    attribute_type: "",
    operator: null,
    value: null,
  });
  // Mechanics with last added filter item is needed to avoid creating new object that will lose reference
  const v$: TypeValidatorFilterCondition = useVuelidate(
    defaultItemFormRules,
    filter_items.value[filter_items.value.length - 1],
  );
  formRulesList.value.push(defaultItemFormRules);
  // ...and push it into list to validate later all of them
  v$List.value.push(v$);
};

const toggleAddNestedFilterDialog = () => {
  isAddNestedFilterDialogOpened.value = !isAddNestedFilterDialogOpened.value;
};

// When user edits filter, three or four items already will be available and need to be set:

// 1. Comparison operators
const setInitialComparisonOperator = () => {
  const comparisonOperatorIndex = comparisonOperators.indexOf(
    props.comparisonOperator,
  );
  comparisonOperatorValue.value =
    comparisonOperatorIndex !== -1 ? comparisonOperatorIndex : 0;
};

// 2. Filter conditions
const setInitialFilterConditionValues = async () => {
  if (props.items?.length) {
    filter_items.value = props.items.map((filterConditionItem: FilterItem) => ({
      attribute_source: filterConditionItem.attribute_source,
      attribute_type: filterConditionItem.attribute_type,
      operator: filterConditionItem.operator,
      value: filterConditionItem.value,
      id: filterConditionItem.id,
    }));

    const promises = props.items.map(
      (filterConditionItem: FilterItem, index: number) => {
        if (
          filterConditionItem.attribute_source === "RESOURCE" &&
          filterConditionItem.attribute_type !== "=OPERATION="
        ) {
          const [resourceTypeId, resourceAttributeTypeId] =
            filterConditionItem.attribute_type.split("?=");

          onUpdateResourceType(resourceTypeId, index);

          resourceFilterConditionDataResourceTypeIds.value[index] =
            resourceTypeId;
          resourceFilterConditionDataAttributeTypeIds.value[index] =
            resourceAttributeTypeId;

          return getServiceProviderResourceAttributeTypeById(
            resourceAttributeTypeId,
          );
        } else if (isValidUUID(filterConditionItem.attribute_type)) {
          return attributeTypesService.getAttributeType(
            props.serviceProviderId,
            filterConditionItem.attribute_type,
          );
        } else {
          return `${filterConditionItem.attribute_source}__${filterConditionItem.attribute_type}`;
        }
      },
    );

    const attributesResponses = await Promise.all(promises);

    const attributes = attributesResponses.map((attributeResponse) => {
      if (typeof attributeResponse === "string") return attributeResponse;
      if (Object.hasOwnProperty.call(attributeResponse, "format_option"))
        return attributeResponse.format_option;

      const attributeOf =
        attributeResponse.attribute_of === "USER"
          ? "ORGANIZATION_USER"
          : attributeResponse.attribute_of;
      return `${attributeOf}__${attributeResponse.id}__${attributeResponse.data_type}`;
    }) as TypeAttribute[];

    filterItemsAttributes.push(...attributes);
  } else {
    addFilterCondition();
  }
};

const generateFormRuleEntity = {
  email: helpers.withMessage("Email should be correct", (value: string) =>
    value
      ? /^[\w+.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:,[\w+.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})*$/.test(
          value,
        )
      : true,
  ),
  uuid: (name: string) =>
    helpers.withMessage(`${name} should be correct UUID`, (value) =>
      value ? isValidUUID(`${value}`) : true,
    ),
  minLength: (name: string, min_length: number) =>
    helpers.withMessage(
      `${name} must be at least ${min_length} characters long`,
      minLength(min_length),
    ),
  maxLength: (name: string, max_length: number) =>
    helpers.withMessage(
      `${name} must be at most ${max_length} characters long`,
      maxLength(max_length),
    ),
};

const checkIsAttributeTypeHasRestrictions = (
  restrictions: Record<string, never> | null,
) =>
  restrictions && Object.values(restrictions).some((value) => value !== null);

// 3. List of validations
const setInitialValidations = () => {
  v$List.value = [];
  formRulesList.value = [];

  filter_items.value.forEach((formItem: FilterItem, formItemIndex: number) => {
    const itemFormRules = cloneDeep(defaultItemFormRules);

    if (formItem.attribute_type === "email") {
      itemFormRules.value.email = generateFormRuleEntity.email;
    }

    const attributeType = attributeTypesPerServiceProvider.find(
      (attributeTypePerServiceProvider) =>
        attributeTypePerServiceProvider.id === formItem.attribute_type,
    );

    if (attributeType) {
      if (attributeType.data_type === "uuid") {
        itemFormRules.value.uuid = generateFormRuleEntity.uuid(
          attributeType.name,
        );
      }

      if (checkIsAttributeTypeHasRestrictions(attributeType.restrictions)) {
        const { min_length, max_length } = attributeType.restrictions;

        if (min_length) {
          itemFormRules.value.minLength = generateFormRuleEntity.minLength(
            attributeType.name,
            min_length,
          );
        } else delete itemFormRules.value.minLength;

        if (max_length) {
          itemFormRules.value.maxLength = generateFormRuleEntity.maxLength(
            attributeType.name,
            max_length,
          );
        } else delete itemFormRules.value.maxLength;
      }
    }

    formRulesList.value.push(itemFormRules);
    v$List.value.push(
      useVuelidate(itemFormRules, filter_items.value[formItemIndex]),
    );
  });
};

// 4. Optional item are nested filters
// They are being fetched by id in parallel requests for optimization
// After that they are pushed into nestedFilters array
const setInitialNestedFilters = async () => {
  if (!props.nestedFiltersIds?.length) return;
  const requests = props.nestedFiltersIds.map(
    (nestedFilter: NestedFilterRead) =>
      filtersService.getFilterById(
        props.serviceProviderId,
        nestedFilter.child_filter_id,
      ),
  );

  const existingNestedFilters: FilterRead[] = await Promise.all(requests);
  nestedFilters.value.push(...existingNestedFilters);
};

const setFilterItemConditionFormRules = (
  filterConditionIndex: number,
  attribute_type: string,
) => {
  const attributeType = attributeTypesPerServiceProvider.find(
    (attributeTypePerServiceProvider) =>
      attributeTypePerServiceProvider.id === attribute_type,
  );

  if (attribute_type === "email") {
    formRulesList.value[filterConditionIndex].value.email =
      generateFormRuleEntity.email;
  } else delete formRulesList.value[filterConditionIndex].value.email;

  if (attributeType) {
    formRulesList.value[filterConditionIndex].value.required =
      helpers.withMessage(`${attributeType.name} is required`, required);

    if (attributeType.data_type === "uuid") {
      formRulesList.value[filterConditionIndex].value.uuid =
        generateFormRuleEntity.uuid(attributeType.name);
    } else delete formRulesList.value[filterConditionIndex].value.uuid;

    if (checkIsAttributeTypeHasRestrictions(attributeType.restrictions)) {
      const { min_length, max_length } = attributeType.restrictions;

      if (min_length) {
        formRulesList.value[filterConditionIndex].value.minLength =
          generateFormRuleEntity.minLength(attributeType.name, min_length);
      } else delete formRulesList.value[filterConditionIndex].value.minLength;

      if (max_length) {
        formRulesList.value[filterConditionIndex].value.maxLength =
          generateFormRuleEntity.maxLength(attributeType.name, max_length);
      } else delete formRulesList.value[filterConditionIndex].value.maxLength;
    } else {
      delete formRulesList.value[filterConditionIndex].value.minLength;
      delete formRulesList.value[filterConditionIndex].value.maxLength;
    }
  } else {
    formRulesList.value[filterConditionIndex].value.required =
      helpers.withMessage("Value is required", required);
    delete formRulesList.value[filterConditionIndex].value.minLength;
    delete formRulesList.value[filterConditionIndex].value.maxLength;
  }

  v$List.value[filterConditionIndex] = useVuelidate(
    formRulesList.value[filterConditionIndex],
    filter_items.value[filterConditionIndex],
  );
};

// As soon as user changes first select (attribute), operator and value needs to be dropped
const onAttributeUpdate = (
  attribute: TypeAttribute,
  filterConditionIndex: number,
) => {
  if (attribute.includes("__")) {
    const [attribute_source, attribute_type] = attribute.split("__");
    filter_items.value[filterConditionIndex].attribute_source =
      attribute_source as TypeEnumAttributeSource;
    filter_items.value[filterConditionIndex].attribute_type = attribute_type;

    setFilterItemConditionFormRules(filterConditionIndex, attribute_type);
  } else {
    filter_items.value[filterConditionIndex].attribute_source = "RESOURCE";
    filter_items.value[filterConditionIndex].attribute_type = attribute;
  }
  filter_items.value[filterConditionIndex].operator =
    operatorsByAttributeMappedForSelect(filterConditionIndex)[0].value;
  filter_items.value[filterConditionIndex].value = null;
  v$List.value[filterConditionIndex].value.$reset(); // validation is also needs to be reset
};

const getAttributeTypesPerServiceProvider = async (
  params: TableRequestParams,
) => {
  try {
    isAttributesSelectDisabled.value = true;
    const response: TableResponse<AttributeTypeRead> =
      await attributeTypesService.getAttributeTypesPerServiceProvider(
        props.serviceProviderId,
        params,
      );

    if (!response) return;

    const generateAttributeSource = (
      attributeOf: AttributeSetAttributesOf,
    ): TypeEnumAttributeSource => {
      switch (attributeOf) {
        case "USER":
          return TypeEnumAttributeSource.ORGANIZATION_USER;
        case "ORGANIZATION":
        default:
          return TypeEnumAttributeSource.ORGANIZATION;
      }
    };

    attributeTypesPerServiceProvider.push(...response.results);

    attributesForSelect.value = [
      ...attributesForSelect.value,
      ...response.results.map((attributeType) => ({
        title: attributeType.name,
        value: `${generateAttributeSource(attributeType.attribute_of)}__${attributeType.id}__${attributeType.data_type}`,
      })),
    ];
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: err,
      status: "error",
    });
  } finally {
    isAttributesSelectDisabled.value = false;
  }
};

// Different inputs have different placeholders
// It generates placeholders based on combination of attribute_source and attribute_type
const generateInputPlaceholderByAttribute = (
  attribute_source: TypeEnumAttributeSource | null | undefined,
  attribute_type: string | null,
) => {
  if (isValidUUID(attribute_type)) {
    const attributeType = attributeTypesPerServiceProvider.find(
      (attributeTypePerServiceProvider) =>
        attributeTypePerServiceProvider.id === attribute_type,
    );

    if (attributeType) {
      if (
        attributeType.data_type === "string" ||
        attributeType.data_type === "uuid"
      )
        return `Enter ${attributeType.name}`;
      if (
        attributeType.data_type === "boolean" ||
        attributeType.data_type === "enum"
      )
        return `Select ${attributeType.name}`;
    }
  }
  const attribute = `${attribute_source}__${attribute_type}` as TypeAttribute;
  return inputPlaceholderByAttribute[attribute];
};

// This is method for adding nested filter to the filter conditions list from dialog
const onAddNestedFilter = async (selectedNestedFilterId: string) => {
  const nestedFilterToAdd = await filtersService.getFilterById(
    props.serviceProviderId,
    selectedNestedFilterId,
  );
  if (nestedFilterToAdd) nestedFilters.value.push(nestedFilterToAdd);
  toggleAddNestedFilterDialog();
};

// This is method for removing nested filter from the list
const onRemoveNestedFilter = (filterIndex: number) => {
  nestedFilters.value.splice(filterIndex, 1);
};

const onGoToFilter = (filter_id: string) => {
  router.push(`/sp/${props.serviceProviderId}/filters/${filter_id}`);
};

const isOperatorDisabled = (filterConditionItem: FilterItem, index: number) => {
  if (filterConditionItem.attribute_source === "RESOURCE") {
    if (filterConditionItem.attribute_type === "=OPERATION=")
      return !filterItemsAttributes[index];
    return !resourceFilterConditionDataAttributeTypeIds.value[index];
  }
  return !filterItemsAttributes[index];
};

const filterConditionItemClassList = (filterConditionItem: FilterItem) => {
  const classList = ["mm-grid", "mm-grid-column-gap-12"];
  if (filterConditionItem.attribute_source === "RESOURCE") {
    if (filterConditionItem.attribute_type === "=OPERATION=") {
      classList.push("filter-condition-item");
      return classList;
    }
    classList.push("resource-filter-condition-item");
    return classList;
  }
  classList.push("filter-condition-item");
  return classList;
};

const getServiceProviderResources = async (params: TableRequestParams) => {
  try {
    resourceTypes.value = await resourceTypesService.getResourcesTypes(
      props.serviceProviderId,
      params,
    );

    const resourceTypeForSelectChunk =
      resourceTypes.value?.results.map((resourceType) => ({
        value: resourceType.id,
        title: resourceType.name,
      })) || [];

    resourceTypesForSelect.value = [
      ...resourceTypesForSelect.value,
      ...resourceTypeForSelectChunk,
    ];
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching resource types",
      status: "error",
    });
  }
};

const getResourceTypeById = async (id: string) =>
  resourceTypesService.getResourceType(props.serviceProviderId, id);

const getServiceProviderResourceAttributeTypeById = async (
  resourceAttributeTypeId: string,
) =>
  resourceAttributeTypesService.getResourceAttributeType(
    props.serviceProviderId,
    resourceAttributeTypeId,
  );

const getResourceAttributeTypes = (resourceAttributeTypeIds: string[]) =>
  Promise.all(
    resourceAttributeTypeIds.map((resourceAttributeTypeId) =>
      getServiceProviderResourceAttributeTypeById(resourceAttributeTypeId),
    ),
  );

const onUpdateResourceType = async (resourceTypeId: string, index: number) => {
  resourceFilterConditionDataAttributeTypeIds.value[index] = null;

  const resourceType = await getResourceTypeById(resourceTypeId);

  resourceAttributeTypes.value[index] = await getResourceAttributeTypes(
    resourceType.resource_attribute_types as string[],
  );

  resourceAttributeTypesForSelect.value[index] = resourceAttributeTypes.value[
    index
  ].map((resourceAttributeType) => ({
    title: resourceAttributeType.name,
    value: resourceAttributeType.id,
  }));
};

const onUpdateResourceAttributeType = (
  resourceAttributeTypeId: string,
  index: number,
) => {
  const resourceAttributeTypeFoundById = resourceAttributeTypes.value[
    index
  ].find(
    (resourceAttributeType) =>
      resourceAttributeType.id === resourceAttributeTypeId,
  );
  filterItemsAttributes[index] =
    resourceAttributeTypeFoundById?.format_option || "STRING";

  filter_items.value[index].attribute_type =
    `${resourceFilterConditionDataResourceTypeIds.value[index]}?=${resourceFilterConditionDataAttributeTypeIds.value[index]}`;
};

const isResourceFilterCondition = (filter: FilterItem) =>
  filter.attribute_source === "RESOURCE" &&
  filter.attribute_type !== "=OPERATION=";

const generateItemsForSelect = (index: number) => {
  return componentSelectEnumItemsByAttribute(filterItemsAttributes[index]);
};

onMounted(async () => {
  setInitialComparisonOperator();
  await setInitialFilterConditionValues();
  await setInitialNestedFilters();
  await getServiceProviderResources({
    offset: "0",
    limit: "10",
  });
  await getAttributeTypesPerServiceProvider({
    limit: "50",
    offset: "0",
  });
  setInitialValidations();
});

defineExpose({
  filter_items,
  filters: nestedFilters,
  operator,
  v$List,
});
</script>

<template>
  <div class="filter-conditions-container">
    <div class="mm-flex mm-flex-column" style="margin-top: 10px">
      <div class="filter-conditions-subtitle mm-flex mm-flex-align-center">
        <div class="mm-page-subtitle--h2 mm-mr-4">Use</div>
        <m-m-toggle
          v-model="comparisonOperatorValue"
          :items="comparisonOperators"
          class="mm-mr-4"
        />
        <div class="mm-page-subtitle--h2 mm-flex-shrink-0 mm-mr-4">
          to the filters
        </div>
      </div>
      <div
        v-for="(filter, filterIndex) in filter_items"
        :key="filterIndex"
        :class="filterConditionItemClassList(filter)"
        :data-cy="`filter-condition-${filterIndex}`"
      >
        <template v-if="isResourceFilterCondition(filter)">
          <m-m-select
            v-model="resourceFilterConditionDataResourceTypeIds[filterIndex]"
            placeholder="Select Resource"
            :items="resourceTypesForSelect"
            cy="select-resource-type"
            :data-select-value="
              resourceFilterConditionDataResourceTypeIds[filterIndex]
            "
            @scrolled-to-end="getServiceProviderResources"
            @update:model-value="onUpdateResourceType($event, filterIndex)"
          />
          <m-m-select
            v-model="resourceFilterConditionDataAttributeTypeIds[filterIndex]"
            :disabled="
              !Boolean(resourceFilterConditionDataResourceTypeIds[filterIndex])
            "
            placeholder="Select Attribute Type"
            cy="select-resource-attribute-type"
            :data-select-value="
              resourceFilterConditionDataAttributeTypeIds[filterIndex]
            "
            :items="resourceAttributeTypesForSelect[filterIndex]"
            @update:model-value="
              onUpdateResourceAttributeType($event, filterIndex)
            "
          />
        </template>
        <template v-if="v$List[filterIndex]">
          <m-m-select
            v-if="!isResourceFilterCondition(filter)"
            v-model="filterItemsAttributes[filterIndex]"
            :disabled="isAttributesSelectDisabled"
            :items="attributesForSelect"
            errors-position="absolute"
            :errors="v$List[filterIndex].value.attribute_type.$errors"
            cy="select-filter-condition-attribute"
            @update:model-value="onAttributeUpdate($event, filterIndex)"
          />
          <m-m-select
            v-model="filter.operator"
            :items="operatorsByAttributeMappedForSelect(filterIndex)"
            :errors="v$List[filterIndex].value.operator.$errors"
            :disabled="isOperatorDisabled(filter, filterIndex)"
            errors-position="absolute"
            cy="select-filter-condition-operator"
          />
          <m-m-input
            v-if="
              componentByAttribute(filterItemsAttributes[filterIndex]) ===
              'input'
            "
            v-model="filter.value"
            :disabled="!filterItemsAttributes[filterIndex] || !filter.operator"
            errors-position="absolute"
            :errors="v$List[filterIndex].value.value?.$errors"
            :placeholder="
              generateInputPlaceholderByAttribute(
                filter.attribute_source,
                filter.attribute_type,
              )
            "
            cy="input-filter-condition-value"
            @blur="v$List[filterIndex].value?.$touch"
          />
          <m-m-select
            v-if="
              componentByAttribute(filterItemsAttributes[filterIndex]) ===
              'select-enum'
            "
            v-model="filter.value"
            :placeholder="
              generateInputPlaceholderByAttribute(
                filter.attribute_source,
                filter.attribute_type,
              )
            "
            :items="generateItemsForSelect(filterIndex)"
            :disabled="!filterItemsAttributes[filterIndex] || !filter.operator"
            :errors="v$List[filterIndex].value?.$errors"
            errors-position="absolute"
            cy="select-filter-condition-value"
          />
          <m-m-select
            v-if="
              componentByAttribute(filterItemsAttributes[filterIndex]) ===
              'select-boolean'
            "
            v-model="filter.value"
            :placeholder="
              generateInputPlaceholderByAttribute(
                filter.attribute_source,
                filter.attribute_type,
              )
            "
            :items="selectBooleanItems"
            :disabled="!filterItemsAttributes[filterIndex] || !filter.operator"
            :errors="v$List[filterIndex].value?.$errors"
            errors-position="absolute"
            cy="select-filter-condition-value"
          />
          <m-m-datepicker
            v-if="
              componentByAttribute(filterItemsAttributes[filterIndex]) ===
              'datepicker-date'
            "
            v-model="filter.value"
            :placeholder="
              generateInputPlaceholderByAttribute(
                filter.attribute_source,
                filter.attribute_type,
              )
            "
            popup-side="right"
            :datepicker-shortcuts="shortcutsForDatepickers.date"
            format="MMM D, YYYY"
            type="date"
            confirm
            confirm-text="Apply"
            :disabled="!filterItemsAttributes[filterIndex] || !filter.operator"
            errors-position="absolute"
            :errors="v$List[filterIndex].value?.$errors"
            cy="datepicker-filter-condition-value"
          />
          <m-m-datepicker
            v-if="
              componentByAttribute(filterItemsAttributes[filterIndex]) ===
              'datepicker-time'
            "
            v-model="filter.value"
            :placeholder="
              generateInputPlaceholderByAttribute(
                filter.attribute_source,
                filter.attribute_type,
              )
            "
            popup-side="right"
            :datepicker-shortcuts="shortcutsForDatepickers.time"
            format="HH:mm"
            type="time"
            confirm
            confirm-text="Apply"
            errors-position="absolute"
            :disabled="!filterItemsAttributes[filterIndex] || !filter.operator"
            :errors="v$List[filterIndex].value?.$errors"
            cy="datepicker-filter-condition-value"
          />
          <m-m-datepicker
            v-if="
              componentByAttribute(filterItemsAttributes[filterIndex]) ===
              'datepicker-datetime'
            "
            v-model="filter.value"
            :placeholder="
              generateInputPlaceholderByAttribute(
                filter.attribute_source,
                filter.attribute_type,
              )
            "
            popup-side="right"
            :datepicker-shortcuts="shortcutsForDatepickers.datetime"
            time-title-format="MMMM DD, YYYY"
            format="MMMM DD, YYYY HH:mm"
            type="datetime"
            confirm
            confirm-text="Apply"
            :disabled="!filterItemsAttributes[filterIndex] || !filter.operator"
            errors-position="absolute"
            :errors="v$List[filterIndex].value?.$errors"
            cy="datepicker-filter-condition-value"
          />
        </template>
        <m-m-button
          :is-disabled="isButtonRemoveFilterDisabled"
          class="button-remove-filter"
          variant="text"
          cy="button-remove-filter-condition"
          @click="onRemoveFilter(filterIndex)"
        >
          <m-m-icon icon="trash-black" width="auto" height="auto" />
        </m-m-button>
        <comparison-operator :comparison-operator="operator" />
      </div>
      <template v-if="nestedFilters.length">
        <div
          v-for="(nestedFilter, nestedFilterIndex) in nestedFilters"
          :key="nestedFilter.id"
          class="filter-condition-item mm-flex mm-flex-column"
          :data-cy="`filter-condition-existing-${nestedFilterIndex}`"
        >
          <filter-nested
            :filter="nestedFilter"
            @go-to-filter="onGoToFilter(nestedFilter.id)"
            @remove="onRemoveNestedFilter(nestedFilterIndex)"
          />
          <comparison-operator :comparison-operator="operator" />
        </div>
      </template>
    </div>
    <div class="d-flex mm-flex-gap-6 mm-mt-12">
      <m-m-button
        variant="outlined"
        prepend-icon="plus"
        size="small"
        cy="button-add-filter-condition"
        @click="addFilterCondition"
      >
        Add filter condition
      </m-m-button>
      <m-m-button
        variant="tertiary"
        prepend-icon="folder"
        size="small"
        cy="button-import-existing-filter"
        @click="toggleAddNestedFilterDialog"
      >
        Add existing filter
      </m-m-button>
      <m-m-button
        variant="outlined"
        prepend-icon="plus"
        size="small"
        cy="button-add-resource-filter-condition"
        @click="addResourceFilterCondition"
      >
        Add resource filter condition
      </m-m-button>
    </div>
  </div>

  <dialog-add-nested-filters
    :is-open="isAddNestedFilterDialogOpened"
    :service-provider-id="serviceProviderId"
    :filter-name="filterName"
    :already-added-nested-filters="nestedFilters"
    @submit="onAddNestedFilter"
    @close="toggleAddNestedFilterDialog"
  />
</template>

<style lang="scss" scoped>
.filter-conditions-container {
  width: 97%;
  padding: 0 0 30px 0;
}
.filter-conditions-subtitle {
  color: #072e51;
  margin-bottom: 34px;

  &:after {
    content: "";
    width: 100%;
    height: 1px;
    background-color: #d2d6db;
  }
}

.filter-condition-item {
  grid-template-columns: repeat(3, 1fr) auto;

  &:last-of-type {
    .comparison-operator {
      display: none;
    }
  }
}

.resource-filter-condition-item {
  grid-template-columns: repeat(4, 1fr) auto;

  &:last-of-type {
    .comparison-operator {
      display: none;
    }
  }
}

.button-remove-filter {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background-color: #f3f4f6;
  border-radius: 6px;
}
</style>
