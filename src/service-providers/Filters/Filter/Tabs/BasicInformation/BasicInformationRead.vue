<script setup lang="ts">
import { computed, PropType } from "vue";
import { TypeFilterBasicInformationData } from "~/service-providers/Filters/Filter/Tabs/types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeFilterBasicInformationData>,
    default: null,
  },
});

const tabBasicInformationDataIteratorData = computed(() => [
  {
    label: "Filter name",
    text: props.data.name,
  },
  {
    label: "Description",
    text: props.data.description,
    isEmpty: !props.data.description,
    emptyText: "No description",
  },
]);
</script>

<template>
  <m-m-data-iterator
    :data="tabBasicInformationDataIteratorData"
    :columns="2"
    class="basic-information-iterator"
  />
</template>
<style lang="scss" scoped>
.basic-information-iterator {
  width: 100%;
  padding: 5px 24px 24px;
}
.mm-card.mm-data-iterator {
  border: none;
}
</style>
