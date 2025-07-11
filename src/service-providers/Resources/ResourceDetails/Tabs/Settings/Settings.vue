<script setup lang="ts">
import { PropType, ref, toRef } from "vue";
import BasicInformationEdit from "../BasicInformation/BasicInformationEdit.vue";
import BasicInformationRead from "../BasicInformation/BasicInformationRead.vue";
import ResourceAttributesEdit from "../ResourceAttributes/ResourceAttributesEdit.vue";
import ResourceAttributesRead from "../ResourceAttributes/ResourceAttributesRead.vue";
import { TypeResourceBasicInformationForm } from "../types";

const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  isInEditMode: {
    type: Boolean,
    required: true,
    default: false,
  },
  basicInformationData: {
    type: Object as PropType<TypeResourceBasicInformationForm>,
    default: () => ({}),
  },
  resourceAttributesData: {
    type: Array as PropType<string[]>,
    default: () => [],
  },
  isBasicInfoOpen: {
    type: Boolean,
    default: true,
  },
  isResourceAttributesOpen: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits([
  "update:basicInfoOpen",
  "update:resourceAttributesOpen",
]);

const basicInformationEditRef = ref(null);
const resourceAttributesEditRef = ref(null);

const isBasicInfoOpen = toRef(props, "isBasicInfoOpen");
const isResourceAttributesOpen = toRef(props, "isResourceAttributesOpen");

defineExpose({
  basicInformationEditRef,
  resourceAttributesEditRef,
});
</script>
<template>
  <div>
    <m-m-expandable-card
      title="Basic information"
      :is-opened="isBasicInfoOpen"
      :required="isInEditMode"
      @update:is-opened="emit('update:basicInfoOpen', $event)"
    >
      <BasicInformationEdit
        v-if="isInEditMode"
        ref="basicInformationEditRef"
        class="form-container"
        :data="basicInformationData"
      />
      <BasicInformationRead v-else :data="basicInformationData" />
    </m-m-expandable-card>
    <m-m-expandable-card
      title="Resource attributes"
      :is-opened="isResourceAttributesOpen"
      :required="isInEditMode"
      class="mm-mt-10"
      @update:is-opened="emit('update:resourceAttributesOpen', $event)"
    >
      <ResourceAttributesEdit
        v-if="isInEditMode"
        ref="resourceAttributesEditRef"
        class="form-container"
        :data="resourceAttributesData"
        :service-provider-id="serviceProviderId"
      />
      <ResourceAttributesRead
        v-else
        :data="resourceAttributesData"
        :service-provider-id="serviceProviderId"
      />
    </m-m-expandable-card>
  </div>
</template>
<style scoped lang="scss">
:deep(.mm-table) {
  padding: 0 24px 24px;
}
:deep(.mm-card) {
  overflow: visible;
}
:deep(.mm-expandable-card--active.table-elem) {
  background-color: #f2f4f7;
}
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
</style>
