<script setup lang="ts">
import { Ref, nextTick, onMounted, ref } from "vue";
import { TypeMarketingFeature } from "~/service-providers/Licenses/licenses.types";
import draggable from "vuedraggable";

const props = defineProps({
  serviceProviderId: { type: String, default: "" },
  isEditMode: { type: Boolean, default: false },
  marketingFeatures: { type: Array, default: () => [] },
});
const emit = defineEmits(["updateMarketingList"]);
const inputRef = ref<HTMLInputElement | null>(null);
const featureListValues: Ref<TypeMarketingFeature> = ref([]);

const onAddMarketingFeatureList = async () => {
  featureListValues.value.push({
    name: "",
  });
  await nextTick();
  if (inputRef.value) {
    inputRef.value.inputRef.focus();
  }
};

const onRemoveFeatureList = (index: number) => {
  featureListValues.value.splice(index, 1);
  updateFormByField();
};

const updateFormByField = () => {
  emit(
    "updateMarketingList",
    featureListValues.value
      .filter((item) => item.name !== "")
      .map((item) => item.name),
  );
};

onMounted(async () => {
  props.marketingFeatures.map((item) => {
    featureListValues.value.push({
      name: item,
    });
  });
  updateFormByField();
});
</script>
<template>
  <div>
    <div class="mm-page-subtitle mm-mb-4">
      A list of features included in this plan to display on your Veriam hosted
      pricing page
    </div>
    <m-m-button
      class="mm-my-10"
      variant="tertiary"
      :disabled="!isEditMode"
      cy="button-add-feature"
      prepend-icon="plus"
      @click="onAddMarketingFeatureList"
    >
      Add feature
    </m-m-button>
    <draggable
      v-model="featureListValues"
      item-key="id"
      :disabled="!isEditMode"
      @change="updateFormByField"
      ><template #item="{ element, index }">
        <div class="mm-flex mm-flex-gap-8 mm-flex-align-center">
          <m-m-icon
            v-if="isEditMode"
            icon="frame"
            width="12px"
            height="8px"
            class="marketing-feature--draggable"
          />
          <m-m-input
            ref="inputRef"
            v-model="element.name"
            :data-cy="`input-feature-${index}`"
            class="marketing-feature--item"
            placeholder="Add Feature"
            :disabled="!isEditMode"
            :class="{ 'mm-mb-8': !isEditMode }"
            :is-draggable="true"
            @input="updateFormByField"
            @keyup.enter="onAddMarketingFeatureList"
            @keydown.stop
          />
          <m-m-button
            v-if="isEditMode"
            class="mm-my-6"
            variant="tertiary"
            :disabled="!isEditMode"
            :cy="`button-remove-feature-${index}`"
            prepend-icon="trash-black"
            @click="onRemoveFeatureList(index)"
          /></div></template
    ></draggable>
  </div>
</template>
<style scoped lang="scss">
.marketing-feature {
  &--item {
    width: calc(50% - 16px);
  }

  &--draggable {
    cursor: grabbing;
  }
}
</style>
