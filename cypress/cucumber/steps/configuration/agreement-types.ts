import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders from "../../fixtures/service_providers";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import { agreementTypes } from "../../fixtures/configuration/agreement-types";
import { AgreementTypePoliciesRead } from "../../../../src/configuration/configuration.types";

Given(
  "the Configuration GET Agreement types request has been intercepted to return Agreement Types {string} for Service Provider {string} with query params {string}",
  (
    agreementTypeFixtureIds: string,
    serviceProviderFixtureId: string,
    queryParams: string,
  ): void => {
    const agreementIdsArr: string[] = agreementTypeFixtureIds.split(",");
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const results = agreementIdsArr.includes("no-results")
      ? []
      : agreementIdsArr.map(
          (agreementId: string) => agreementTypes[agreementId],
        );
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types?${queryParams}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results,
        size: 10,
        total: 18,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Agreement Type request has been intercepted to return Agreement Type {string} for Service Provider {string}",
  (agreementTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType: AgreementTypePoliciesRead =
      agreementTypes[agreementTypeFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${agreementType.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: agreementType,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Agreement Types request has been intercepted to create Agreement Type {string} for Service Provider {string}",
  (agreementTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType: AgreementTypePoliciesRead =
      agreementTypes[agreementTypeFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types`;
    cy.intercept("POST", url, {
      statusCode: 200,
      body: agreementType,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type {string} and return Agreement Type {string} for Service Provider {string}",
  (
    agreementTypeToUpdateFixtureId: string,
    agreementTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType: AgreementTypePoliciesRead =
      agreementTypes[agreementTypeFixtureId];
    const agreementTypeToUpdate: AgreementTypePoliciesRead =
      agreementTypes[agreementTypeToUpdateFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${agreementTypeToUpdate.id}`;
    cy.intercept("PATCH", url, {
      statusCode: 200,
      body: agreementType,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration DELETE Agreement Type request has been intercepted to delete Agreement Type {string} for Service Provider {string}",
  (agreementTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType: AgreementTypePoliciesRead =
      agreementTypes[agreementTypeFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${agreementType.id}`;
    cy.intercept("DELETE", url, {
      statusCode: 200,
      body: agreementType,
    }).as(url);
    context.aliases.push(url);
  },
);
