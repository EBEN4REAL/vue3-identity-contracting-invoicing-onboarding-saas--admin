import { Given } from "cypress-cucumber-preprocessor/steps";
import { legalDocToLicense } from "../../fixtures/licenses/legal-doc-agreement";
import { LegalDocumentTypeWithPdfSyncStatusRead } from "../../../../src/service-providers/LegalDocuments/legal-documents.types";
import { context } from "../app";
import config from "../../../../src/mm.config.json";

Given(
  "the contracting request has been intercepted to return the documents {string} for agreement {string} for Service Provider {string}",
  (
    documentId: string,
    agreement_type_id: string,
    serviceProviderId: string,
  ): void => {
    const data = legalDocToLicense[documentId];

    const legalDocs: LegalDocumentTypeWithPdfSyncStatusRead = {
      offset: 0,
      limit: 10,
      results: data,
      size: data.length > 10 ? 10 : data.length,
      total: data.length,
    };
    const url = `${config.contracting.url}/service-providers/${serviceProviderId}/agreement-types/${agreement_type_id}/legal-document-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: legalDocs,
    }).as(url);
    context.aliases.push(url);
  },
);
