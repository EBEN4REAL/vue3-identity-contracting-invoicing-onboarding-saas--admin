<script setup lang="ts">
import { computed, PropType } from "vue";
import { TypeAttributeSetBasicInformationForm } from "~/service-providers/AttributeSets/AttributeSet/Tabs/types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeAttributeSetBasicInformationForm>,
    default: null,
  },
});

const tabBasicInformationDataIteratorData = computed(() => [
  {
    label: "Name",
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
    class="mm-my-9 data-iterator"
  />
</template>
<style scoped lang="scss">
.data-iterator {
  width: 97%;
  margin-right: 20px;
}
.mm-card.mm-data-iterator {
  border: none;
}
.mm-data-iterator {
  padding: 0 0 0 10px;
}
</style>
