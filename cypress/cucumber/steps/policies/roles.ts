import { Given } from "cypress-cucumber-preprocessor/steps";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import serviceProviders from "../../fixtures/service_providers";
import { policyTypeRoleByRoleId, roleUsages } from "../../fixtures/roles";

Given(
  "the Role Usages {string} for Role {string} for Service Provider {string} request has been intercepted",
  (
    roleUsagesFixtureId: string,
    roleFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/roles/${policyTypeRoleByRoleId[roleFixtureId].id}/usage`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: roleUsages[roleUsagesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
