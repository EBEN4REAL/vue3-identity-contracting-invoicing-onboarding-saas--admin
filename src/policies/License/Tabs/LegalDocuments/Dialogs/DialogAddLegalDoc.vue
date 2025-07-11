<script setup lang="ts">
import {
  Ref,
  computed,
  onMounted,
  ref,
  watch,
  ComputedRef,
  PropType,
} from "vue";
import { authService } from "~/auth/auth.service";
import { useFlag } from "@unleash/proxy-client-vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  LegalDocumentTypeCreate,
  LegalDocumentTypeWithPdfSyncStatusRead,
} from "~/service-providers/LegalDocuments/legal-documents.types";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";
import { LegalDocumentTypeRead } from "~/configuration/configuration.types";
import Multiselect from "vue-multiselect";
import { useTranslation } from "i18next-vue";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  licenseName: { type: String, default: "" },
  alreadyAddedLegalDocumentsIds: {
    type: Array as PropType<string[]>,
    default: () => [],
  },
  routeLabel: {
    type: String,
    default: "",
  },
  legalDocumentTypeId: {
    type: String,
    default: "",
  },
});

const { t } = useTranslation();

const emit = defineEmits(["closeDialog", "updateList", "removeItem"]);
const isGetLegalDocumentsLoading: Ref<boolean> = ref(false);
const isButtonSubmitDisabled: Ref<boolean> = ref(true);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const documents: Ref<TableResponse<LegalDocumentTypeRead> | null> = ref(null);
const serviceProviderId: Ref<string> = ref("");
const documentItems: Ref<LegalDocumentTypeRead[]> = ref([]);
const legalDocsEnabled = useFlag("legal_documents");
const legalDocumentsSearch: Ref<string> = ref("");
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);
const isButtonAddLegalDocumentDisabled: Ref<boolean> = ref(false);
const isButtonAddLegalDocumentLoading: Ref<boolean> = ref(false);

const legalDocumentsForMultiselect = computed(() =>
  documents.value?.results.map((document) => {
    const isLegalDocumentDisabled = Boolean(
      props.alreadyAddedLegalDocumentsIds.find(
        (alreadyAddedId) => alreadyAddedId === document.id,
      ),
    );
    return {
      value: document.id,
      title: document.external_facing_name,
      wizard: document?.wizard,
      $isDisabled:
        isLegalDocumentDisabled || Boolean(document.wizard?.isolated),
    };
  }),
);

const resetForm = () => {
  documentItems.value = [];
};

const onDialogClose = () => {
  emit("closeDialog");
  resetForm();
};

const getLegalDocuments = async (params: TableRequestParams) => {
  try {
    isGetLegalDocumentsLoading.value = true;
    documents.value = await legalDocumentTypesService.getLegalDocumentTypes(
      serviceProviderId.value,
      params,
    );
    updateAllDisable();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isGetLegalDocumentsLoading.value = false;
  }
};

const onCreateLegalDocument = async () => {
  const postLegalDocumentTypeResponse =
    await legalDocumentTypesService.postLegalDocumentType(
      serviceProviderId.value,
    );

  try {
    isButtonAddLegalDocumentDisabled.value = true;
    isButtonAddLegalDocumentLoading.value = true;

    const patchLegalDocumentTypeResponse =
      await legalDocumentTypesService.patchLegalDocumentType(
        serviceProviderId.value,
        postLegalDocumentTypeResponse.id,
        {
          legal_document_type_create: {
            external_facing_name: legalDocumentsSearch.value,
            text_source: "pdf",
            signature_required_from_SC: true,
            signature_required_from_SP: false,
            signature_required_from_end_user: false,
          },
        } as LegalDocumentTypeCreate,
      );

    documentItems.value.push({
      title: patchLegalDocumentTypeResponse.external_facing_name,
      value: patchLegalDocumentTypeResponse.id,
    });
    multiselectRef.value?.closeMultiselect();

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isButtonAddLegalDocumentDisabled.value = false;
    isButtonAddLegalDocumentLoading.value = false;
  }
};

