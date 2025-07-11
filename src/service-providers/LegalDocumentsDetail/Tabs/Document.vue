<script setup lang="ts">
import { PropType } from "vue";
import {
  LegalDocumentForm,
  LegalDocumentTypePdfPreSignUrl,
} from "~/service-providers/LegalDocuments/legal-documents.types";

defineProps({
  form: {
    type: Object as PropType<LegalDocumentForm>,
    required: true,
  },
  isEditMode: {
    type: Boolean,
    default: false,
  },
  validation: {
    type: Object,
    default: () => ({}),
  },
  pdfUrl: {
    type: Object as PropType<LegalDocumentTypePdfPreSignUrl | null>,
    default: () => {},
  },
  hasDocChanged: {
    type: Boolean,
    default: false,
  },
});
const emit = defineEmits(["uploadedFile", "update:form", "documentRemoved"]);
</script>
<template>
  <m-m-document-upload
    :file="form.file"
    :is-edit-mode="isEditMode"
    :errors="validation.file?.$errors"
    :pdf-url="pdfUrl"
    :has-file-changed="hasDocChanged"
    @document-uploaded="emit('uploadedFile', { ...form, file: $event })"
    @document-removed="emit('documentRemoved')"
  />

  <m-m-divider />
  <div class="document-tab mm-mt-12 mm-mb-8">
    <div class="mm-page-title mm-page-title--h4 mm-page-title--required">
      Signing options
    </div>
    <div
      data-cy="checkbox-signing"
      class="mm-flex mm-flex-align-center mm-flex-gap-4 checkbox"
    >
      <m-m-checkbox
        :model-value="form.signing"
        class="mm-my-6"
        value="1"
        checked
        disabled
        name="checkbox"
        @update:model-value="emit('update:form', { ...form, signing: $event })"
        >Checkbox signing</m-m-checkbox
      >
      <m-m-icon icon="question-mark-circle" class="mm-mt-4 document-tab-icon" />
      <m-m-tooltip display-position="toRight" data-cy="tooltip-signing">
        This means when the customer clicks on the checkbox to agree to the
        legal document they are signing it. More options coming soon!
      </m-m-tooltip>
    </div>
    <div class="mm-page-title mm-page-title--h4 mm-page-title--required">
      Signed by
    </div>
    <div
      data-cy="checkbox-signedBy"
      class="mm-flex mm-flex-align-center mm-flex-gap-4 checkbox"
    >
      <m-m-checkbox
        :model-value="form.signedBy"
        class="mm-my-6"
        value="2"
        checked
        disabled
        name="checkbox"
        @update:model-value="emit('update:form', { ...form, signedBy: $event })"
        >Customer organization admin only</m-m-checkbox
      >
      <m-m-icon icon="question-mark-circle" class="mm-mt-4 document-tab-icon" />
      <m-m-tooltip display-position="toRight" data-cy="tooltip-signed-by">
        Only the admin user/s of the customer organization will sign the legal
        document, on behalf of the organization and it’s users. More options
        coming soon!
      </m-m-tooltip>
    </div>
  </div>
</template>

<style scoped lang="scss">
.document-tab {
  width: calc(100% - 24px);
  margin-left: 24px;
  .checkbox {
    width: fit-content;
  }

  &-icon {
    cursor: pointer;
  }
}
</style>
