import config from "../../../../src/mm.config.json";
import { Given } from "cypress-cucumber-preprocessor/steps";
import { licenses } from "../../fixtures/service-provider/licenses";
import { context } from "../app";
import serviceProviders from "../../fixtures/service_providers";

Given(
  "the Licenses request has been intercepted to return the Licenses {string} for Service Provider {string}",
  (filterId: string, serviceProviderId: string): void => {
    const licensesIdsArr: string[] = filterId.split(",");
    const licensesPagination = {
      offset: 0,
      limit: 10,
      results: licensesIdsArr.map((license: string) => licenses[license]),
      size: licensesIdsArr.length > 10 ? 10 : licensesIdsArr.length,
      total: licensesIdsArr.length,
    };
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreements*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: licensesPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Licenses request has been intercepted to return the Licenses {string} for Service Provider {string} with query params {string}",
  (filterId: string, serviceProviderId: string, queryParams: string): void => {
    const licensesIdsArr: string[] = filterId.split(",");
    const licensesPagination = {
      offset: 0,
      limit: 10,
      results: licensesIdsArr.map((license: string) => licenses[license]),
      size: licensesIdsArr.length > 10 ? 10 : licensesIdsArr.length,
      total: licensesIdsArr.length,
    };
    const url = `${config.policies.url}/service-providers/${serviceProviderId}/agreements?${queryParams}`;

    cy.intercept("GET", url, {
      statusCode: 200,
      body: licensesPagination,
    }).as(url);

    context.aliases.push(url);
  },
);

// TODO: Delete later
Given(
  "the Licenses request has been intercepted to return the License {string} for Service Provider {string}",
  (licenseId: string, serviceProviderId: string): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreements/${licenses[licenseId]?.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: licenses[licenseId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies GET Agreement Type request has been intercepted to return Agreement Type {string} for Service Provider {string}",
  (agreementTypeFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const agreementType = licenses[agreementTypeFixtureId];
    const url = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types/${agreementType.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: agreementType,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Licenses request has been intercepted to return for Service Provider {string} the Licenses {string} for service consumer {string}",
  (
    serviceProviderId: string,
    filterId: string,
    serviceConsumerId: string,
  ): void => {
    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProviderId}/agreements?service_consumer_id=${serviceConsumerId}?limit=10&offset=0`,
      {
        statusCode: 200,
        body: licenses[filterId],
      },
    );
  },
);

Given(
  "the Licenses request has been intercepted to return for Service Provider {string} the Active Licenses {string} for service consumer {string}",
  (
    serviceProviderId: string,
    filterId: string,
    serviceConsumerId: string,
  ): void => {
    const licensesIdsArr: string[] = filterId.split(",");
    const licensesPagination = {
      offset: 0,
      limit: 10,
      results: licensesIdsArr.map((license: string) => licenses[license]),
      size: licensesIdsArr.length > 10 ? 10 : licensesIdsArr.length,
      total: licensesIdsArr.length,
    };
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreements?cancelled=false?service_consumer_id=${serviceConsumerId}?limit=*&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: licensesPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to cancel the License with id {string}",
  (serviceProviderId: string, agreementId: string): void => {
    cy.intercept(
      "POST",
      `${config.policies.url}/service-providers/${serviceProviderId}/agreements/${agreementId}/cancel`,
      {
        statusCode: 200,
        body: licenses[agreementId],
      },
    );
  },
);
