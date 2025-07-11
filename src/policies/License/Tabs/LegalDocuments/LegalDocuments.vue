<script setup lang="ts">
import { Ref, computed, ref, ComputedRef } from "vue";
import DialogAddLegalDoc from "./Dialogs/DialogAddLegalDoc.vue";
import DialogRemoveLegalDoc from "./Dialogs/DialogRemoveLegalDoc.vue";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { useRoute } from "vue-router";
import { useFlag } from "@unleash/proxy-client-vue";
import { LegalDocumentTypeWithPdfSyncStatusRead } from "~/service-providers/LegalDocuments/legal-documents.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { isEqual } from "lodash";

const props = defineProps({
  licenseName: { type: String, default: "" },
  isEditMode: { type: Boolean, default: false },
  isCreateMode: {
    type: Boolean,
    default: false,
  },
  isSubmitLoading: { type: Boolean, default: false },
  licenseHasActiveInstances: { type: Boolean, default: false },
  routeLabel: {
    type: String,
    default: "",
  },
});
const emit = defineEmits(["updateList", "removeDocument"]);
const route = useRoute();
const isAddDocumentDialogOpen: Ref<boolean> = ref(false);
const isLegalDocumentsLoading: Ref<boolean> = ref(false);
const isRemoveDocumentDialogOpen: Ref<boolean> = ref(false);
const documentsList: Ref<
  TableResponse<LegalDocumentTypeWithPdfSyncStatusRead>
> = ref({
  limit: ITEMS_PER_PAGE,
  offset: 0,
  total: 0,
  results: [] as LegalDocumentTypeWithPdfSyncStatusRead[],
  size: 0,
});
const documentsRemovedList: Ref<string[]> = ref([]);
const initialDocumentsList: Ref<LegalDocumentTypeWithPdfSyncStatusRead[]> = ref(
  [],
);

const removeDocumentDialogData: Ref<string> = ref("");
const legalDocsEnabled = useFlag("legal_documents");

const emptyState: string = "No legal documents";

const headers: TableHeader[] = [
  {
    key: "name",
    label: "Document name",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    key: "actions",
    label: "",
  },
];

const isCurrentCategoryPlan: ComputedRef<boolean> = computed(() =>
  route.path.includes("/plans/"),
);

const handleUrl = (row: LegalDocumentTypeWithPdfSyncStatusRead) => {
  return `/sp/${route.params.service_provider_id}/legal-documents/${row.id}?from=${
    isCurrentCategoryPlan.value ? "plans" : "access-licenses"
  }`;
};

const getDropdownItems = (row: LegalDocumentTypeWithPdfSyncStatusRead) => {
  return props.isEditMode || props.isCreateMode
    ? [
        {
          label: `Go to ${row.name}`,
          type: "link",
          to: handleUrl(row),
        },
        {
          label: getRemoveLabel(props.licenseName, props.routeLabel),
          isDisabled: props.licenseHasActiveInstances,
          hint: props.licenseHasActiveInstances
            ? licenseActiveAgreementsMessage.value
            : null,
          type: "button",
          color: "error",
          onClick: () => handleRemoveLegalDoc(row),
        },
      ]
    : [
        {
          label: `Go to ${row.name}`,
          type: "link",
          to: handleUrl(row),
        },
      ];
};

const hasChanges: ComputedRef<boolean> = computed(
  () =>
    !isEqual(
      documentsList.value.results.map(({ id }) => id),
      initialDocumentsList.value.map(({ id }) => id),
    ),
);

const alreadyAddedLegalDocumentsIds: ComputedRef<string[]> = computed(() =>
  documentsList.value ? documentsList.value.results.map((doc) => doc.id) : [],
);

const handleUpdate = (data: LegalDocumentTypeWithPdfSyncStatusRead[]) => {
  data.forEach((item) => {
    documentsList?.value?.results?.push(item);
    documentsRemovedList.value = documentsRemovedList.value.filter(
      (id) => id != item.id,
    );
  });

  emit(
    "updateList",
    documentsList.value && documentsList?.value?.results.map((item) => item.id),
  );
  emit("removeDocument", documentsRemovedList.value);
};

