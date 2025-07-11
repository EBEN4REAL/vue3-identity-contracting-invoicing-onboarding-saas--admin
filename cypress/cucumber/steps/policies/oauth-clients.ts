import config from "../../../../src/mm.config.json";
import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders from "../../fixtures/service_providers";
import oauthClients from "../../fixtures/oauth_clients";
import {
  policiesServiceProviders,
  policiesServiceProvidersUpdate,
  policyServiceProviders,
} from "../../fixtures/policies";

Given(
  "the Policies for OAuth Client request has been intercepted to return policies {string} for OAuth Client {string} for Service Provider {string}",
  (
    policiesFixtureId: string,
    oauthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId: string = oauthClients[oauthClientFixtureId].id;
    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/policies*`,
      {
        statusCode: 200,
        body: policiesServiceProviders[policiesFixtureId],
      },
    );
  },
);

Given(
  "the Policies for OAuth Client request has been intercepted to update Policies {string} for Service Provider {string}",
  (
    policiesPayloadFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    cy.intercept(
      "PUT",
      `${config.policies.url}/service-providers/${serviceProviderId}/oauth-clients/policies*`,
      {
        statusCode: 200,
        body: policiesServiceProvidersUpdate[policiesPayloadFixtureId],
      },
    );
  },
);

Given(
  "the Policies for OAuth Client request has been intercepted to add Policies {string} for Service Provider {string} and OAuthClient {string}",
  (
    policiesPayloadFixtureId: string,
    serviceProviderFixtureId: string,
    oauthClientId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const appId: string = policyServiceProviders[oauthClientId].oauth_client_id;
    cy.intercept(
      "POST",
      `${config.policies.url}/service-providers/${serviceProviderId}/oauth-clients/${appId}/policies`,
      {
        statusCode: 200,
        body: policiesServiceProvidersUpdate[policiesPayloadFixtureId],
      },
    );
  },
);

Given(
  "the Policies for OAuth Client request has been intercepted to unassign Policy {string} from OAuth Client {string} from Service Provider {string}",
  (
    policyFixtureId: string,
    oauthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId: string = oauthClients[oauthClientFixtureId].id;
    const policyId: string = policyServiceProviders[policyFixtureId].policy_id;
    cy.intercept(
      "DELETE",
      `${config.policies.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/policies/${policyId}`,
      {
        statusCode: 204,
      },
    );
  },
);
