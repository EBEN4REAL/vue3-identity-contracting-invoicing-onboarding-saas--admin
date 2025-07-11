import { Given } from "cypress-cucumber-preprocessor/steps";
import { ResourceAttributeTypeInUseRead } from "../../../../src/configuration/configuration.types";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import resourceAttributeTypes from "../../fixtures/service-provider/resource_attributes";
import config from "../../../../src/mm.config.json";
import { context } from "../app";

Given(
  "the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types {string} for Service Provider {string}",
  (
    resourceAttributeTypeFixtureIds: string,
    serviceProviderFixtureId: string,
  ): void => {
    const results: ResourceAttributeTypeInUseRead[] =
      resourceAttributeTypeFixtureIds
        .split(",")
        .map(
          (resourceAttributeTypeFixtureId) =>
            resourceAttributeTypes[resourceAttributeTypeFixtureId],
        );
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-attribute-types*`;
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
  "the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type {string} for Service Provider {string}",
  (
    resourceAttributeTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const resourceAttributeType: ResourceAttributeTypeInUseRead =
      resourceAttributeTypes[resourceAttributeTypeFixtureId];

    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-attribute-types/${resourceAttributeType.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: resourceAttributeType,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Resource Attribute Type request has been intercepted to create the Resource Attribute Type for Service Provider {string}",
  (serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];

    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-attribute-types`;

    cy.intercept("POST", url, {
      statusCode: 201,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Resource Attribute Type request has been intercepted to return error 409 for Service Provider {string}",
  (serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];

    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-attribute-types`;

    cy.intercept("POST", url, {
      statusCode: 409,
      body: {
        detail: "Conflict",
      },
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration PATCH Resource Attribute Type request has been intercepted to update the Resource Attribute Type {string} for Service Provider {string}",
  (
    resourceAttributeTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const resourceAttributeType: ResourceAttributeTypeInUseRead =
      resourceAttributeTypes[resourceAttributeTypeFixtureId];

    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-attribute-types/${resourceAttributeType.id}`;

    cy.intercept("PATCH", url, {
      statusCode: 200,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Configuration DELETE Resource Attribute Type request has been intercepted to delete the Resource Attribute Type {string} for Service Provider {string}",
  (
    resourceAttributeTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const resourceAttributeType: ResourceAttributeTypeInUseRead =
      resourceAttributeTypes[resourceAttributeTypeFixtureId];

    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/resource-attribute-types/${resourceAttributeType.id}`;

    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);

    context.aliases.push(url);
  },
);
