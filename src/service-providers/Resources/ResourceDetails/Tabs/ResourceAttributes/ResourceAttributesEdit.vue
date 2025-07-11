<script setup lang="ts">
import { computed, ComputedRef, onMounted, PropType, ref, Ref } from "vue";
import { SELECT_OPTIONS_MAP } from "~/common/constants";
import { ResourceAttributeTypeRead } from "~/policies/policies.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { ResourceAttributeTypeInUseRead } from "~/configuration/configuration.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { TypeErrorResponse } from "~/mm_ui_kit/src/types/types";
import Multiselect from "vue-multiselect";
import { useTranslation } from "i18next-vue";

const { t } = useTranslation();

const props = defineProps({
  data: {
    type: Array as PropType<string[]>,
    default: () => [],
  },
  serviceProviderId: { type: String, default: "" },
});

const resourceAttributesTypes: Ref<TableResponse<ResourceAttributeTypeInUseRead> | null> =
  ref(null);
const resourceAttributesTypesValues: Ref<(ResourceAttributeTypeRead | null)[]> =
  ref([]);
const generatedErrors = ref([]);
const isResourceAttributesItemsForSelectLoading: Ref<boolean> = ref(false);
const isButtonAddResourceAttributeTypeLoading: Ref<boolean> = ref(false);
const isButtonAddResourceAttributeTypeDisabled: Ref<boolean> = ref(false);
const attributeTypeMultiselectSearch: Ref<string> = ref("");
const multiselectRefs: Ref<InstanceType<typeof Multiselect>[]> = ref([]);

const resourceAttributesTypesForSelect = computed(() => {
  if (!resourceAttributesTypes.value?.results) return [];

  const isResourceAttributeAlreadyAdded = (resourceAttributesTypeId: string) =>
    resourceAttributesTypesValues.value.find(
      (resourceAttributesTypeValue) =>
        resourceAttributesTypeValue?.id === resourceAttributesTypeId,
    );

  return resourceAttributesTypes.value?.results.map(
    (resourceAttributesType: ResourceAttributeTypeRead) => ({
      ...resourceAttributesType,
      $isDisabled:
        isResourceAttributeAlreadyAdded(resourceAttributesType.id) ||
        Boolean(resourceAttributesType.wizard?.isolated),
    }),
  );
});

const resourceAttributesTypesSelectedIds: ComputedRef<string[]> = computed(() =>
  resourceAttributesTypesValues.value
    .filter((resourceAttributesType) => resourceAttributesType)
    .map((resourceAttributesType) => resourceAttributesType?.id as string),
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(attributeTypeMultiselectSearch.value) &&
    !isResourceAttributesItemsForSelectLoading.value &&
    !resourceAttributesTypesForSelect.value.find(
      (attributeSet) =>
        attributeSet.title === attributeTypeMultiselectSearch.value,
    ),
);

const createResourceAttributeTypeButtonText: ComputedRef<string> = computed(
  () => `Create resource attribute "${attributeTypeMultiselectSearch.value}"`,
);

const resourceAttributesTypesTotal: ComputedRef<number> = computed(
  () => resourceAttributesTypes.value?.total || 0,
);

const getResourceAttributes = async (params: TableRequestParams) => {
  resourceAttributesTypes.value =
    await resourceAttributeTypesService.getResourceAttributeTypes(
      props.serviceProviderId as string,
      params,
    );
};

const getResourceAttributeType = async (
  id: string,
): Promise<ResourceAttributeTypeInUseRead> =>
  resourceAttributeTypesService.getResourceAttributeType(
    props.serviceProviderId as string,
    id,
  );

const getResourceAttributeTypesPerValues = async () => {
  resourceAttributesTypesValues.value = await Promise.all(
    props.data.map((id) => getResourceAttributeType(id)),
  );
};

const onAddAttribute = () => {
  resourceAttributesTypesValues.value.push(null);
};

const onRemoveAttribute = (index: number) => {
  resourceAttributesTypesValues.value.splice(index, 1);
  generatedErrors.value.splice(index, 1);
};

const checkForErrors = () => {
  const error = [
    {
      $property: "attribute",
      $validator: "required",
      $message: "Attribute is required",
    },
  ];
  generatedErrors.value = resourceAttributesTypesValues.value.map(
    (attribute) => (!attribute ? error : null),
  );
};

