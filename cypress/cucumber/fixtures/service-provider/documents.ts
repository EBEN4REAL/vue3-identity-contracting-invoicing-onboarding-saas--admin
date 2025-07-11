import {
  LegalDocumentTypeIdAndSP,
  LegalDocumentTypeRead,
} from "../../../../src/service-providers/LegalDocuments/legal-documents.types";

export const documents: {
  [key: string]: LegalDocumentTypeRead;
} = {
  "001": {
    id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    name: "doc name",
    description: "doc desc",
    text_source: "pdf",
    signature_required_from_SC: true,
    signature_required_from_SP: true,
    signature_required_from_end_user: true,
    service_provider_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    version_reference: "string",
    legal_document_count: 0,
    pdf_filename: "acme.pdf",
    pdf_size: 6014,
    agreement_type_ids: [],
    external_facing_name: "External Name",
  },
  "002": {
    id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    name: "doc name",
    description: "doc desc",
    text_source: "pdf",
    signature_required_from_SC: true,
    signature_required_from_SP: true,
    signature_required_from_end_user: true,
    service_provider_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    version_reference: "string",
    legal_document_count: 1,
    agreement_type_ids: ["2fa85f64-5717-4562-b3fc-2c963f66afa7"],
    pdf_filename: "acme.pdf",
    pdf_size: 6014,
    external_facing_name: "External Name",
  },
  "003": {
    id: "2010037e-e92b-40ff-8166-b77257836d3a",
    name: "doc 3",
    description: "doc desc 3",
    text_source: "pdf",
    signature_required_from_SC: true,
    signature_required_from_SP: true,
    signature_required_from_end_user: true,
    service_provider_id: "2010037e-e92b-40ff-8166-b77257836d3a",
    version_reference: "version 3",
    legal_document_count: 1,
    external_facing_name: "External Name",
  },
};

export const createDocument: {
  [key: string]: LegalDocumentTypeIdAndSP;
} = {
  "001": {
    id: "2010037e-e92b-40ff-8166-b77257836d3a",
    service_provider_id: "00000000-0000-0000-0002-000000000001",
  },
};

export const pdf_url: {
  [key: string]: string;
} = {
  "001": "cypress/downlaods/acme.pdf",
};
