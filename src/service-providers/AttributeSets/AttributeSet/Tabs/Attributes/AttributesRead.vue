<script setup lang="ts">
import { onMounted, PropType, ref, Ref } from "vue";
import { TypeAttributesRead } from "~/service-providers/AttributeSets/AttributeSet/Tabs/types";
import { attributeTypesService } from "~/service-providers/attributeTypesService";
import { useRoute } from "vue-router";
import { AttributeTypeRead } from "~/onboarding/onboarding.types";

const route = useRoute();

const props = defineProps({
  data: {
    type: Object as PropType<TypeAttributesRead>,
    default: null,
  },
});

const attributeTypesRequired: Ref<AttributeTypeRead[]> = ref([]);
const attributeTypesOptional: Ref<AttributeTypeRead[]> = ref([]);

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

onMounted(async () => {
  await getAttributeTypes();
});
</script>

<template>
  <div class="description mm-mt-8 mm-ml-1">
    The attributes that are either required (user cannot continue logging in
    without providing them) or optional (user can login without providing them)
    during a login on your application.
  </div>
  <div class="mm-flex mm-flex-gap-12 attributes-wrapper mm-mr-1">
    <m-m-card class="column mm-pa-8 mm-h-fit-content mm-my-10">
      <div class="mm-fs-18 mm-fw-500 mm-pb-4">Required attributes</div>
      <div
        v-if="attributeTypesRequired.length"
        class="mm-flex mm-flex-column mm-flex-gap-8 mm-max-h-4-vh mm-overflow-auto"
      >
        <m-m-card
          v-for="attributeTypeRequired in attributeTypesRequired"
          :key="attributeTypeRequired.id"
          border-radius="8px"
          class="mm-px-7 mm-py-6"
          :data-cy="`attribute-required-${attributeTypeRequired.id}`"
        >
          <div class="mm-fs-16 mm-fw-500">{{ attributeTypeRequired.name }}</div>
        </m-m-card>
      </div>
      <div v-else class="empty-label mm-page-subtitle--h2 mm-mt-16">
        Nothing to display
      </div>
    </m-m-card>
    <m-m-card class="column mm-pa-8 mm-h-fit-content mm-my-10">
      <div class="mm-fs-18 mm-fw-500 mm-pb-4">Optional attributes</div>
      <div
        v-if="attributeTypesOptional.length"
        class="mm-flex mm-flex-column mm-flex-gap-8 mm-max-h-4-vh mm-overflow-auto"
      >
        <m-m-card
          v-for="attributeTypeOptional in attributeTypesOptional"
          :key="attributeTypeOptional.id"
          border-radius="8px"
          class="mm-px-7 mm-py-6"
          :data-cy="`attribute-optional-${attributeTypeOptional.id}`"
        >
          <div class="mm-fs-16 mm-fw-500">{{ attributeTypeOptional.name }}</div>
        </m-m-card>
      </div>
      <div v-else class="empty-label mm-page-subtitle--h2 mm-mt-16">
        Nothing to display
      </div>
    </m-m-card>
  </div>
</template>

<style scoped lang="scss">
.column {
  width: calc((100% / 3) - 20px);
  min-width: 340px;
}

.empty-label {
  color: #9ea5af;
}
.description {
  margin-right: 5px;
  margin-left: 22px;
  align-self: flex-start;
  text-align: left;
  font-size: 14px;
  line-height: 20px;
}
.attributes-wrapper {
  width: 97%;
}
</style>
