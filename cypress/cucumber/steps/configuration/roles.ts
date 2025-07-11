import { Given } from "cypress-cucumber-preprocessor/steps";
import { policyTypes } from "../../fixtures/service-provider/policy-types";
import serviceProviders from "../../fixtures/service_providers";
import {
  policyTypeRoleByRoleId,
  policyTypeRoles,
  roles,
} from "../../fixtures/roles";
import { context } from "../app";
import config from "../../../../src/mm.config.json";

Given(
  "the Roles {string} for Policy Type {string} for Service Provider {string} request has been intercepted",
  (
    rolesFixtureId: string,
    policyTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const policyTypeId: string = policyTypes[policyTypeFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types/${policyTypeId}/roles`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        roles: policyTypeRoles[rolesFixtureId],
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the add Roles for Policy Type {string} for Service Provider {string} POST request has been intercepted",
  (policyTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const policyTypeId: string = policyTypes[policyTypeFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types/${policyTypeId}/roles`;
    cy.intercept("POST", url, {
      statusCode: 201,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Role {string} for Policy Type {string} for Service Provider {string} DELETE request has been intercepted",
  (
    rolesFixtureId: string,
    policyTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const policyTypeId: string = policyTypes[policyTypeFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types/${policyTypeId}/roles/${policyTypeRoleByRoleId[rolesFixtureId].id}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Roles {string} Service Provider {string} request has been intercepted",
  (rolesFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/roles*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: roles[rolesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Role {string} for Service Provider {string} request has been intercepted",
  (rolesFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/roles/${policyTypeRoleByRoleId[rolesFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policyTypeRoleByRoleId[rolesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
