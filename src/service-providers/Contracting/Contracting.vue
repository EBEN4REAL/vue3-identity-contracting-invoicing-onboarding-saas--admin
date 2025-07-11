<script setup lang="ts">
import { computed, ComputedRef, Ref, ref } from "vue";
import { authService } from "../../auth/auth.service";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "../../mm_ui_kit/src/types/table.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { useRouter } from "vue-router";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";
import { LegalDocumentTypeRead } from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import DialogDeleteDocument from "~/service-providers/LegalDocuments/DialogDeleteDocument.vue";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const router = useRouter();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const documents: Ref<TableResponse<LegalDocumentTypeRead> | null> = ref(null);
const isDeleteDocumentDialogOpen: Ref<boolean> = ref(false);
const dialogDeleteDocumentData: Ref<string> = ref("");
const serviceProviderId: Ref<string | null> = ref(null);

const isButtonCreateLegalDocumentDisabled: ComputedRef<boolean> = computed(
  () => isConfigPublishing.value || uiStore.isSPViewerOnly,
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const emptyState: EmptyStateType = {
  title: "Create your first legal document template",
  description:
    "Add the content and signing requirements for your legal documents.",
  icon: "document-outline",
};

const headers: TableHeader[] = [
  {
    key: "external_facing_name",
    label: "Document name",
    sortable: true,
    sortIcon: true,
    order: "asc",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    label: "Created date",
    key: "created_date",
    sortIcon: true,
    order: "desc",
    sortable: true,
    defaultSortItem: true,
  },
  {
    key: "actions",
    label: "",
  },
];
const isLoading: Ref<boolean> = ref(false);

const isDeleteLegalDocDisabled = (document: LegalDocumentTypeRead) => {
  return (
    (document.legal_documents_count ?? 0) > 0 ||
    (document?.agreement_type_ids?.length ?? 0) > 0 ||
    isConfigPublishing.value
  );
};

const onCloseDialogDeleteDocument = async () => {
  isDeleteDocumentDialogOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const deleteLegalDocHintText: ComputedRef<
  (document: LegalDocumentTypeRead) => string | null
> = computed(() => {
  return (document: LegalDocumentTypeRead): string | null => {
    if (isDeleteLegalDocDisabled(document)) {
      return "You cannot delete this document because it is currently being used.";
    }
    if (isConfigPublishing.value) {
      return "You cannot delete this item as config is currently being published.";
    }
    return null;
  };
});

const handleActionClick = () =>
  router.push(`/sp/${serviceProviderId.value}/legal-documents/new`);

const handleUpdateParams = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  await getLegalDocuments(params);
};

const handleDeleteDocumentDialog = (document: LegalDocumentTypeRead) => {
  isDeleteDocumentDialogOpen.value = true;
  dialogDeleteDocumentData.value = document.id;
};

const getLegalDocuments = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || null;
    }
    const response = await legalDocumentTypesService.getLegalDocumentTypes(
      serviceProviderId.value as string,
      params ? params : { limit: ITEMS_PER_PAGE[0], offset: "0" },
    );
    if (response?.results?.length) {
      response?.results.forEach((legalDocument) => {
        legalDocument.hidden = legalDocument?.wizard?.hidden || false;
      });
    }
    documents.value = response;
  } finally {
    isLoading.value = false;
  }
};

const goToLegalDocumentDetails = (legalDocumentTypeId: string) => {
  router.push({
    name: "LegalDocumentDetails",
    params: {
      service_provider_id: serviceProviderId.value,
      legalDocumentTypeId,
    },
  });
};

const isLegalDocumentDeletable = (
  legalDocument: LegalDocumentTypeRead,
): boolean => legalDocument?.deletable ?? true;

const isLegalDocumentEditable = (
  legalDocument: LegalDocumentTypeRead,
): boolean => legalDocument?.editable ?? true;

const dropdownItems = (row: LegalDocumentTypeRead) => [
  {
    label: "View",
    type: "button",
    onClick: () => {
      goToLegalDocumentDetails(row.id);
    },
  },
  {
    label: "Edit",
    type: "button",
    isDisabled:
      !!isConfigPublishing.value ||
      uiStore.isSPViewerOnly ||
      !isLegalDocumentEditable(row),
    hint: isConfigPublishing.value
      ? "You cannot edit this legal document as config is currently being published"
      : "",
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/legal-documents/${row.id}`,
        query: { editMode: "true" },
      });
    },
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    hint: deleteLegalDocHintText.value(row),
    isDisabled:
      isDeleteLegalDocDisabled(row) ||
      !isLegalDocumentDeletable(row) ||
      uiStore.isSPViewerOnly,
    onClick: () => handleDeleteDocumentDialog(row),
  },
];

const goToDetailedViewLink = (row: string) =>
  `/sp/${serviceProviderId.value}/legal-documents/${row}`;

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_template",
    action: handleActionClick,
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="contracting"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-table
      :is-loading="isLoading"
      :headers="headers"
      :rows="documents?.results"
      :total-rows="documents?.total"
      cy="legal-documents-table"
      show-search
      :empty-state="emptyState"
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          prepend-icon="plus-white"
          cy="empty-state-button-create-legal-document"
          :is-disabled="isButtonCreateLegalDocumentDisabled"
          @click="handleActionClick"
        >
          Create template
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </template>
      <template #name="{ row }">
        <m-m-link
          :to="goToDetailedViewLink(row.id)"
          font-weigth="500"
          :data-cy="`column-name-${row.id}`"
        >
          {{ row.name }}
        </m-m-link>
      </template>
      <template #description="{ row }">
        <span :data-cy="`column-description-${row.id}`">
          {{ row.description }}
        </span>
      </template>
      <template #created_date="{ row }">
        <m-m-formatted-date
          :raw-date="row.created_date"
          format="D MMM YYYY, HH:mm"
        />
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="dropdownItems(row)"
            :cy="`actions-dropdown-${row.id}`"
            list-variant="shadow"
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
        </div>
      </template> </m-m-table
  ></m-m-overview-page>
  <m-m-config-banner />
  <dialog-delete-document
    :is-open="isDeleteDocumentDialogOpen"
    :data="dialogDeleteDocumentData"
    :service-provider-id="serviceProviderId"
    @close="onCloseDialogDeleteDocument"
    @submit="getLegalDocuments"
  />
</template>

<style scoped></style>
