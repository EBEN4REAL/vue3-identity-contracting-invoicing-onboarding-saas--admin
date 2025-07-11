import { Given } from "cypress-cucumber-preprocessor/steps";
import { policyTypes } from "../../fixtures/service-provider/policy-types";
import serviceProviders from "../../fixtures/service_providers";
import {
  permissions,
  policyTypePermissionByPermissionId,
  policyTypePermissions,
} from "../../fixtures/permissions";
import { context } from "../app";
import config from "../../../../src/mm.config.json";

Given(
  "the Permissions {string} for Policy Type {string} for Service Provider {string} request has been intercepted",
  (
    permissionsFixtureId: string,
    policyTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const policyTypeId: string = policyTypes[policyTypeFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types/${policyTypeId}/entitlements`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        entitlements: policyTypePermissions[permissionsFixtureId],
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the add Permissions for Policy Type {string} for Service Provider {string} POST request has been intercepted",
  (policyTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const policyTypeId: string = policyTypes[policyTypeFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types/${policyTypeId}/entitlements`;
    cy.intercept("POST", url, {
      statusCode: 201,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Permission {string} for Policy Type {string} for Service Provider {string} DELETE request has been intercepted",
  (
    permissionsFixtureId: string,
    policyTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const policyTypeId: string = policyTypes[policyTypeFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types/${policyTypeId}/entitlements/${policyTypePermissionByPermissionId[permissionsFixtureId].id}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Permissions {string} Service Provider {string} request has been intercepted",
  (permissionsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/entitlements*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: permissions[permissionsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Permission {string} for Service Provider {string} request has been intercepted",
  (permissionsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/entitlements/${policyTypePermissionByPermissionId[permissionsFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policyTypePermissionByPermissionId[permissionsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
