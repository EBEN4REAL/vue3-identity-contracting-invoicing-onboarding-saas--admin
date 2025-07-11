<script setup lang="ts">
import {
  ComputedRef,
  PropType,
  Ref,
  computed,
  onMounted,
  reactive,
  ref,
  watch,
} from "vue";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { NavigationGuardNext, onBeforeRouteLeave, useRoute } from "vue-router";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import SettingsTab from "~/service-providers/LegalDocumentsDetail/Tabs/Settings.vue";
import TabRelatedItems from "~/service-providers/LegalDocumentsDetail/Tabs/RelatedItems.vue";
import useVuelidate from "@vuelidate/core";
import { helpers, maxLength, required } from "@vuelidate/validators";
import {
  BasicInfoData,
  LegalDocumentForm,
  LegalDocumentTypeCreate,
  LegalDocumentTypePdfPreSignUrl,
  LegalDocumentTypeUpdate,
} from "../LegalDocuments/legal-documents.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import DialogDeleteDocument from "../LegalDocuments/DialogDeleteDocument.vue";
import router from "~/router/index.router";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";
import { getErrorMessage } from "../_shared/helpers/configErrorMessageHelper";
import { LegalDocumentTypeRead } from "~/configuration/configuration.types";
import { isEqual } from "lodash";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import { useUiStore } from "~/stores/useUiStore";

const props = defineProps({
  data: {
    type: Object as PropType<BasicInfoData>,
    default: () => {},
  },
  document: {
    type: Object as PropType<LegalDocumentTypeRead | null>,
    default: () => {},
  },
  pdfUrl: {
    type: Object as PropType<LegalDocumentTypePdfPreSignUrl | null>,
    default: () => {},
  },
});

const emit = defineEmits(["onSave", "onViewMode"]);

const uiStore = useUiStore();
const route = useRoute();
const isLoading: Ref<boolean> = ref(false);
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const hasDocChanged: Ref<boolean> = ref(false);
const serviceProviderId: Ref<string> = ref("");
const legalDocumentTypeId: Ref<string> = ref("");
const createLegalDocPlaceholder = "Legal Document";
const isDeleteDocumentDialogOpen: Ref<boolean> = ref(false);
const isBasicInfoExpandableOpen: Ref<boolean> = ref(true);
const isDocExpandableOpen: Ref<boolean> = ref(true);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const {
  hasUnsavedChanges,
  updateTargetPages,
  warnUnsavedChanges,
  isDialogUnsavedChangesOpen,
  doNotShowNextTime,
  confirmLeave,
  onCancelDialogUnsavedChanges,
  updateDoNotShowNextTime,
  setTextsForUnsavedChangesDialog,
} = useUnsavedChanges();
const reasonToUnsave: Ref<"discard" | "leave"> = ref("discard");

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || isButtonSaveDisabled.value,
);

const title: ComputedRef<string> = computed(
  () => form.externalFacingName || createLegalDocPlaceholder,
);
const subtitle: ComputedRef<string> = computed(() => form.description || "");

const legalDocumentCount: ComputedRef<number> = computed(
  () => props.document?.legal_documents_count ?? 0,
);

const agreementTypeIds: ComputedRef<string[]> = computed(
  () => props.document?.agreement_type_ids ?? [],
);

const mode = ref(route.name === "SPLegalDocumentsCreate" ? "create" : "edit");

const isCreating: ComputedRef<boolean> = computed(
  () => mode.value === "create",
);

const isEditing: ComputedRef<boolean> = computed(() => mode.value === "edit");

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  { to: `/sp/config/legal-documents`, label: "Legal documents" },
  {
    to: `/sp/${serviceProviderId.value}/legal-documents/new`,
    label: isCreating.value ? "Create legal document" : form.externalFacingName,
  },
]);

const TABS: ComputedRef<TypeTab[]> = computed(() => [
  { label: "Settings", name: "Settings", isRequired: false },
  {
    label: "Related items",
    name: "Related items",
    isRequired: false,
    isHidden: isCreating.value,
  },
]);
const tabActive = ref(TABS.value[0].name);

const isLegalDocumentDeletable: ComputedRef<boolean> = computed(
  () => props.document?.deletable ?? true,
);

const mainHeaderDropdownItems = computed(() => [
  {
    label: "Delete",
    type: "button",
    color: "error",
    isDisabled:
      isCreating.value ||
      uiStore.isSPViewerOnly ||
      isDeleteLegalDocDisabled(props?.document) ||
      isConfigPublishing.value ||
      !isLegalDocumentDeletable.value,
    hint: deleteLegalDocHintText.value(props?.document),
    onClick: onOpenDialogDeleteLegalDocumentType,
  },
]);

const fileRemoved: Ref<boolean> = ref(isCreating.value);

const isDeleteLegalDocDisabled = (document: LegalDocumentTypeRead) => {
  return (
    (document?.legal_documents_count ?? 0) > 0 ||
    (document?.agreement_type_ids?.length ?? 0) > 0
  );
};

