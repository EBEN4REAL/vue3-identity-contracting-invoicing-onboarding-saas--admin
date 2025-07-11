<script setup lang="ts">
import { computed, ComputedRef, onMounted, Ref, ref } from "vue";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { authService } from "~/auth/auth.service";
import DialogDeleteDocument from "./DialogDeleteDocument.vue";
import { useRouter } from "vue-router";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { legalDocumentTypesService } from "~/configuration/legal-document-types.service";
import { LegalDocumentTypeRead } from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";

const router = useRouter();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const documents: Ref<TableResponse<LegalDocumentTypeRead> | null> = ref(null);
const isDeleteDocumentDialogOpen: Ref<boolean> = ref(false);
const dialogDeleteDocumentData: Ref<string> = ref("");
const serviceProviderId: Ref<string> = ref("");
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const headers: TableHeader[] = [
  {
    key: "name",
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
    (document.agreement_type_ids?.length ?? 0) > 0
  );
};

const emptyState: EmptyStateType = {
  title: "No signed contracts",
  icon: sectionIcons["legalDocs"],
};
const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const deleteLegalDocsConfigHintText = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this legal document as config is currently being published"
    : "",
);

const deleteLegalDocHintText = (document: LegalDocumentTypeRead) => {
  return isDeleteLegalDocDisabled(document)
    ? "You cannot delete this document because it is currently being used."
    : null;
};
const handleActionClick = () =>
  router.push(`/sp/${serviceProviderId.value}/legal-documents/new`);

const onOpenDialogDeleteDocument = (document: LegalDocumentTypeRead) => {
  isDeleteDocumentDialogOpen.value = true;
  dialogDeleteDocumentData.value = document.id;
};

const onCloseDialogDeleteDocument = async () => {
  isDeleteDocumentDialogOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const isLegalDocumentDeletable = (
  legalDocument: LegalDocumentTypeRead,
): boolean => legalDocument?.deletable ?? true;

const isLegalDocumentEditable = (
  legalDocument: LegalDocumentTypeRead,
): boolean => legalDocument?.editable ?? true;

const dropdownItems = (row: LegalDocumentTypeRead): TypeDropdownItem[] => [
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
    isDisabled: isConfigPublishing.value || !isLegalDocumentEditable(row),
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
    hint: isDeleteLegalDocDisabled(row)
      ? deleteLegalDocHintText(row)
      : deleteLegalDocsConfigHintText.value,
    isDisabled:
      isDeleteLegalDocDisabled(row) ||
      isConfigPublishing.value ||
      !isLegalDocumentDeletable(row),
    onClick: () => onOpenDialogDeleteDocument(row),
  },
];

const getLegalDocuments = async (params: TableRequestParams) => {
  try {
    isLoading.value = true;
    await getServiceProviderId();
    const response = await legalDocumentTypesService.getLegalDocumentTypes(
      serviceProviderId.value,
      params,
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

const getServiceProviderId = async () => {
  if (serviceProviderId.value) return;
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = `${userProfile.sp_org}`;
    }
  }
};

const goToDetailedViewLink = (row: string) =>
  `/sp/${serviceProviderId.value}/legal-documents/${row}`;

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_legal_document",
    action: () => handleActionClick(),
    isDisabled: isConfigPublishing.value,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);

onMounted(async () => {
  await getServiceProviderId();
});
</script>
<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="legal_documents.overview"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-table
      :is-loading="isLoading"
      :headers="headers"
      :rows="documents?.results"
      :total-rows="documents?.total"
      cy="table-legal-document-types"
      show-search
      :empty-state="emptyState"
      @update-params="getLegalDocuments"
    >
      <template #empty-state-button>
        <m-m-button
          size="small"
          prepend-icon="plus-white"
          cy="button-create-legal-document-type"
          :is-disabled="isConfigPublishing"
          @click="handleActionClick"
        >
          Create legal document
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
          {{ row.external_facing_name }}
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
<style scoped lang="scss"></style>
