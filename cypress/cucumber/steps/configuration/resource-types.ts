import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import resourceTypes from "../../fixtures/resource_types";
import { ResourceTypeRead } from "../../../../src/policies/policies.types";

Given(
  "the Configuration GET Resource Types request has been intercepted to return the Resource Types {string} for Service Provider {string}",
  (resourceTypeFixtureIds: string, serviceProviderFixtureId: string): void => {
    const results: ResourceTypeRead[] = resourceTypeFixtureIds
      .split(",")
      .map((resourceTypeFixtureId) => resourceTypes[resourceTypeFixtureId]);
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results,
        size: results.length,
        total: results.length,
      },
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Resource Type request has been intercepted to return the Resource Type {string} for Service Provider {string}",
  (resourceTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-types/${resourceTypes[resourceTypeFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: resourceTypes[resourceTypeFixtureId],
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration DELETE Resource Type request has been intercepted to delete the Resource Type {string} for Service Provider {string}",
  (resourceTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-types/${resourceTypes[resourceTypeFixtureId].id}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Resource Type request has been intercepted to add the Resource Type {string} for Service Provider {string}",
  (resourceTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-types`;
    cy.intercept("POST", url, {
      statusCode: 201,
      body: resourceTypes[resourceTypeFixtureId],
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration PATCH Resource Type request has been intercepted to update the Resource Type {string} and return the Resource Type {string} for Service Provider {string}",
  (
    resourceTypeFixtureId: string,
    updatedResourceTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const url = `${config.configuration.url}/service-providers/${serviceProviders[serviceProviderFixtureId].id}/resource-types/${resourceTypes[resourceTypeFixtureId].id}`;
    cy.intercept("PATCH", url, {
      statusCode: 200,
      body: resourceTypes[updatedResourceTypeFixtureId],
    }).as(url);

    context.aliases.push(url);
  },
);
