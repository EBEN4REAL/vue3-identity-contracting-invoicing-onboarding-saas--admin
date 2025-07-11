import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders from "../../fixtures/service_providers";
import config from "../../../../src/mm.config.json";
import {
  attributeSet,
  attributeSets,
  attributeSetUsage,
} from "../../fixtures/onboarding/attributeSets";
import { context } from "../app";

Given(
  "the Configuration GET Attribute Sets {string} request for Service Provider {string} has been intercepted",
  (attributeSetsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeSets[attributeSetsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET Organization Attribute Sets {string} request for Service Provider {string} has been intercepted",
  (attributeSetsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets?attribute_of=ORGANIZATION*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeSets[attributeSetsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET User Attribute Sets {string} request for Service Provider {string} has been intercepted",
  (attributeSetsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets?attribute_of=USER*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeSets[attributeSetsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST Attribute Set {string} request for Service Provider {string} has been intercepted",
  (attributeSetsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    cy.intercept(
      "POST",
      `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets`,
      {
        statusCode: 200,
        body: attributeSet[attributeSetsFixtureId],
      },
    );
  },
);

Given(
  "the Configuration DELETE Attribute Set {string} request for Service Provider {string} has been intercepted",
  (attributeSetFixtureId: string, serviceProviderFixtureId: string) => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;

    cy.intercept(
      "DELETE",
      `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets/${attributeSet[attributeSetFixtureId].id}`,
      {
        statusCode: 204,
      },
    );
  },
);

Given(
  "the Configuration GET Attribute Set {string} request for Service Provider {string} has been intercepted",
  (attributeSetsFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets/${attributeSet[attributeSetsFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeSet[attributeSetsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration PATCH Attribute Set {string} request for Service Provider {string} has been intercepted",
  (attributeSetsFixtureId: string, serviceProviderFixtureId: string) => {
    const serviceProviderId = serviceProviders[serviceProviderFixtureId].id;

    cy.intercept(
      "PATCH",
      `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets/${attributeSet[attributeSetsFixtureId].id}`,
      {
        statusCode: 200,
        body: attributeSet[attributeSetsFixtureId],
      },
    );
  },
);

Given(
  "the Configuration GET Attribute Set {string} usage {string} request for Service Provider {string} has been intercepted",
  (
    attributeSetsFixtureId: string,
    attributeSetUsageFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/attribute-sets/${attributeSet[attributeSetsFixtureId].id}/usage`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeSetUsage[attributeSetUsageFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