const deleteLegalDocHintText: ComputedRef<
  (document: LegalDocumentTypeRead) => string | null
> = computed(() => {
  return (document: LegalDocumentTypeRead) => {
    if (isDeleteLegalDocDisabled(document)) {
      return "You cannot delete this document because it is currently being used.";
    }
    if (isConfigPublishing.value) {
      return "You cannot delete this document as config is currently being published.";
    }
    return null;
  };
});

const formRules = {
  externalFacingName: {
    required: helpers.withMessage("Please enter a external name", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  docName: {
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(256)),
  },
  file: {
    required: helpers.withMessage(
      "Please upload at least one legal document to proceed!",
      required,
    ),
  },
};

const updateForm = (newForm: LegalDocumentForm) => {
  if (!newForm) {
    return;
  }

  form.externalFacingName = newForm.externalFacingName || "";
  form.docName = newForm.docName || "";
  form.description = newForm.description;
  form.version = newForm.version;
  form.signedBy = newForm.signedBy;
  form.signing = newForm.signing;
  form.file = newForm.file || null;
  if (form.externalFacingName) v$.value.externalFacingName.$touch();
  if (form.docName) v$.value.docName?.$touch();
  if (form.description) v$.value.description?.$touch();

  hasDocChanged.value = true;
};

const form: LegalDocumentForm = reactive({
  externalFacingName: props.data ? props.data.externalFacingName : "",
  docName: props.data ? props.data.docName : "",
  description: props.data ? props.data.description : "",
  version: props.data ? props.data.version : "",
  signing: true,
  signedBy: true,
  file: props.data ? props.data.file : null,
});

const v$ = useVuelidate(formRules, form);
const isFormBasicInfoInvalid = computed(() => !form.externalFacingName);

const isDocFormInvalid = computed(() => {
  return !form.file;
});

const onDiscard = () => {
  if (isEditing.value) {
    if (hasUnsavedChanges.value) {
      reasonToUnsave.value = "discard";
      setTextsForUnsavedChangesDialog("discard");
      warnUnsavedChanges();
    } else emit("onViewMode");
  }
  if (isCreating.value) {
    if (hasUnsavedChanges.value) {
      reasonToUnsave.value = "leave";
      setTextsForUnsavedChangesDialog("leave");
      warnUnsavedChanges();
    }
    router.push("/sp/config/legal-documents");
  }
};

const onSubmitDialogUnsavedChanges = () => {
  if (isCreating.value || reasonToUnsave.value === "leave") {
    confirmLeave(nextRef.value);
  } else {
    emit("onViewMode");
  }
  hasUnsavedChanges.value = false;
  isDialogUnsavedChangesOpen.value = false;
};

const initialCreatePayloadBody: LegalDocumentTypeCreate = {
  name: "",
  description: "",
  text_source: "pdf",
  signature_required_from_SC: true,
  signature_required_from_SP: false,
  signature_required_from_end_user: false,
  version_reference: "",
  external_facing_name: "",
};

const initialEditPayloadBody: Ref<LegalDocumentTypeUpdate | null> = ref(null);

const payloadBody: ComputedRef<LegalDocumentTypeUpdate> = computed(() => ({
  name: form.docName,
  description: form.description,
  text_source: "pdf",
  signature_required_from_SC: true,
  signature_required_from_SP: false,
  signature_required_from_end_user: false,
  version_reference: form.version,
  external_facing_name: form.externalFacingName,
}));

const payload: ComputedRef<LegalDocumentTypeCreate | LegalDocumentTypeUpdate> =
  computed(() => {
    const payloadKey = isCreating.value
      ? "legal_document_type_create"
      : "legal_document_type_update";

    return {
      [payloadKey]: payloadBody.value,
    };
  });

const updateOrCreateDocument = async (formData: FormData) => {
  let response;
  try {
    response = await legalDocumentTypesService.patchLegalDocumentType(
      serviceProviderId.value,
      isCreating.value
        ? legalDocumentTypeId.value
        : `${route.params.legalDocumentTypeId}`,
      filterEmptyPropertiesFromObject(payload.value),
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(error, true),
      status: "error",
    });
    return;
  }
  try {
    await legalDocumentTypesService.postDocumentToLegalDocumentType(
      serviceProviderId.value,
      isCreating.value
        ? legalDocumentTypeId.value
        : route.params.legalDocumentTypeId.toString(),
      formData,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
  if (response) {
    router.push({
      name: "LegalDocumentDetails",
      params: {
        service_provider_id: serviceProviderId.value,
        legalDocumentTypeId: response.id,
      },
    });
  }
};

const submitForm = async () => {
  v$.value.$validate();
  if (isFormBasicInfoInvalid.value) {
    isBasicInfoExpandableOpen.value = true;
    return;
  }
  if (isDocFormInvalid.value) {
    isDocExpandableOpen.value = true;
    return;
  }
  try {
    isLoading.value = true;
    isButtonSaveDisabled.value = true;
    hasUnsavedChanges.value = false;
    const formData = new FormData();
    formData.append("pdf", form.file);
    await updateOrCreateDocument(formData);
    emit("onSave", form);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(error, true),
      status: "error",
    });
  } finally {
    isLoading.value = false;
    isButtonSaveDisabled.value = false;
  }
};

