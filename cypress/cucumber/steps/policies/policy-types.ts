import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import config from "../../../../src/mm.config.json";
import { PolicyTypeRead } from "../../../../src/policies/policies.types";
import { PolicyCategoryReadLimited } from "../../../../src/service-providers/ConfigurationTabs/Policies/policies.types";
import {
  policies,
  policyUx,
  policyUxCategories,
} from "../../fixtures/service-provider/policies";
import { policyTypes } from "../../fixtures/service-provider/policy-types";
import { context } from "../app";
import { TableResponse } from "../../../../src/mm_ui_kit/src/types/table.types";
import { policyServiceProviders } from "../../fixtures/policies";

Given(
  "the Policies Policy Types request has been intercepted to return the Policy Types {string} for Service Provider {string}",
  (policyTypesFixtureIds: string, serviceProviderFixtureId: string): void => {
    const policyTypes = policies[policyTypesFixtureIds];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];

    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProvider.id}/policy-types?*`,
      {
        statusCode: 200,
        body: policyTypes,
      },
    );
  },
);

Given(
  "the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category {string}",
  (policyUxCategoryId: string): void => {
    const policyUxCategory: PolicyCategoryReadLimited =
      policyUxCategories[policyUxCategoryId];

    const url = `${config.policies.url}/policy-type-categories/${policyUxCategory.id}/ux`;

    cy.intercept("GET", url, {
      statusCode: 200,
      body: policyUx,
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories",
  (): void => {
    const url: string = `${config.policies.url}/policy-type-categories`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: Object.values(policyUxCategories),
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies request has been intercepted to return the Policies {string} for Service Provider {string}",
  (policyId: string, serviceProviderId: string): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/policy-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policies[policyId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies request has been intercepted to return the Policies {string} for Service Provider {string} for Autocomplete",
  (policyId: string, serviceProviderId: string): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/policy-types?limit=50&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policies[policyId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policy Types request has been intercepted to return Policy Types {string} for Service Provider {string}",
  (policyTypesFixtureIds: string, serviceProviderFixtureId: string): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const policyTypesFixtureIdsArr: string[] = policyTypesFixtureIds.split(",");
    const policyTypesPaginated: TableResponse<PolicyTypeRead> = {
      offset: 0,
      limit: 10,
      results: policyTypesFixtureIdsArr.map(
        (policyTypeId: string) => policyTypes[policyTypeId],
      ),
      size: 3,
      total: 3,
    };
    cy.intercept(
      "GET",
      `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types*`,
      {
        statusCode: 200,
        body: policyTypesPaginated,
      },
    );
  },
);

Given(
  "the Create Policy request has been intercepted to return the Policy {string} for Service Provider {string}",
  (policyId: string, serviceProviderId: string): void => {
    const url = `${config.configuration.url}/service-providers/${serviceProviderId}/policy-types`;
    cy.intercept("POST", url, {
      statusCode: 201,
      body: policyTypes[policyId],
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Update Policy request has been intercepted to return the Policy {string} for Service Provider {string}",
  (policyFixtureId: string, serviceProviderFixtureId: string): void => {
    const url = `${config.configuration.url}/service-providers/${serviceProviders[serviceProviderFixtureId].id}/policy-types/${policyTypes[policyFixtureId].id}`;
    cy.intercept("PATCH", url, {
      statusCode: 200,
      body: policyTypes[policyFixtureId],
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Policy request has been intercepted to return the PolicyType {string} for Service Provider {string}",
  (policyTypeId: string, serviceProviderId: string): void => {
    const serviceProvider = serviceProviders[serviceProviderId];
    const policyType = policyTypes[policyTypeId];
    cy.intercept(
      "GET",
      `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}`,
      {
        statusCode: 200,
        body: policyType,
      },
    );
  },
);

Given(
  "the Policy request has been intercepted to return no PolicyTypes for Service Provider {string}",
  (serviceProviderId: string): void => {
    const serviceProvider = serviceProviders[serviceProviderId];
    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProvider.id}/policy-types`,
      {
        statusCode: 200,
        body: [],
      },
    );
  },
);

