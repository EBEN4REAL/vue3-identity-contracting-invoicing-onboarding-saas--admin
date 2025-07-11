import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders from "../../fixtures/service_providers";
import Oauth_clients from "../../fixtures/oauth_clients";
import OAuthClientAttributeSets from "../../fixtures/onboarding/oAuthClientAttributeSets";
import { context } from "../app";
import config from "../../../../src/mm.config.json";

Given(
  "the Onboarding GET Attribute Sets {string} for OAuthClient {string} for Service Provider {string} request has been intercepted",
  (
    attributeSetFixtureId: string,
    OAuthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId = Oauth_clients[OAuthClientFixtureId].id;
    const attributeSets = OAuthClientAttributeSets[attributeSetFixtureId];
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeSets,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding PUT Organization Attribute Set {string} OAuthClient {string} for Service Provider {string} request has been intercepted",
  (
    attributeSetFixtureId: string,
    OAuthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId = Oauth_clients[OAuthClientFixtureId].id;
    const attributeSets = OAuthClientAttributeSets[attributeSetFixtureId];
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/organization_attribute_set`;
    cy.intercept("PUT", url, {
      statusCode: 200,
      body: attributeSets,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding PUT User Attribute Set {string} OAuthClient {string} for Service Provider {string} request has been intercepted",
  (
    attributeSetFixtureId: string,
    OAuthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId = Oauth_clients[OAuthClientFixtureId].id;
    const attributeSets = OAuthClientAttributeSets[attributeSetFixtureId];
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/user_attribute_set`;
    cy.intercept("PUT", url, {
      statusCode: 200,
      body: attributeSets,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding DELETE User Attribute Set from OAuthClient {string} for Service Provider {string} request has been intercepted",
  (OAuthClientFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId = Oauth_clients[OAuthClientFixtureId].id;
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/user_attribute_set`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding DELETE Organization Attribute Set from OAuthClient {string} for Service Provider {string} request has been intercepted",
  (OAuthClientFixtureId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId = Oauth_clients[OAuthClientFixtureId].id;
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/organization_attribute_set`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);
