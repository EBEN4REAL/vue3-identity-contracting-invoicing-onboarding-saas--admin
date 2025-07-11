import { components } from "~/contracting/contracting.schemas";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";

export type LegalDocumentForm = {
  externalFacingName: string;
  docName: string;
  description: string | null;
  version: string | null;
  signing: boolean;
  signedBy: boolean;
  file: File;
};

export type PaginationSchema_LegalDocumentTypeRead_ =
  components["schemas"]["PaginationSchema_LegalDocumentTypeRead_"];

export type LegalDocumentTypeUpdate =
  components["schemas"]["LegalDocumentTypeUpdate"];

export type LegalDocumentTypeCreate =
  components["schemas"]["LegalDocumentTypeCreate"];

export type LegalDocumentTypeDocUpload =
  components["schemas"]["Body_upload_legal_document_type_pdf_service_providers__service_provider_id__legal_document_types__legal_document_type_id__pdf_post"];

export type LegalDocumentTypeIdAndSP =
  components["schemas"]["LegalDocumentTypeIdAndSP"];

export type LegalDocumentTypeRead =
  components["schemas"]["LegalDocumentTypeRead"];

export type AgreementTypeToLegalDocumentTypeUpdate =
  components["schemas"]["AgreementTypeToLegalDocumentTypeUpdate"];

export type LegalDocumentTypeWithPdfSyncStatusRead =
  components["schemas"]["LegalDocumentTypeWithPdfSyncStatusRead"];

export type LegalDocumentTypePdfPreSignUrl =
  components["schemas"]["LegalDocumentTypePdfPreSignUrl"];
export type LegalDocumentRead = components["schemas"]["LegalDocumentRead"];
export type TypeAllocateDocToLicense = {
  agreement_type_id: string;
  id: string;
  legal_document_type_id: string;
  name: string;
  description: string;
};
export type GetLegalDocumentsParams = TableRequestParams & {
  service_consumer_id?: string;
  fully_signed?: boolean;
};
export type BasicInfoData = {
  externalFacingName: string;
  docName: string;
  description: string | null;
  version?: string | null;
  signing?: boolean;
  signedBy?: boolean;
  file: File | null;
};

export type SPLegalDocumentRead = components["schemas"]["SPLegalDocumentRead"];
