<script setup lang="ts">
import { computed, PropType } from "vue";
import { TypeLicenseBasicInfo } from "../../types";

const props = defineProps({
  data: {
    type: Object as PropType<TypeLicenseBasicInfo>,
    default: null,
  },
});

const tabBasicInformationDataIteratorData = computed(() => [
  {
    label: "Name",
    text: props.data.external_facing_name,
    labelTooltip: "This will be visible to your customers",
  },
  {
    label: "Reference",
    text: props.data.name,
    labelTooltip: "Reference for internal use only",
  },
  {
    label: "Description",
    text: props.data.external_facing_description,
    isEmpty: !props.data.external_facing_description,
    emptyText: "No external description",
    labelTooltip: "This will be visible to your customers",
  },
  {
    label: "Remarks",
    text: props.data.description,
    isEmpty: !props.data.description,
    emptyText: "No remarks",
    labelTooltip: "Remarks and notes for internal use only",
  },
]);
</script>

<template>
  <m-m-data-iterator :data="tabBasicInformationDataIteratorData" :columns="2" />
</template>