const onRemoveDocument = (id: string) => {
  if (documentsList.value) {
    documentsList.value.results = documentsList?.value?.results.filter(
      (obj) => obj.id != id,
    );
    documentsRemovedList.value.push(id);
    emit("removeDocument", documentsRemovedList.value);
    emit(
      "updateList",
      documentsList.value &&
        documentsList?.value?.results.map((item) => item.id),
    );
  }
};

const handleRemoveLegalDoc = (row: LegalDocumentTypeWithPdfSyncStatusRead) => {
  isRemoveDocumentDialogOpen.value = true;
  removeDocumentDialogData.value = row.id;
};

const getLegalDocuments = async (params?: TableRequestParams) => {
  try {
    isLegalDocumentsLoading.value = true;
    documentsList.value =
      await agreementTypesService.getAgreementTypeLegalDocumentTypes(
        route.params.service_provider_id.toString(),
        route.params?.license_id.toString(),
        params ? params : { limit: ITEMS_PER_PAGE[0], offset: "0" },
      );
    initialDocumentsList.value = documentsList.value
      ? [...documentsList.value?.results]
      : [];
  } catch (error) {
    isLegalDocumentsLoading.value = false;
  } finally {
    isLegalDocumentsLoading.value = false;
  }
};

const handleUpdateParams = async (params: TableRequestParams) => {
  if (legalDocsEnabled.value && route.params?.license_id) {
    await getLegalDocuments(params);
  }
};

const licenseActiveAgreementsMessage = computed(() => {
  return "Cannot edit legal documents as there are active instances of the plan";
});

const getRemoveLabel = (licenseName: string, routeLabel: string): string => {
  const defaultType = routeLabel.toLowerCase() === "plans" ? "plan" : "license";
  return `Remove from ${licenseName || defaultType}`;
};

defineExpose({
  hasChanges,
});
</script>

<template>
  <div class="form-container">
    <div class="mm-flex mm-flex-align-center mm-flex-justify-between mm-mb-8">
      <div
        class="mm-page-subtitle mm-page-subtitle--h1 mm-mb-8"
        data-cy="legal-documents-header"
      >
        These contain all the terms and conditions users have to agree to when
        signing up for this {{ routeLabel === "plans" ? "plan" : "license" }}.
      </div>
      <m-m-button
        v-if="isEditMode || isCreateMode"
        variant="outlined"
        prepend-icon="plus"
        size="small"
        cy="button-add-legal-document"
        :is-disabled="isSubmitLoading || licenseHasActiveInstances"
        @click="isAddDocumentDialogOpen = true"
      >
        Add legal document
        <m-m-tooltip
          v-if="licenseHasActiveInstances"
          max-width="300px"
          display-position="toLeft"
        >
          {{ licenseActiveAgreementsMessage }}
        </m-m-tooltip>
      </m-m-button>
    </div>
    <m-m-table
      :empty-state="emptyState"
      :headers="headers"
      :rows="documentsList?.results"
      :is-loading="isLegalDocumentsLoading"
      :total-rows="documentsList?.total"
      cy="legal-documents"
      show-search
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          v-if="isEditMode || isCreateMode"
          variant="elevated"
          prepend-icon="plus-white"
          size="small"
          cy="empty-state-button-add-legal-document"
          :is-disabled="isSubmitLoading || licenseHasActiveInstances"
          @click="isAddDocumentDialogOpen = true"
        >
          Add legal document
        </m-m-button>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="getDropdownItems(row)"
            :cy="`actions-dropdown-${row.id}`"
            max-width="218px"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="text"
                :cy="`actions-${row.id}`"
              />
            </template>
          </m-m-dropdown>
        </div> </template
    ></m-m-table>
  </div>
  <DialogAddLegalDoc
    v-if="legalDocsEnabled"
    :is-open="isAddDocumentDialogOpen"
    :license-name="licenseName"
    :already-added-legal-documents-ids="alreadyAddedLegalDocumentsIds"
    :route-label="routeLabel"
    @close-dialog="isAddDocumentDialogOpen = false"
    @update-list="handleUpdate"
    @remove-item="onRemoveDocument"
  />
  <DialogRemoveLegalDoc
    :is-open="isRemoveDocumentDialogOpen"
    :license-name="licenseName"
    :document-id="removeDocumentDialogData"
    @close-dialog="isRemoveDocumentDialogOpen = false"
    @remove-document="onRemoveDocument"
  />
</template>

<style scoped lang="scss">
.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
</style>
