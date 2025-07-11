<script lang="ts" setup>
import {
  computed,
  ComputedRef,
  onMounted,
  PropType,
  Ref,
  ref,
  watch,
} from "vue";
import { TypeAttributesRead } from "~/service-providers/AttributeSets/AttributeSet/Tabs/types";
import draggable from "vuedraggable";
import { AttributeTypeRead } from "~/onboarding/onboarding.types";
import { attributeTypesService } from "~/service-providers/attributeTypesService";
import { useRoute } from "vue-router";
import { TableResponse } from "~/mm_ui_kit/src/types/table.types";
import { debounce } from "lodash";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { attributeSetsService } from "~/configuration/attribute-sets.service";
import { ITEMS_PER_PAGE } from "~/common/constants";

const props = defineProps({
  data: {
    type: Object as PropType<TypeAttributesRead>,
    default: null,
  },
});

const emit = defineEmits(["change"]);

const route = useRoute();

const attributeTypesPerServiceProvider: Ref<TableResponse<AttributeTypeRead> | null> =
  ref(null);
const tempAttributeTypesRequired: Ref<AttributeTypeRead[]> = ref([]);
const tempAttributeTypesOptional: Ref<AttributeTypeRead[]> = ref([]);
const attributeTypesRequired: Ref<AttributeTypeRead[]> = ref([]);
const attributeTypesOptional: Ref<AttributeTypeRead[]> = ref([]);
const attributeTypeSearch: Ref<string> = ref("");
const dragOptions = {
  animation: 200,
  group: "attribute-types",
};

const required_attribute_types: ComputedRef<string[]> = computed(() =>
  tempAttributeTypesRequired.value.map((attributeType) => attributeType.id),
);

const optional_attribute_types: ComputedRef<string[]> = computed(() =>
  tempAttributeTypesOptional.value.map((attributeType) => attributeType.id),
);

const allAttributes: ComputedRef<AttributeTypeRead[]> = computed(() => {
  if (!attributeTypesPerServiceProvider.value) return [];

  const alreadyAddedAttributes = [
    ...tempAttributeTypesRequired.value,
    ...tempAttributeTypesOptional.value,
  ];

  return attributeTypesPerServiceProvider.value.results.filter(
    (attributeType) =>
      !alreadyAddedAttributes.find(
        (addedAttribute) => addedAttribute.id === attributeType.id,
      ) && attributeType.enabled,
  );
});

const getAttributeType = (id: string) =>
  attributeTypesService.getAttributeType(
    route.params.service_provider_id as string,
    id,
  );

const getAttributeTypes = async () => {
  attributeTypesRequired.value = props.data?.required_attribute_types
    ? await Promise.all(
        props.data?.required_attribute_types?.map((id: string) =>
          getAttributeType(id),
        ),
      )
    : [];
  attributeTypesOptional.value = props.data?.optional_attribute_types
    ? await Promise.all(
        props.data?.optional_attribute_types?.map((id: string) =>
          getAttributeType(id),
        ),
      )
    : [];
};

const getAttributeTypesPerServiceProvider = async () => {
  attributeTypesPerServiceProvider.value =
    await attributeTypesService.getAttributeTypesPerServiceProvider(
      route.params.service_provider_id as string,
      {
        limit: ITEMS_PER_PAGE[4],
        offset: "0",
        query: attributeTypeSearch.value || null,
        attribute_of: attributeSetsService.state.attributeSetAttributeOf,
        exclude_in_attribute_set_id: route.params.attribute_set_id,
      },
    );
};

watch(
  attributeTypeSearch,
  debounce(async () => {
    await getAttributeTypesPerServiceProvider();
  }, 500),
);

watch([tempAttributeTypesRequired, tempAttributeTypesOptional], () => {
  emit("change", {
    required_attribute_types,
    optional_attribute_types,
  });
});

onMounted(async () => {
  await getAttributeTypes();
  tempAttributeTypesRequired.value = [...attributeTypesRequired.value];
  tempAttributeTypesOptional.value = [...attributeTypesOptional.value];
  await getAttributeTypesPerServiceProvider();
});

defineExpose({
  required_attribute_types,
  optional_attribute_types,
});
</script>

