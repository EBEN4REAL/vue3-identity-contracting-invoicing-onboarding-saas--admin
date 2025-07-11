import { Given } from "cypress-cucumber-preprocessor/steps";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import serviceProviders from "../../fixtures/service_providers";
import { legalDocumentTypes } from "../../fixtures/service-provider/legal-document-types";
import { licenses } from "../../fixtures/service-provider/licenses";
import { pdf_url } from "../../fixtures/service-provider/documents";
import { agreementTypes } from "../../fixtures/configuration/agreement-types";
import { SPAgreementTypeRead } from "../../../../src/configuration/configuration.types";
import {
  LegalDocumentTypeRead,
  PaginationSchema_LegalDocumentTypeRead_,
} from "../../../../src/service-providers/LegalDocuments/legal-documents.types";

Given(
  "the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types {string} for Service Provider {string}",
  (
    legalDocumentTypeFixtureIds: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId = serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentTypeFixtureIdsArray: string[] =
      legalDocumentTypeFixtureIds.split(",");
    const results = legalDocumentTypeFixtureIds
      ? legalDocumentTypeFixtureIdsArray.map(
          (legalDocumentTypeId: string) =>
            legalDocumentTypes[legalDocumentTypeId],
        )
      : [];

    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results,
        size: results.length > 10 ? 10 : results.length,
        total: results.length,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider {string}",
  (serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const docsPagination: PaginationSchema_LegalDocumentTypeRead_ = {
      offset: 0,
      limit: 10,
      results: [],
      size: 0,
      total: 0,
    };
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types?*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: docsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Legal Document Types request has been intercepted to create the Legal Document Type {string} for Service Provider {string}",
  (
    legalDocumentTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentType: LegalDocumentTypeRead =
      legalDocumentTypes[legalDocumentTypeFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types`;
    cy.intercept("POST", url, {
      statusCode: 200,
      body: legalDocumentType,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type {string} for Service Provider {string}",
  (
    legalDocumentTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentTypeId: string =
      legalDocumentTypes[legalDocumentTypeFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: legalDocumentTypes[legalDocumentTypeId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type {string} PDF URL for Service Provider {string}",
  (
    legalDocumentTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentTypeId: string =
      legalDocumentTypes[legalDocumentTypeFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}/pdf`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: pdf_url[legalDocumentTypeId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration Legal Document Types DELETE request has been intercepted to delete Legal Document Type {string} from Service Provider {string}",
  (
    legalDocumentTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId = serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentTypeId =
      legalDocumentTypes[legalDocumentTypeFixtureId].id;

    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}`;
    cy.intercept("DELETE", url, {
      statusCode: 200,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types {string} for Agreement Type {string} for for Service Provider {string}",
  (
    legalDocumentTypeFixtureIds: string,
    agreementTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId = serviceProviders[serviceProviderFixtureId].id;
    const agreementType = licenses[agreementTypeFixtureId];
    const legalDocumentTypeFixtureIdsArray: string[] =
      legalDocumentTypeFixtureIds.split(",");
    const results = legalDocumentTypeFixtureIds
      ? legalDocumentTypeFixtureIdsArray.map(
          (legalDocumentTypeId: string) =>
            legalDocumentTypes[legalDocumentTypeId],
        )
      : [];

    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${agreementType.id}/legal-document-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results,
        size: results.length > 10 ? 10 : results.length,
        total: results.length,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration PATCH Legal Document Type request has been intercepted to update the Legal Document Type {string} and return {string} for Service Provider {string}",
  (
    legalDocumentTypeFixtureId: string,
    legalDocumentTypeUpdatedFixtureId,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentTypeId =
      legalDocumentTypes[legalDocumentTypeFixtureId].id;
    const legalDocumentTypeUpdated: LegalDocumentTypeRead =
      legalDocumentTypes[legalDocumentTypeUpdatedFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}`;
    cy.intercept("PATCH", url, {
      statusCode: 200,
      body: legalDocumentTypeUpdated,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Legal Document Type PDF request has been intercepted to upload the Legal Document Type {string} PDF for Service Provider {string}",
  (
    serviceProviderFixtureId: string,
    legalDocumentTypeFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const legalDocumentTypeId =
      legalDocumentTypes[legalDocumentTypeFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}/pdf`;
    cy.intercept("POST", url, {
      statusCode: 200,
      body: {},
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Legal Document Types request has been intercepted to return the Agreement Type to Legal Document Types {string} for Agreement Type {string} for for Service Provider {string}",
  (
    legalDocumentTypeFixtureIds: string,
    agreementTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType: SPAgreementTypeRead =
      agreementTypes[agreementTypeFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${agreementType.id}/legal-document-types*`;
    cy.intercept("POST", url, {
      statusCode: 200,
      body: {},
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration DELETE Legal Document Type from Agreement Type request has been intercepted for Legal Document Type {string} and Agreement Type {string} for Service Provider {string}",
  (
    legalDocumentTypeFixtureId: string,
    agreementTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType: SPAgreementTypeRead =
      agreementTypes[agreementTypeFixtureId];
    const legalDocumentType: LegalDocumentTypeRead =
      legalDocumentTypes[legalDocumentTypeFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${agreementType.id}/legal-document-types/${legalDocumentType.id}`;
    cy.intercept("DELETE", url, {
      statusCode: 200,
      body: {},
    }).as(url);
    context.aliases.push(url);
  },
);
