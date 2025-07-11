<script setup lang="ts">
import { PropType, toRef } from "vue";
import BasicInformation from "./BasicInfo.vue";
import BasicInformationRead from "./BasicInfoRead.vue";
import Document from "./Document.vue";
import {
  LegalDocumentForm,
  LegalDocumentTypePdfPreSignUrl,
} from "~/service-providers/LegalDocuments/legal-documents.types";

const props = defineProps({
  form: {
    type: Object as PropType<LegalDocumentForm>,
    default: () => {},
  },
  validation: {
    type: Object,
    default: () => {},
  },
  pdfUrl: {
    type: Object as PropType<LegalDocumentTypePdfPreSignUrl | null>,
    default: () => {},
  },
  hasDocChanged: {
    type: Boolean,
    default: false,
  },
  isEditMode: {
    type: Boolean,
    default: true,
  },
  isBasicInfoExpandableOpen: {
    type: Boolean,
    default: true,
  },
  isDocExpandableOpen: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits([
  "update:form",
  "documentRemoved",
  "update:basicInfoOpen",
  "update:docOpen",
]);
const isBasicInformationOpen = toRef(props, "isBasicInfoExpandableOpen");
const isDocumentOpen = toRef(props, "isDocExpandableOpen");

const updateForm = (newForm: LegalDocumentForm) => {
  emit("update:form", newForm);
};
</script>
<template>
  <m-m-expandable-card
    title="Basic information"
    :is-opened="isBasicInformationOpen"
    :required="isEditMode"
    @update:is-opened="emit('update:basicInfoOpen', $event)"
  >
    <BasicInformation
      v-if="isEditMode"
      class="form-container"
      :form="form"
      :validation="validation"
      @update:form="updateForm($event)"
    />
    <BasicInformationRead v-else :data="form" />
  </m-m-expandable-card>
  <m-m-expandable-card
    title="Document"
    class="mm-mt-10"
    :is-opened="isDocumentOpen"
    :required="isEditMode"
    @update:is-opened="emit('update:docOpen', $event)"
  >
    <Document
      v-if="isEditMode || form.docName"
      :form="form"
      :is-edit-mode="isEditMode"
      :validation="validation"
      :pdf-url="pdfUrl"
      :has-doc-changed="hasDocChanged"
      @uploaded-file="updateForm($event)"
      @document-removed="emit('documentRemoved')"
    />
  </m-m-expandable-card>
</template>
<style scoped lang="scss">
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
:deep(.doc-upload) {
  padding: 24px;
}
.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
</style>
