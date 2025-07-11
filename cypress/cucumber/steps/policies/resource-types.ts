import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import resourceTypes from "../../fixtures/resource_types";
import { context } from "../app";
import { ResourceTypeRead } from "../../../../src/policies/policies.types";
import resourceAttributeTypes from "../../fixtures/service-provider/resource_attributes";
import config from "../../../../src/mm.config.json";

Given(
  "the IAM Service Providers request has been intercepted to return the Resources {string} for Service Provider {string}",
  (resourceTypesFixtureIds: string, serviceProviderFixtureId: string): void => {
    const resourceTypeArr: string[] = resourceTypesFixtureIds.split(",");
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];

    const url: string = `${config.policies.url}/service-providers/${serviceProvider.id}/resource-types*`;

    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        results: resourceTypeArr.map(
          (resourceTypeId: string) => resourceTypes[resourceTypeId],
        ),
        total: resourceTypeArr.length,
      },
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers OAuth Clients request has been intercepted to return the Resource {string} for Service Provider {string}",
  (resourceTypesFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const resourceType: ResourceTypeRead =
      resourceTypes[resourceTypesFixtureId];
    const url: string = `${config.policies.url}/service-providers/${serviceProvider.id}/resource-types/${resourceType.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: resourceTypes[resourceTypesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies Service Providers Resource Attributes request has been intercepted to get the resource attribute type {string} for Service Provider {string}",
  (
    resourceAttributeTypeFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const resourceAttributeType =
      resourceAttributeTypes[resourceAttributeTypeFixtureId];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.policies.url}/service-providers/${serviceProvider.id}/resource-attribute-types/${resourceAttributeType.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: resourceAttributeType,
    }).as(url);
    context.aliases.push(url);
  },
);
