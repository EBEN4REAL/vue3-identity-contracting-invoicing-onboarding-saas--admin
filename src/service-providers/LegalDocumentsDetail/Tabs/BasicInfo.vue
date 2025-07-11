<script setup lang="ts">
import { PropType } from "vue";
import { LegalDocumentForm } from "~/service-providers/LegalDocuments/legal-documents.types";

const emit = defineEmits(["update:form"]);
defineProps({
  form: {
    type: Object as PropType<LegalDocumentForm>,
    required: true,
  },
  validation: {
    type: Object,
    default: () => ({}),
  },
});
</script>
<template>
  <form v-mm-focus-first data-cy="document-create-form">
    <div class="mm-flex mm-flex-row mm-flex-gap-16">
      <div class="mm-w-5">
        <m-m-input
          :model-value="form.externalFacingName"
          label="Name"
          placeholder="Customer facing name"
          required
          :errors="validation.externalFacingName?.$errors"
          cy="document-external-name-input"
          @update:model-value="
            emit('update:form', { ...form, externalFacingName: $event })
          "
        />
        <div class="mm-flex mm-flex-align-center mm-flex-gap-2 mm-mt-2">
          <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
          <span class="mm-page-options-hint">
            This is visible to your customers
          </span>
        </div>
      </div>
      <div class="mm-w-5">
        <m-m-input
          :model-value="form.docName"
          label="Reference"
          placeholder="Reference"
          :errors="validation.docName?.$errors"
          cy="document_name_input"
          @update:model-value="
            emit('update:form', { ...form, docName: $event })
          "
        />
        <div class="mm-flex mm-flex-align-center mm-flex-gap-2 mm-mt-2">
          <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
          <span class="mm-page-options-hint">
            This is only visible internally on Veriam admin
          </span>
        </div>
      </div>
    </div>
    <div class="mm-flex mm-flex-row mm-flex-gap-16 mm-mt-16">
      <div class="mm-w-5">
        <m-m-input
          :model-value="form.description"
          label="Description"
          :errors="validation.description?.$errors"
          placeholder="Add a description"
          inputmode="textarea"
          cy="document_description_input"
          @update:model-value="
            emit('update:form', { ...form, description: $event })
          "
        />
        <div class="mm-flex mm-flex-align-center mm-flex-gap-2">
          <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
          <span class="mm-page-options-hint">
            This is only visible internally on Veriam admin
          </span>
        </div>
      </div>
      <div class="mm-w-5 basic-info-version">
        <m-m-input
          :model-value="form.version"
          label="Version reference"
          placeholder="Enter version reference"
          cy="document_version_input"
          @update:model-value="
            emit('update:form', { ...form, version: $event })
          "
        >
          <template #options-helper>
            <m-m-icon icon="info" width="16px" height="16px" />
            <div class="mm-page-options-hint">
              To help with aligning this legal document to your internal
              versioning standards
            </div>
          </template>
        </m-m-input>
      </div>
    </div>
  </form>
</template>
<style scoped lang="scss">
.basic-info {
  &-version {
    width: calc(50% - 16px);
  }
}
</style>
