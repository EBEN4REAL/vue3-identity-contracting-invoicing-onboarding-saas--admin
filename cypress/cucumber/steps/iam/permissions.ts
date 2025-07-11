import { Given } from "cypress-cucumber-preprocessor/steps";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import serviceProviders from "../../fixtures/service_providers";
import { permission } from "../../fixtures/permissions";

Given(
  "the Permission for Service provider {string} POST request has been intercepted",
  (serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/entitlements`;
    cy.intercept("POST", url, {
      statusCode: 201,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Permission {string} for Service provider {string} PATCH request has been intercepted",
  (permissionFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const permissionId: string = permission[permissionFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/entitlements/${permissionId}`;
    cy.intercept("PATCH", url, {
      statusCode: 201,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Permission {string} for Service provider {string} DELETE request has been intercepted",
  (permissionFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const permissionId: string = permission[permissionFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/entitlements/${permissionId}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);
