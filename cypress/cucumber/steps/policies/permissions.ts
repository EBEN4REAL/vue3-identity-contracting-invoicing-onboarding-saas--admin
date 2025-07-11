import { Given } from "cypress-cucumber-preprocessor/steps";
import { context } from "../app";
import config from "../../../../src/mm.config.json";
import serviceProviders from "../../fixtures/service_providers";
import {
  permissionUsages,
  policyTypePermissionByPermissionId,
} from "../../fixtures/permissions";

Given(
  "the Permission Usages {string} for Permission {string} for Service Provider {string} request has been intercepted",
  (
    permissionUsagesFixtureId: string,
    permissionFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/entitlements/${policyTypePermissionByPermissionId[permissionFixtureId].id}/usage`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: permissionUsages[permissionUsagesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