<template>
  <div class="mm-grid mm-grid-columns-3 mm-grid-column-gap-10 grid">
    <div
      class="panel-all-attributes column mm-flex mm-flex-column mm-pr-12 mm-overflow-x-hidden"
      data-cy="attributes-all"
    >
      <m-m-input
        v-model="attributeTypeSearch"
        placeholder="Search"
        icon-prepended="search-lg"
        clear-button="x-circle"
        class="mm-pb-6"
      />
      <m-m-badge
        :status="BadgeTypes.Inactive"
        :text="attributeSetsService.getAttributeSetAttributeOfLabel"
        class="mm-mr-auto mm-mb-16"
      />
      <draggable
        v-if="attributeTypesPerServiceProvider"
        v-model="allAttributes"
        item-key="id"
        v-bind="dragOptions"
        class="mm-flex mm-flex-column mm-flex-gap-8 mm-max-h-4-vh mm-overflow-auto"
      >
        <template #item="{ element }">
          <m-m-card
            class="mm-px-7 mm-py-6"
            :data-cy="`attribute-all-${element.id}`"
          >
            <div class="mm-flex mm-flex-align-center">
              <m-m-icon icon="drag" class="mm-mr-8" width="12px" height="7px" />
              <div class="mm-flex mm-flex-column">
                <div class="mm-fs-16 mm-fw-500">
                  {{ element.name }}
                </div>
              </div>
            </div>
          </m-m-card>
        </template>
      </draggable>
    </div>
    <div class="column mm-overflow-y-auto">
      <m-m-card
        class="mm-pa-8 dragndrop-placeholder-container"
        data-cy="attributes-required"
      >
        <div class="mm-fs-18 mm-fw-500 mm-pb-4">Required attributes</div>
        <draggable
          v-model="tempAttributeTypesRequired"
          item-key="id"
          v-bind="dragOptions"
          class="mm-flex mm-flex-column mm-flex-gap-8 mm-max-h-4-vh mm-overflow-auto"
        >
          <template #item="{ element }">
            <m-m-card
              class="mm-px-7 mm-py-6"
              :data-cy="`attribute-required-${element.id}`"
            >
              <div class="mm-flex mm-flex-align-center">
                <m-m-icon
                  icon="drag"
                  class="mm-mr-8"
                  width="12px"
                  height="7px"
                />
                <div class="mm-flex mm-flex-column">
                  <div class="mm-fs-16 mm-fw-500">
                    {{ element.name }}
                  </div>
                </div>
              </div>
            </m-m-card>
          </template>
          <template #footer>
            <div class="dragndrop-placeholder">Drag and drop fields here</div>
          </template>
        </draggable>
      </m-m-card>
    </div>
    <div class="column mm-overflow-y-auto">
      <m-m-card
        class="mm-pa-8 dragndrop-placeholder-container"
        data-cy="attributes-optional"
      >
        <div class="mm-fs-18 mm-fw-500 mm-pb-4">Optional attributes</div>
        <draggable
          v-model="tempAttributeTypesOptional"
          item-key="id"
          v-bind="dragOptions"
          class="mm-flex mm-flex-column mm-flex-gap-8 mm-max-h-4-vh mm-overflow-auto"
        >
          <template #item="{ element }">
            <m-m-card
              class="mm-px-7 mm-py-6"
              :data-cy="`attribute-optional-${element.id}`"
            >
              <div class="mm-flex mm-flex-align-center">
                <m-m-icon
                  icon="drag"
                  class="mm-mr-8"
                  width="12px"
                  height="7px"
                />
                <div class="mm-flex mm-flex-column">
                  <div class="mm-fs-16 mm-fw-500">
                    {{ element.name }}
                  </div>
                </div>
              </div>
            </m-m-card>
          </template>
          <template #footer>
            <div class="dragndrop-placeholder">Drag and drop fields here</div>
          </template>
        </draggable>
      </m-m-card>
    </div>
  </div>
</template>

<style scoped lang="scss">
.grid {
  align-self: flex-start;
  margin-left: 22px;
}
.column {
  position: relative;
  min-width: 320px;
  height: fit-content;
  padding-top: 24px;
  padding-bottom: 112px;
  transition: box-shadow 0.3s;

  &--drag-over {
    box-shadow: 0 0 10px 2px #d0d5dd;
  }

  & > .dragndrop-placeholder-container {
    position: relative;
    padding-bottom: 112px;
  }
}

.panel-all-attributes {
  border-right: 1px solid #e6e8ec;
  padding-bottom: 16px;
}

.dragndrop-placeholder {
  position: absolute;
  bottom: 16px;
  left: 16px;
  right: 16px;
  background-color: #fafbfc;
  border: 1px dashed #d3d7dc;
  border-radius: 16px;
  padding: 30px;
  font-size: 14px;
  font-weight: 400;
  line-height: 20px;
  text-align: center;
}
</style>
