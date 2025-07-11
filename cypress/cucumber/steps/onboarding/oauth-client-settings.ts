import { Given } from "cypress-cucumber-preprocessor/steps";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import serviceProviders from "../../fixtures/service_providers";
import OAuthClientSettings from "../../fixtures/onboarding/OAuthClientSettings";

Given(
  "the Onboarding OauthClient Settings {string} request for Service Provider {string} has been intercepted",
  (OAuthClientId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/global-oauth-client-settings`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: OAuthClientSettings[OAuthClientId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding OauthClient Settings {string} request for Service Provider {string} has been intercepted to update the settings",
  (OAuthClientId: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    cy.intercept(
      "PUT",
      `${config.onboarding.url}/service-providers/${serviceProviderId}/global-oauth-client-settings`,
      {
        statusCode: 200,
        body: OAuthClientSettings[OAuthClientId],
      },
    );
  },
);
