import { LegalDocumentTypeWithPdfSyncStatusRead } from "../../../../src/service-providers/LegalDocuments/legal-documents.types";

export type AddLegalDocToLicenseResponse = {
  agreement_type_id: string;
  legal_document_type_id: string;
  id: string;
}[];

export const legalDocToLicense: {
  [key: string]: LegalDocumentTypeWithPdfSyncStatusRead;
} = {
  "001": [
    {
      id: "a6d887a9-14b8-4b3b-ab40-402492771f9f",
      name: "doc 1",
      description: "A Legal document",
      pdf_sync_status: "SUCCESS",
    },
    {
      id: "634f4e51-31e7-4dd9-a652-78a8239d0abb",
      name: "doc 2",
      description: "doc 2 desc",
      pdf_sync_status: "SUCCESS",
    },
    {
      id: "e97ac3a6-072c-4edf-a2fb-01a8745bc08c",
      name: "doc 3",
      description: "dco 3",
      pdf_sync_status: "SUCCESS",
    },
  ],
  "001-updated": [
    {
      id: "a6d887a9-14b8-4b3b-ab40-402492771f9f",
      name: "doc 1",
      description: "",
      pdf_sync_status: "SUCCESS",
    },
    {
      id: "634f4e51-31e7-4dd9-a652-78a8239d0abb",
      name: "doc 2",
      description: "doc 2 desc",
      pdf_sync_status: "SUCCESS",
    },
    {
      id: "e97ac3a6-072c-4edf-a2fb-01a8745bc08c",
      name: "doc 3",
      description: "dco 3",
      pdf_sync_status: "SUCCESS",
    },
    {
      id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      name: "doc name",
      description: "doc desc",
      pdf_sync_status: "SUCCESS",
    },
  ],
  "no-results": [],
};

export const addDocToLicense: {
  [key: string]: AddLegalDocToLicenseResponse;
} = {
  "001": [
    {
      agreement_type_id: "bbac1962-adaf-4393-a1d7-13962c9fb3fd",
      legal_document_type_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      id: "10e19611-5173-4031-a8c6-15e7fc4dfdd5",
    },
  ],
};
