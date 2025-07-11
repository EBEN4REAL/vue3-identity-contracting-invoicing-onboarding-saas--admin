<script setup lang="ts">
import { computed, ComputedRef, PropType } from "vue";
import { TypeResourceBasicInformationForm } from "~/service-providers/Resources/ResourceDetails/Tabs/types";
import { TypeDataIteratorItem } from "~/mm_ui_kit/src/types/dataIterator.types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeResourceBasicInformationForm>,
    default: null,
  },
});

const tabBasicInformationDataIteratorData: ComputedRef<TypeDataIteratorItem[]> =
  computed((): TypeDataIteratorItem[] => [
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
  <m-m-data-iterator :data="tabBasicInformationDataIteratorData" :columns="2" />
</template>
