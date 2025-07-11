<script setup lang="ts">
import { onMounted, PropType, ref, Ref } from "vue";
import { SELECT_OPTIONS_MAP } from "~/common/constants";
import { ResourceAttributeTypeRead } from "~/policies/policies.types";
import { resourceAttributeTypesService } from "~/configuration/resource-attribute-types.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  data: {
    type: Object as PropType<string[]>,
    default: () => ({}),
  },
  serviceProviderId: { type: String, default: "" },
});

const isResourceAttributeTypesLoading: Ref<boolean> = ref(true);
const resourceAttributesTypes: Ref<ResourceAttributeTypeRead[]> = ref([]);

const getResourceAttributeTypes = async () => {
  try {
    isResourceAttributeTypesLoading.value = true;
    resourceAttributesTypes.value = await Promise.all(
      props.data.map((id: string) =>
        resourceAttributeTypesService.getResourceAttributeType(
          props.serviceProviderId,
          id,
        ),
      ),
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching resource attribute types",
      status: "error",
    });
  } finally {
    isResourceAttributeTypesLoading.value = false;
  }
};

const resourceAttributesTypeById = (
  id: string,
): ResourceAttributeTypeRead | null =>
  resourceAttributesTypes.value.find((item) => item.id === id) || null;

onMounted(async () => {
  await getResourceAttributeTypes();
});
</script>

<template>
  <m-m-card class="mm-flex mm-flex-column mm-px-12 mm-pb-12">
    <div class="mm-page-form-label">Resource attributes added</div>
    <template v-if="isResourceAttributeTypesLoading">
      <m-m-skeleton-loader
        v-for="item in data.length"
        :key="item"
        class="mm-mb-8"
      />
    </template>
    <template v-else>
      <m-m-card
        v-for="resourceAttributesTypeId in data"
        :key="resourceAttributesTypeId"
        class="mm-mr-auto resource-attribute-item"
        :border-radius="8"
        :data-cy="`resource-attribute-item-${resourceAttributesTypeId}`"
      >
        <span class="mm-page-subtitle--h1 mm-fw-500">
          {{
            resourceAttributesTypeById(resourceAttributesTypeId)?.name
          }} </span
        >&thinsp;
        <span class="mm-page-subtitle--h1 resource-attribute-type">
          ({{
            SELECT_OPTIONS_MAP.get(
              resourceAttributesTypeById(resourceAttributesTypeId)
                ?.format_option,
            )
          }})
        </span>
      </m-m-card>
    </template>
  </m-m-card>
</template>

<style scoped lang="scss">
.card-title {
  color: #384250;
}

.resource-attribute-item {
  min-width: 280px;
}

.resource-attribute-type {
  color: #6d7480;
}
</style>