const onSubmit = async () => {
  try {
    isButtonSubmitDisabled.value = true;
    isButtonSubmitLoading.value = true;
    const docsToBeAdded = await Promise.all(
      documentItems.value.map((document) =>
        legalDocumentTypesService.getLegalDocumentType(
          serviceProviderId.value,
          document.value,
        ),
      ),
    );

    const legalDocumentTypes: LegalDocumentTypeWithPdfSyncStatusRead[] =
      docsToBeAdded.map((doc) => ({
        id: doc.id,
        description: doc.description,
        name: doc.external_facing_name,
      }));

    emit("updateList", legalDocumentTypes);
    emit("closeDialog");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error adding legal document",
      status: "error",
    });
  } finally {
    isButtonSubmitDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

const updateAllDisable = () => {
  documents.value?.results.forEach((doc) => (doc.disabled = false));
  documents.value?.results
    .filter((doc) =>
      props.alreadyAddedLegalDocumentsIds.some(
        (document) => document === doc.id,
      ),
    )
    .forEach((doc) => (doc.disabled = true));
};

const agreementType = computed(() => {
  return (
    props.licenseName ||
    (props.routeLabel.toLowerCase() === "plans" ? "plan" : "license")
  );
});

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(legalDocumentsSearch.value) &&
    !isGetLegalDocumentsLoading.value &&
    !documents.value?.results.find(
      (document) =>
        document.external_facing_name === legalDocumentsSearch.value,
    ),
);

const createLegalDocumentButtonText: ComputedRef<string> = computed(
  () => `Create legal document "${legalDocumentsSearch.value}"`,
);

const onSearchChange = (value: string) => {
  legalDocumentsSearch.value = value;
};

watch(
  () => props.alreadyAddedLegalDocumentsIds.length,
  () => {
    updateAllDisable();
  },
);

watch(
  () => props.isOpen,
  () => {
    if (props.isOpen) documentItems.value = [];
  },
);

watch(
  () => documentItems.value.length,
  (documentItemsAddedLength) => {
    isButtonSubmitDisabled.value = !Boolean(documentItemsAddedLength);
  },
);

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org && legalDocsEnabled.value) {
    serviceProviderId.value = userProfile.sp_org;
  }
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Add legal document to ${agreementType}`"
    icon="book-open"
    icon-size="24px"
    cy="add-legal-document-dialog"
    @close="onDialogClose"
  >
    <template #default>
      <m-m-multiselect
        ref="multiselectRef"
        v-model="documentItems"
        :options="legalDocumentsForMultiselect"
        :total="documents?.total"
        label="Search & add legal document:"
        :loading="isGetLegalDocumentsLoading"
        multiple
        searchable
        @search-change="onSearchChange"
        @update-params="getLegalDocuments"
      >
        <template v-if="isAfterListContentVisible" #afterListContent>
          <m-m-button
            :loading="isButtonAddLegalDocumentLoading"
            :is-disabled="isButtonAddLegalDocumentDisabled"
            @click="onCreateLegalDocument"
          >
            {{ createLegalDocumentButtonText }}
          </m-m-button>
        </template>
        <template #disabled-text="{ option }">
          <span v-if="option.wizard?.isolated">
            {{ t("multiselect.part_of") }}
            <m-m-link :to="`/sp${option.wizard.path}`" class="mm-fs-16">
              {{ option.wizard.name }}
            </m-m-link>
          </span>
          <span v-else-if="option.$isDisabled">
            {{ t("multiselect.already_added") }}
          </span>
        </template>
      </m-m-multiselect>
    </template>
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-add-document"
        @click="onDialogClose"
      >
        Cancel
      </m-m-button>
      <m-m-button
        variant="elevated"
        :is-disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        data-cy="button-confirm-add-document"
        prepend-icon="plus-white"
        @click="onSubmit"
      >
        Add legal document
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
<style scoped lang="scss"></style>
