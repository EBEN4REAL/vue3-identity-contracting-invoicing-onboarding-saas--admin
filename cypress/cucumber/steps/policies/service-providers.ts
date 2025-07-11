import { Given } from "cypress-cucumber-preprocessor/steps";
import config from "../../../../src/mm.config.json";
import { license } from "../../fixtures/licenses/license";
import { context } from "../app";

Given(
  "the Service Provider {string} request has been intercepted to fetch the License with id {string}",
  (serviceProviderId: string, licenseFixtureId: string): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types/${license[licenseFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: license[licenseFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to fetch the License and service consumer id {string} and id {string}",
  (
    serviceProviderId: string,
    service_consumer_id: string,
    licenseFixtureId: string,
  ): void => {
    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProviderId}/agreement-types?service_consumer_id_excluded=${service_consumer_id}*`,
      {
        statusCode: 200,
        body: license[licenseFixtureId],
      },
    );
  },
);

Given(
  "the Service Provider {string} request has been intercepted to delete the License with id {string}",
  (serviceProviderId: string, licenseFixtureId: string): void => {
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types/${license[licenseFixtureId].id}`;
    cy.intercept("DELETE", url, {
      statusCode: 200,
      body: null,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Service Provider {string} request has been intercepted to create the License with id {string}",
  (serviceProviderId: string, licenseFixtureId: string): void => {
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/agreement-types`;
    cy.intercept("POST", url, {
      statusCode: 200,
      body: license[licenseFixtureId],
    }).as(url);

    context.aliases.push(url);
  },
);
