<script setup lang="ts">
import { PropType } from "vue";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { SPLegalDocumentRead } from "~/service-providers/LegalDocuments/legal-documents.types";

const props = defineProps({
  documents: {
    type: Object as PropType<TableResponse<SPLegalDocumentRead> | null>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
});
const documentName = (row: SPLegalDocumentRead) => row.name || "-";
const emit = defineEmits(["updateParams"]);

const handleUpdateParams = (params: TableRequestParams) => {
  emit("updateParams", params);
};
const headers: TableHeader[] = [
  {
    key: "name",
    label: "Document name",
  },
  {
    key: "date_created",
    label: "Date created",
  },
  {
    key: "actions",
    label: "Legal documents",
  },
];

const fetchPDFUrl = async (legal_document_type_id: string) => {
  try {
    if (!props.documents) return;
    const result = await legalDocumentTypesService.getLegalDocumentTypePdfUrl(
      props.serviceProviderId,
      legal_document_type_id,
    );
    if (result.pdf_url) {
      window.open(result.pdf_url, "_blank");
    } else {
      eventBus.$emit("onShowToast", {
        text: "PDF URL not found",
        status: "error",
      });
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "There was an error while fetching pdf url",
      status: "error",
    });
  }
};
</script>
<template>
  <m-m-expandable-card title="Legal documents" cy="legal-docs-expandable">
    <m-m-table
      show-search
      background-color="#F2F4F7"
      :is-loading="isLoading"
      :headers="headers"
      :rows="documents?.results"
      empty-state="No legal documents"
      :total-rows="documents?.total"
      cy="legal-documents-table"
      @update-params="handleUpdateParams"
    >
      <template #name="{ row }">
        <div class="name-column" :data-cy="`column-name-${row.id}`">
          {{ documentName(row) }}
        </div>
      </template>
      <template #date_created="{ row }">
        <m-m-formatted-date :raw-date="row.date_created as string" />
      </template>
      <template #actions="{ row }">
        <m-m-button
          variant="text"
          :data-cy="`column-name-${row.id}`"
          class="view-document-column"
          @click="() => fetchPDFUrl(row.legal_document_type as string)"
        >
          View document
        </m-m-button>
      </template>
    </m-m-table>
  </m-m-expandable-card>
</template>
<style scoped lang="scss">
.view-document-column {
  text-decoration: underline;
}
:deep(.mm-button) {
  font-size: 14px;
  &:hover {
    background-color: transparent;
    border-color: transparent;
  }
  &:active {
    outline: transparent;
  }
}
</style>
