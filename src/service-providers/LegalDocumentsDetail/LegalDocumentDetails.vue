<script setup lang="ts">
import { ComputedRef, Ref, computed, onMounted, onUnmounted, ref } from "vue";
import { useRoute } from "vue-router";
import {
  BasicInfoData,
  LegalDocumentTypePdfPreSignUrl,
  LegalDocumentTypeRead,
} from "../LegalDocuments/legal-documents.types";
import LegalDocumentsEdit from "./LegalDocumentsEdit.vue";
import LegalDocumentViewer from "./LegalDocumentViewer.vue";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const route = useRoute();
const editMode = route.query.editMode;
const isInEditMode = ref(false);
const serviceProviderId: Ref<string> = ref("");
const document: Ref<LegalDocumentTypeRead | null> = ref(null);
const pdfUrl: Ref<LegalDocumentTypePdfPreSignUrl | null> = ref(null);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const scrimmedClass: ComputedRef<string> = computed(() =>
  document.value?.wizard?.hidden ? "mm-opacity-40" : "",
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const documentData: ComputedRef<File | null> = computed(() => {
  if (!document.value?.pdf_filename && !document.value?.pdf_size) return null;
  const file = new File([""], document.value?.pdf_filename as string, {
    type: "pdf",
  });
  Object.defineProperty(file, "size", { value: document.value?.pdf_size });
  return file;
});

const basicInformationData: Ref<BasicInfoData> = computed(() => ({
  externalFacingName: document.value?.external_facing_name || "",
  docName: document.value?.name || "",
  description: document.value?.description || null,
  version: document.value?.version_reference,
  signing: true,
  signedBy: true,
  file: documentData.value,
}));

const handleEditMode = () => {
  isInEditMode.value = true;
};

const handleSave = (form: BasicInfoData) => {
  isInEditMode.value = false;
  basicInformationData.value.externalFacingName = form.externalFacingName;
  basicInformationData.value.docName = form.docName;
  basicInformationData.value.description = form.description;
  basicInformationData.value.version = form.version;
  basicInformationData.value.file = form.file;
};

onMounted(async () => {
  serviceProviderId.value = route.params.service_provider_id as string;
  if (serviceProviderId.value) {
    document.value = await legalDocumentTypesService.getLegalDocumentType(
      serviceProviderId.value,
      route.params.legalDocumentTypeId.toString(),
    );
    uiStore.isScrimmed = document.value?.wizard?.hidden;
    if (document.value?.pdf_filename && document.value.pdf_size) {
      pdfUrl.value = await legalDocumentTypesService.getLegalDocumentTypePdfUrl(
        serviceProviderId.value,
        route.params.legalDocumentTypeId.toString(),
      );
    }
  }
  isInEditMode.value = false;
  if (editMode) {
    handleEditMode();
  }
});

onUnmounted(() => {
  uiStore.isScrimmed = false;
});
</script>

<template>
  <m-m-teleport to="mm-config-banner-section">
    <wizard-banner
      v-if="document?.wizard"
      :wizard="document?.wizard"
      :item-id="document.id"
      class="mm-mb-8"
    />
  </m-m-teleport>
  <LegalDocumentViewer
    v-if="!isInEditMode"
    :document="document"
    :service-provider-id="serviceProviderId"
    :data="basicInformationData"
    :pdf-url="pdfUrl"
    :scrimmed-class="scrimmedClass"
    @is-in-edit-mode="handleEditMode"
  />
  <LegalDocumentsEdit
    v-else
    :data="basicInformationData"
    :document="document"
    :pdf-url="pdfUrl"
    :is-config-publishing="isConfigPublishing"
    @on-save="handleSave"
    @on-view-mode="isInEditMode = false"
  />
</template>
