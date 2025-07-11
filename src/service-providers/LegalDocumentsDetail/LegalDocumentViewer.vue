<script setup lang="ts">
import { ComputedRef, PropType, Ref, computed, ref } from "vue";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import {
  LegalDocumentForm,
  LegalDocumentTypePdfPreSignUrl,
} from "../LegalDocuments/legal-documents.types";
import DialogDeleteDocument from "../LegalDocuments/DialogDeleteDocument.vue";
import SettingsTab from "./Tabs/Settings.vue";
import TabRelatedItems from "./Tabs/RelatedItems.vue";
import { useRoute } from "vue-router";
import { LegalDocumentTypeRead } from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const props = defineProps({
  document: {
    type: Object as PropType<LegalDocumentTypeRead | null>,
    default: () => {},
  },
  serviceProviderId: { type: String, default: "" },
  data: {
    type: Object as PropType<LegalDocumentForm>,
    default: () => {},
  },
  pdfUrl: {
    type: Object as PropType<LegalDocumentTypePdfPreSignUrl | null>,
    default: () => {},
  },
  scrimmedClass: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["isInEditMode"]);
const route = useRoute();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const isDeleteDocumentDialogOpen: Ref<boolean> = ref(false);

const isButtonEditLegalDocumentDisabled: ComputedRef<boolean> = computed(
  () => !isLegalDocumentEditable.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    to: `/sp/config/legal-documents`,
    label: "Legal documents",
    id: props.document?.id || "",
  },
  {
    id: props.document?.id || "",
    label: props.data.externalFacingName || "",
  },
]);

const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
  {
    label: "Related items",
    name: "Related items",
    isRequired: false,
    isHidden: false,
  },
];

const currentTabName: Ref<string> = ref(TABS[0].name);

const legalDocumentCount: ComputedRef<number> = computed(
  () => props.document?.legal_documents_count ?? 0,
);

const agreementTypeIds: ComputedRef<string[]> = computed(
  () => props.document?.agreement_type_ids ?? [],
);

const isLegalDocumentEditable: ComputedRef<boolean> = computed(
  () => (props.document?.editable ?? true) && !isConfigPublishing.value,
);
</script>
<template>
  <m-m-page-header
    base-key="configuration.legal_documents.legal_document_details"
    icon="book-open"
    :breadcrumbs="breadcrumbs"
    :is-in-edit-mode="false"
    :params="{
      docName: props.data.externalFacingName,
      docDescription: props.data.description,
    }"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <m-m-button
          variant="outlined"
          prepend-icon="pen"
          cy="button-edit-document"
          :is-disabled="isButtonEditLegalDocumentDisabled"
          @click="emit('isInEditMode')"
        >
          Edit
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </div></template
    ></m-m-page-header
  >
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="currentTabName" :items="TABS" :is-in-edit-mode="true" />
  </m-m-teleport>
  <m-m-tab-items :current-tab="currentTabName" :class="scrimmedClass">
    <m-m-tab-item keep-alive :name="TABS[0].name">
      <SettingsTab :form="data" :pdf-url="pdfUrl" :is-edit-mode="false" />
    </m-m-tab-item>
    <m-m-tab-item keep-alive :name="TABS[1].name">
      <tab-related-items
        v-if="document"
        :documents-signed-count="legalDocumentCount"
        :agreements="agreementTypeIds"
      />
    </m-m-tab-item>
  </m-m-tab-items>
  <DialogDeleteDocument
    :is-open="isDeleteDocumentDialogOpen"
    :service-provider-id="serviceProviderId"
    :data="route.params.legalDocumentTypeId.toString()"
    @close-dialog="isDeleteDocumentDialogOpen = false"
  />
</template>
<style scoped lang="scss"></style>
