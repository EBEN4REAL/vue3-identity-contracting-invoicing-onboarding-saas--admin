import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import {
  OauthClientRead,
  PaginationSchema_OauthClientRead_,
} from "../../../../src/configuration/configuration.types";
import oauthClients from "../../fixtures/oauth_clients";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import { clientSecret } from "../../fixtures/service-provider/client-secrets";

Given(
  "the Configuration GET OAuth Client request has been intercepted to return the Oauth Client {string} for Service Provider {string}",
  (
    oauthClientProviderFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const oauthClient: OauthClientRead =
      oauthClients[oauthClientProviderFixtureId];
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.configuration.url}/service-providers/${serviceProviderId}/oauth-clients/${oauthClient.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: oauthClient,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients {string} for Service Provider {string}",
  (oauthClientIds: string, serviceProviderId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderId];
    const oauthClientIdsArr: string[] = oauthClientIds.split(",");
    const results: OauthClientRead[] = oauthClientIdsArr.map(
      (oauthClientId: string) => oauthClients[oauthClientId],
    );
    const oauthClientsPagination: PaginationSchema_OauthClientRead_ = {
      offset: 0,
      limit: 10,
      results,
      size: oauthClientIdsArr.length > 10 ? 10 : oauthClientIdsArr.length,
      total: oauthClientIdsArr.length,
    };
    const url: string = `${config.configuration.url}/service-providers/${serviceProvider.id}/oauth-clients?*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: oauthClientsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration POST OAuth Client Secret request has been intercepted to create and return the Secret {string} for OAuth Client {string} and Service Provider {string}",
  (
    clientSecretFixtureId: string,
    oauthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId: string = oauthClients[oauthClientFixtureId].id;
    cy.intercept(
      "POST",
      `${config.configuration.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/secrets`,
      {
        statusCode: 201,
        body: clientSecret[clientSecretFixtureId],
      },
    );
  },
);

Given(
  "the Configuration POST OAuth Clients request has been intercepted to create and return the OAuth Client {string} for Service Provider {string}",
  (
    oauthClientProviderFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const oauthClient: OauthClientRead =
      oauthClients[oauthClientProviderFixtureId];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];

    cy.intercept(
      "POST",
      `${config.configuration.url}/service-providers/${serviceProvider.id}/oauth-clients`,
      {
        statusCode: 201,
        body: oauthClient,
      },
    );
  },
);

Given(
  "the Configuration PATCH OAuth Client request has been intercepted to update the Oauth Client {string} for Service Provider {string} and return {string}",
  (
    oauthClientProviderFixtureId: string,
    serviceProviderFixtureId: string,
    updatedClientProviderFixtureId: string,
  ): void => {
    const oauthClient: OauthClientRead =
      oauthClients[oauthClientProviderFixtureId];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const updatedOauthClient: OauthClientRead =
      oauthClients[updatedClientProviderFixtureId];
    cy.intercept(
      "PATCH",
      `${config.configuration.url}/service-providers/${serviceProvider.id}/oauth-clients/${oauthClient.id}`,
      {
        statusCode: 200,
        body: updatedOauthClient,
      },
    );
  },
);

Given(
  "the Configuration DELETE OAuth Client request has been intercepted to delete the Oauth Client {string} for Service Provider {string}",
  (
    oauthClientProviderFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const oauthClient: OauthClientRead =
      oauthClients[oauthClientProviderFixtureId];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    cy.intercept(
      "DELETE",
      `${config.configuration.url}/service-providers/${serviceProvider.id}/oauth-clients/${oauthClient.id}`,
      {
        statusCode: 204,
      },
    );
  },
);

Given(
  "the Configuration DELETE OAuth Client Secret request has been intercepted to delete the Secret {string} for OAuth Client {string} and Service Provider {string}",
  (
    clientSecretFixtureId: string,
    oauthClientFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const clientSecretId: string = clientSecret[clientSecretFixtureId].id;
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const oAuthClientId: string = oauthClients[oauthClientFixtureId].id;
    const url = `${config.configuration.url}/service-providers/${serviceProviderId}/oauth-clients/${oAuthClientId}/secrets/${clientSecretId}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);

    context.aliases.push(url);
  },
);
