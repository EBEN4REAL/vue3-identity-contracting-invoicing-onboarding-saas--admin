import config from "../../../../src/mm.config.json";
import { Given } from "cypress-cucumber-preprocessor/steps";
import { agreementTypes } from "../../fixtures/service-provider/licenses";
import { context } from "../app";
import { organizations } from "../../fixtures/service-provider/organizations";
import serviceProviders from "../../fixtures/service_providers";

Given(
  "the Agreements request has been intercepted to return the Agreement types {string} for Service Provider {string}",
  (filterId: string, serviceProviderId: string): void => {
    const agreementIdsArr: string[] = filterId.split(",");
    const results = agreementIdsArr.map(
      (agreementId: string) => agreementTypes[agreementId],
    );
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types?limit=10&offset=0*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results: results,
        size: 10,
        total: 18,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

// TODO: Remove later
Given(
  "the Agreements request has been intercepted to return the Agreement types {string} for Service Provider {string} with query params {string}",
  (filterId: string, serviceProviderId: string, queryParams: string): void => {
    const agreementIdsArr: string[] = filterId.split(",");
    const results = agreementIdsArr.includes("no-results")
      ? []
      : agreementIdsArr.map(
          (agreementId: string) => agreementTypes[agreementId],
        );
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types?${queryParams}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results: results,
        size: 10,
        total: 18,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies Agreement Type request has been intercepted to return the Agreement type {string} for Service Provider {string}",
  (agreementTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types/${agreementTypes[agreementTypeFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: agreementTypes[agreementTypeFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Agreements request has been intercepted to return the Agreement types {string} with type ids {string} for Service Provider {string}",
  (
    filterId: string,
    agreementTypeIds: string,
    serviceProviderId: string,
  ): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types?agreement_type_ids=${agreementTypeIds}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results: [agreementTypes[filterId]],
        size: 10,
        total: 1,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Agreements request has been intercepted to return the Agreement types {string} for Service Provider {string} for Autocomplete",
  (filterId: string, serviceProviderId: string): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 50,
        results: [agreementTypes[filterId]],
        size: 10,
        total: 18,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to assign an agreement with id {string} to an organization with id {string}",
  (
    serviceProviderId: string,
    agreementTypeId: string,
    organizationId: string,
  ): void => {
    const orgId = organizations[organizationId].results.map(
      (result) => result.organization.id,
    );
    cy.intercept(
      "POST",
      `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types/${agreementTypeId}/assign/${orgId}`,
      {
        statusCode: 200,
        body: organizations[organizationId],
      },
    );
  },
);
