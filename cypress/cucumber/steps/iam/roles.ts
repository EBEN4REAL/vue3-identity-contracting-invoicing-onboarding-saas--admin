import { Given } from "cypress-cucumber-preprocessor/steps";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import serviceProviders from "../../fixtures/service_providers";
import { role } from "../../fixtures/roles";

Given(
  "the Role for Service provider {string} POST request has been intercepted",
  (serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/roles`;
    cy.intercept("POST", url, {
      statusCode: 201,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Role {string} for Service provider {string} PATCH request has been intercepted",
  (roleFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const roleId: string = role[roleFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/roles/${roleId}`;
    cy.intercept("PATCH", url, {
      statusCode: 201,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Role {string} for Service provider {string} DELETE request has been intercepted",
  (roleFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const roleId: string = role[roleFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/roles/${roleId}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);