Given(
  "the Policy request has been intercepted to return PolicyTypes paginated {string} for Service Provider {string}",
  (policyTypesIds: string, serviceProviderId: string): void => {
    const serviceProvider = serviceProviders[serviceProviderId];
    const policyTypesIdsArr: string[] = policyTypesIds.split(",");
    const policyTypesPaginated: TableResponse<PolicyTypeRead> = {
      offset: 0,
      limit: 10,
      results: policyTypesIdsArr.map(
        (policyTypeId: string) => policyTypes[policyTypeId],
      ),
      size: policyTypesIdsArr.length,
      total: policyTypesIdsArr.length,
    };
    const url: string = `${config.policies.url}/service-providers/${serviceProvider.id}/policy-types*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policyTypesPaginated,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Update Policy request has been intercepted to update the PolicyType {string} for Service Provider {string}",
  (policyTypeId: string, serviceProviderId: string): void => {
    const serviceProvider = serviceProviders[serviceProviderId];
    const policyType = policyTypes[policyTypeId];
    cy.intercept(
      "PATCH",
      `${config.policies.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}`,
      {
        statusCode: 200,
        body: policyType,
      },
    );
  },
);

Given(
  "the Policies POST request to add Child Policy Types to Policy {string} with Child Policy {string} and Service provider {string} has been intercepted",
  (
    policyTypeFixtureId: string,
    childPolicyFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider = serviceProviders[serviceProviderFixtureId];
    const policyType = policyTypes[policyTypeFixtureId];
    const childPolicyType = policyTypes[childPolicyFixtureId];
    const url = `/service-providers/${serviceProvider.id}/policy-types/${policyType.id}/child-policy-types`;
    const payload = {
      child_policy_type_id: childPolicyType.id,
    };
    cy.intercept("POST", url, {
      statusCode: 200,
      body: payload,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Configuration Policy Types PUT request to add Child Policy Types to Policy Type {string} with Child Policy Types {string} and Service Provider {string} has been intercepted",
  (
    policyTypeFixtureId: string,
    childPolicyFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider = serviceProviders[serviceProviderFixtureId];
    const policyType = policyTypes[policyTypeFixtureId];
    const childPolicyType = policyTypes[childPolicyFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}/child-policy-types`;
    const payload = {
      child_policy_type_id: childPolicyType.id,
    };
    cy.intercept("PUT", url, {
      statusCode: 200,
      body: payload,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies DELETE request to remove Child Policy Types from Policy {string} with Child Policy {string} and Service provider {string} has been intercepted",
  (
    policyTypeFixtureId: string,
    childPolicyFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider = serviceProviders[serviceProviderFixtureId];
    const policyType = policyTypes[policyTypeFixtureId];
    const childPolicyType = policyTypes[childPolicyFixtureId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}/child-policy-types/${childPolicyType.id}`;
    cy.intercept("DELETE", url, {
      statusCode: 204,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Delete Policy {string} for Service Provider {string} request has been intercepted",
  (policyTypeId: string, serviceProviderId: string): void => {
    const serviceProvider = serviceProviders[serviceProviderId];
    const policyType = policyTypes[policyTypeId];
    const url = `${config.configuration.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}`;
    cy.intercept("DELETE", url, {
      statusCode: 200,
      body: "deleted",
    }).as(url);

    context.aliases.push(url);
  },
);

Given(
  "the Policies Policy Types request has been intercepted to return the Policy Types {string} excluded OAuth {string} for Service Provider {string}",
  (
    policyTypesFixtureIds: string,
    oauthClientId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const policyTypes = policies[policyTypesFixtureIds];
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const appId = policyServiceProviders[oauthClientId].oauth_client_id;
    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProvider.id}/policy-types?exclude_assigned_to_oauth_client=${appId}*`,
      {
        statusCode: 200,
        body: policyTypes,
      },
    );
  },
);
