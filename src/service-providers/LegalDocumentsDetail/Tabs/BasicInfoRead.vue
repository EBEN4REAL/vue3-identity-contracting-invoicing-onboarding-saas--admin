<script setup lang="ts">
import { computed, PropType } from "vue";
import { LegalDocumentForm } from "~/service-providers/LegalDocuments/legal-documents.types";

const props = defineProps({
  data: {
    type: Object as PropType<LegalDocumentForm>,
    default: null,
  },
});

const tabBasicInformationDataIteratorData = computed(() => [
  {
    label: "Name",
    text: props.data.externalFacingName,
  },
  {
    label: "Reference",
    text: props.data.docName,
  },
  {
    label: "Description",
    text: props.data.description,
    isEmpty: !props.data.description,
    emptyText: "No description",
  },
  {
    label: "Version reference",
    text: props.data.version,
    isEmpty: !props.data.version,
    emptyText: "No version reference",
  },
]);
</script>

<template>
  <m-m-data-iterator :data="tabBasicInformationDataIteratorData" :columns="2" />
</template>
