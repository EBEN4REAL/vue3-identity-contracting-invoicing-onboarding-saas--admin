import { Given } from "cypress-cucumber-preprocessor/steps";
import { policies } from "../../fixtures/service-provider/policies";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import config from "../../../../src/mm.config.json";
import { context } from "../app";
import { PolicyTypeRead } from "../../../../src/policies/policies.types";
import { policyTypes } from "../../fixtures/service-provider/policy-types";

Given(
  "the Configuration GET Policy Types request has been intercepted to return no Policy Types for Service Provider {string}",
  (serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    cy.intercept(
      "GET",
      `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types*`,
      {
        statusCode: 200,
        body: [],
      },
    );
  },
);

Given(
  "the Configuration GET Policy Types request has been intercepted to return Policy Types {string} for Service Provider {string}",
  (policyTypesFixtureIds: string, serviceProviderFixtureId: string): void => {
    const policyTypes = policies[policyTypesFixtureIds];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policyTypes,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Policy Type request has been intercepted to return Policy Type {string} for Service Provider {string}",
  (policyTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const policyType: PolicyTypeRead = policyTypes[policyTypeFixtureId];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}`;
    console.log(url);
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policyType,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Policy Type request has been intercepted to create and return Policy Type {string} for Service Provider {string}",
  (policyTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const policyType: PolicyTypeRead = policyTypes[policyTypeFixtureId];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types`;
    cy.intercept("POST", url, {
      statusCode: 201,
      body: policyType,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to delete the Policy with id {string}",
  (service_provider_id: string, policy_type_id: string): void => {
    const url: string = `${config.configuration.url}/service-providers/${service_provider_id}/policy-types/${policy_type_id}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
      body: policies[policy_type_id],
    }).as(url);
    context.aliases.push(url);
  },
);