const onOpenDialogDeleteLegalDocumentType = () => {
  isDeleteDocumentDialogOpen.value = true;
};

const onCloseDialogDeleteLegalDocumentType = () => {
  isDeleteDocumentDialogOpen.value = false;
};

const onSubmitDialogDeleteLegalDocumentType = async () => {
  if (isConfigNotPublished.value)
    localStorage.setItem("hideConfigBanner", "false");
  router.replace("/sp/config/legal-documents");
};

watch(
  () => [payloadBody.value, hasDocChanged.value, Boolean(form.file)],
  ([payloadBodyNew, hasDocChangedNew, isFileUploaded]) => {
    if (isCreating.value) {
      hasUnsavedChanges.value = Boolean(
        !isEqual(initialCreatePayloadBody, payloadBodyNew) || isFileUploaded,
      );
    }
    if (isEditing.value && initialEditPayloadBody.value) {
      hasUnsavedChanges.value = Boolean(
        !isEqual(initialEditPayloadBody.value, payloadBodyNew) ||
          hasDocChangedNew,
      );
    }
  },
);

onMounted(async () => {
  serviceProviderId.value = route.params.service_provider_id as string;
  if (serviceProviderId.value && isCreating.value) {
    try {
      const response = await legalDocumentTypesService.postLegalDocumentType(
        serviceProviderId.value,
      );
      legalDocumentTypeId.value = response.id;
    } catch (error) {
      eventBus.$emit("onShowToast", {
        text: "Something went wrong",
        status: "error",
      });
    }
  }

  if (isEditing.value) {
    initialEditPayloadBody.value = {
      name: props.data.docName,
      description: props.data.description,
      text_source: "pdf",
      signature_required_from_SC: true,
      signature_required_from_SP: false,
      signature_required_from_end_user: false,
      version_reference: props.data.version,
      external_facing_name: props.data.externalFacingName,
    };
  }
});

onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value) {
    if (doNotShowNextTime.valueOf()) next();
    else {
      reasonToUnsave.value = "leave";
      setTextsForUnsavedChangesDialog("leave");
      nextRef.value = next;
      updateTargetPages(from.path.toString(), to.path.toString());
      warnUnsavedChanges();
    }
  } else {
    next();
  }
});

const updateBasicInfoOpen = (value: boolean) => {
  isBasicInfoExpandableOpen.value = value;
};

const updateDocOpen = (value: boolean) => {
  isDocExpandableOpen.value = value;
};
</script>

<template>
  <m-m-page-header
    base-key="configuration.legal_documents.legal_document_new"
    icon="book-open"
    :breadcrumbs="breadcrumbs"
    :is-in-edit-mode="true"
    :params="{ title, subtitle }"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <m-m-button
          :loading="isLoading"
          :disabled="isButtonSubmitDisabled"
          cy="save-legal-doc-button"
          @click="submitForm"
        >
          Save
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
        <m-m-button
          variant="outlined"
          cy="discard-legal-doc-button"
          @click="onDiscard"
        >
          Discard
        </m-m-button>
        <m-m-dropdown
          v-if="!isCreating"
          :items="mainHeaderDropdownItems"
          max-width="218px"
          cy="legal-document-type-dropdown"
        /></div></template
  ></m-m-page-header>
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="tabActive" :items="TABS" :is-in-edit-mode="true" />
  </m-m-teleport>
  <m-m-tab-items :current-tab="tabActive">
    <m-m-tab-item :name="TABS[0].name">
      <SettingsTab
        :form="form"
        :validation="v$"
        :pdf-url="pdfUrl"
        :has-doc-changed="hasDocChanged"
        :is-edit-mode="true"
        :is-basic-info-expandable-open="isBasicInfoExpandableOpen"
        :is-doc-expandable-open="isDocExpandableOpen"
        @update:form="updateForm"
        @document-removed="fileRemoved = true"
        @uploaded-file="updateForm($event)"
        @update:basic-info-open="updateBasicInfoOpen"
        @update:doc-open="updateDocOpen"
      />
    </m-m-tab-item>
    <m-m-tab-item :name="TABS[1].name">
      <tab-related-items
        :documents-signed-count="legalDocumentCount"
        :agreements="agreementTypeIds"
      />
    </m-m-tab-item>
  </m-m-tab-items>

  <DialogDeleteDocument
    :is-open="isDeleteDocumentDialogOpen"
    :service-provider-id="serviceProviderId"
    :data="document?.id"
    @close="onCloseDialogDeleteLegalDocumentType"
    @submit="onSubmitDialogDeleteLegalDocumentType"
  />

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>