const onUpdateResourceAttributesTypeValue = (index: number) => {
  generatedErrors.value.splice(index, 1);
};

const onSearchChange = (value: string) => {
  attributeTypeMultiselectSearch.value = value;
};

const onCreateResourceAttributeType = async (index: number) => {
  try {
    isButtonAddResourceAttributeTypeDisabled.value = true;
    isButtonAddResourceAttributeTypeLoading.value = true;

    const response =
      await resourceAttributeTypesService.postResourceAttributeType(
        props.serviceProviderId,
        [
          {
            name: attributeTypeMultiselectSearch.value,
            format_option: "STRING",
          },
        ],
      );

    resourceAttributesTypesValues.value[index] = response[0];
    multiselectRefs.value[index]?.closeMultiselect();

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err as TypeErrorResponse),
      status: "error",
    });
  } finally {
    isButtonAddResourceAttributeTypeDisabled.value = false;
    isButtonAddResourceAttributeTypeLoading.value = false;
  }
};

const setInitialResourceAttributeTypesPerValues = () => {
  if (!resourceAttributesTypesValues.value.length) onAddAttribute();
};

onMounted(async () => {
  await getResourceAttributeTypesPerValues();
  setInitialResourceAttributeTypesPerValues();
});

defineExpose({
  form: resourceAttributesTypesSelectedIds,
  checkForErrors,
});
</script>

<template>
  <div>
    <div class="mm-page-form-label">Add resource attributes</div>
    <div class="mm-flex mm-flex-column">
      <div
        v-for="(resourceAttributesType, index) in resourceAttributesTypesValues"
        :key="`${resourceAttributesType?.id}-${index}`"
        class="mm-flex"
      >
        <m-m-multiselect
          ref="multiselectRefs"
          v-model="resourceAttributesTypesValues[index]"
          :options="resourceAttributesTypesForSelect"
          :errors="generatedErrors[index]"
          :total="resourceAttributesTypesTotal"
          item-value="id"
          item-title="name"
          placeholder="Select Attribute"
          class="mm-mb-12 select-resource-attribute"
          @search-change="onSearchChange"
          @update-params="getResourceAttributes"
          @update:model-value="onUpdateResourceAttributesTypeValue(index)"
        >
          <template
            #option="{ option: { name, format_option, $isDisabled, wizard } }"
          >
            <div class="mm-flex mm-flex-grow">
              <span class="mm-mr-4">{{ name }}</span>
              <span class="mm-page-subtitle--h1 resource-attribute-type">
                ({{ SELECT_OPTIONS_MAP.get(format_option) }})
              </span>
              <span v-if="wizard?.isolated" class="mm-ml-auto">
                {{ t("multiselect.part_of") }}
                <m-m-link :to="`/sp${wizard.path}`" class="mm-fs-16">
                  {{ wizard.name }}
                </m-m-link>
              </span>
              <span v-else-if="$isDisabled" class="mm-ml-auto">
                {{ t("multiselect.already_added") }}
              </span>
            </div>
          </template>
          <template v-if="isAfterListContentVisible" #afterListContent>
            <m-m-button
              :loading="isButtonAddResourceAttributeTypeLoading"
              :is-disabled="isButtonAddResourceAttributeTypeDisabled"
              @click="onCreateResourceAttributeType(index)"
            >
              {{ createResourceAttributeTypeButtonText }}
            </m-m-button>
          </template>
        </m-m-multiselect>
        <button
          v-if="resourceAttributesTypesValues.length > 1"
          class="mm-flex mm-flex-align-center mm-flex-justify-center button-remove-attribute mm-mr-auto mm-ml-16"
          :data-cy="`button-remove-resource-attribute-${index}`"
          @click="onRemoveAttribute(index)"
        >
          <m-m-icon icon="trash2" />
        </button>
      </div>
      <m-m-button
        variant="outlined"
        prepend-icon="plus"
        size="small"
        class="mm-mr-auto"
        cy="add-resource-attribute-type-button"
        @click="onAddAttribute"
      >
        Add Attribute
      </m-m-button>
    </div>
  </div>
</template>

<style scoped lang="scss">
.card-title {
  color: #384250;
}

.select-resource-attribute {
  min-width: 478px;
}

.resource-attribute-type {
  color: #6d7480;
}

.button-remove-attribute {
  width: 40px;
  height: 40px;
  background-color: #f4f5f7;
  border-radius: 8px;
}
</style>
