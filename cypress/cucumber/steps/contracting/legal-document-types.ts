import { Given } from "cypress-cucumber-preprocessor/steps";
import { PaginationSchema_LegalDocumentTypeRead_ } from "../../../../src/service-providers/LegalDocuments/legal-documents.types";
import { context } from "../app";
import { documents } from "../../fixtures/service-provider/documents";
import config from "../../../../src/mm.config.json";

Given(
  "the contracting request has been intercepted to return empty documents for Service Provider {string}",
  (serviceProviderId: string): void => {
    const docsPagination: PaginationSchema_LegalDocumentTypeRead_ = {
      offset: 0,
      limit: 10,
      results: [],
      size: 0,
      total: 0,
    };
    const url: string = `${config.contracting.url}/service-providers/${serviceProviderId}/legal-document-types?*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: docsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the contracting request has been intercepted to return the documents {string} for Service Provider {string}",
  (documentId: string, serviceProviderId: string): void => {
    const docIdsArr: string[] = documentId.split(",");
    const results = docIdsArr.map((docId: string) => documents[docId]);
    const docsPagination: PaginationSchema_LegalDocumentTypeRead_ = {
      offset: 0,
      limit: 10,
      results: results,
      size: docIdsArr.length > 10 ? 10 : docIdsArr.length,
      total: docIdsArr.length,
    };
    const url: string = `${config.contracting.url}/service-providers/${serviceProviderId}/legal-document-types?*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: docsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);
