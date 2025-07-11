import config from "../../../../src/mm.config.json";
import { Given } from "cypress-cucumber-preprocessor/steps";
import { filter, filters } from "../../fixtures/service-provider/filters";
import { context } from "../app";
import serviceProviders from "../../fixtures/service_providers";
import { policyTypes } from "../../fixtures/service-provider/policy-types";

Given(
  "the Filters request has been intercepted to return the Filters {string} for Service Provider {string}",
  (filterId: string, serviceProviderId: string): void => {
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/filters*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: filters[filterId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies POST request to add Filters to Policy {string} with Filter {string} and Service provider {string} has been intercepted",
  (
    policyTypeFixtureId: string,
    filterFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider = serviceProviders[serviceProviderFixtureId];
    const policyType = policyTypes[policyTypeFixtureId];
    const filterObj = filter[filterFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}/filters`;
    const payload = {
      filter_id: filterObj.id,
    };
    cy.intercept("POST", url, {
      statusCode: 200,
      body: payload,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to fetch the Filters with id {string}",
  (service_provider_id: string, filter_id: string): void => {
    const url: string = `${config.configuration.url}/service-providers/${service_provider_id}/filters*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        results: [filter[filter_id]],
      },
      offset: 0,
      limit: 10,
      total: 1,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to fetch no Filters",
  (service_provider_id: string): void => {
    const url: string = `${config.policies.url}/service-providers/${service_provider_id}/filters*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        results: [],
      },
      offset: 0,
      limit: 10,
      total: 1,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to fetch the Filter with id {string}",
  (service_provider_id: string, filter_id: string): void => {
    const url: string = `${config.configuration.url}/service-providers/${service_provider_id}/filters/${filter[filter_id].id}*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: filter[filter_id],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to update the Filter with id {string}",
  (service_provider_id: string, filter_id: string): void => {
    const url = `${config.configuration.url}/service-providers/${service_provider_id}/filters/${filter[filter_id].id}`;
    cy.intercept("PATCH", url, {
      statusCode: 200,
      body: filter[filter_id],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to create the Filter with id {string}",
  (service_provider_id: string, filter_id: string): void => {
    const url = `${config.configuration.url}/service-providers/${service_provider_id}/filters`;
    cy.intercept("POST", url, {
      statusCode: 200,
      body: filter[filter_id],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to delete the Filter item with id {string}",
  (service_provider_id: string, filter_id: string): void => {
    cy.intercept(
      "DELETE",
      `${config.configuration.url}/service-providers/${service_provider_id}/filters/${filter[filter_id].id}`,
      {
        statusCode: 204,
      },
    );
  },
);

Given(
  "the Service Provider {string} request has been intercepted to delete the Filter with id {string}",
  (service_provider_id: string, filter_id: string): void => {
    cy.intercept(
      "DELETE",
      `${config.configuration.url}/service-providers/${service_provider_id}/filters/${filter_id}`,
      {
        statusCode: 204,
        body: filters[filter_id],
      },
    );
  },
);
