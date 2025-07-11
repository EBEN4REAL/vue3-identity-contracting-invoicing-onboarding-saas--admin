import config from "../../../../src/mm.config.json";
import { Given } from "cypress-cucumber-preprocessor/steps";
import {
  allPolicies,
  policies,
} from "../../fixtures/service-provider/policies";
import {
  orgUsers,
  orgUsersPolicies,
} from "../../fixtures/service-provider/organizations";
import { context } from "../app";
import serviceProviders from "../../fixtures/service_providers";
import { policyTypes } from "../../fixtures/service-provider/policy-types";
import { policyTypeUsages } from "../../fixtures/service-provider/policy-type-usage";
import { AllPolicyRead } from "../../../../src/service-providers/Policies/policies.types";

Given(
  "the Policies request has been intercepted to return the All Policies {string} for Service Provider {string}",
  (filterId: string, serviceProviderId: string): void => {
    const policiesIdsArr: string[] = filterId.split(",");
    const policiesPagination: AllPolicyRead = {
      offset: 0,
      limit: 10,
      results: policiesIdsArr.map((policy: string) => allPolicies[policy]),
      size: policiesIdsArr.length > 10 ? 10 : policiesIdsArr.length,
      total: policiesIdsArr.length,
    };
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/policies/external/all*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policiesPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies request has been intercepted to return the All Policies {string} for Service Provider {string} with query params {string}",
  (filterId: string, serviceProviderId: string, queryParams: string): void => {
    const policiesIdsArr: string[] = filterId.split(",");
    const policiesPagination: AllPolicyRead = {
      offset: 0,
      limit: 10,
      results: policiesIdsArr.map((policy: string) => allPolicies[policy]),
      size: policiesIdsArr.length > 10 ? 10 : policiesIdsArr.length,
      total: policiesIdsArr.length,
    };
    const interceptUrl = `${config.policies.url}/service-providers/${serviceProviderId}/policies/external/all?${queryParams}`;

    cy.intercept("GET", interceptUrl, {
      statusCode: 200,
      body: policiesPagination,
    });
  },
);

Given(
  "the Policies request has been intercepted to return the Organization with Service Provider {string} for filter {string} and with org id {string}",
  (
    serviceProviderId: string,
    policyTypeId: string,
    organization_id: string,
  ): void => {
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/policies/external/organizations?organization_id=${organization_id}&limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 201,
      body: orgUsersPolicies[policyTypeId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Policies request has been intercepted to assign Policy {string} for Service Provider {string}",
  (policyTypeId: string, serviceProviderId: string) => {
    cy.intercept(
      "POST",
      `${config.policies.url}/service-providers/${serviceProviderId}/policies/assign/organization_user`,
      {
        statusCode: 201,
        body: policies[policyTypeId],
      },
    );
  },
);

Given(
  "the Policies request has been intercepted to unassign Policy {string} from Org User for Service Provider {string}",
  (policyTypeId: string, serviceProviderId: string) => {
    cy.intercept(
      "POST",
      `${config.policies.url}/service-providers/${serviceProviderId}/policies/unassign/organization_user`,
      {
        statusCode: 200,
        body: policies[policyTypeId],
      },
    );
  },
);

Given(
  "the Policies request has been intercepted to unassign Policy {string} from Organization for Service Provider {string}",
  (policyTypeId: string, serviceProviderId: string) => {
    cy.intercept(
      "POST",
      `${config.policies.url}/service-providers/${serviceProviderId}/policies/unassign/organization`,
      {
        statusCode: 200,
        body: policies[policyTypeId],
      },
    );
  },
);

Given(
  "the Policies Usage request has been intercepted to return the Usage {string} for Policy {string} and Service Provider {string}",
  (usageId: string, policyTypeId: string, serviceProviderId: string): void => {
    const serviceProvider = serviceProviders[serviceProviderId];
    const policyType = policyTypes[policyTypeId];
    cy.intercept(
      "GET",
      `${config.policies.url}/service-providers/${serviceProvider.id}/policy-types/${policyType.id}/usage`,
      {
        statusCode: 200,
        body: policyTypeUsages[usageId],
      },
    );
  },
);

Given(
  "the Policies request has been intercepted to return the Policies {string} for Service Provider {string} and Organization User {string}",
  (policiesId: string, serviceProviderId: string, orgUser: string): void => {
    const orgUserId = orgUsers[orgUser].results[0].organization.id;
    const url: string = `${config.policies.url}/service-providers/${serviceProviderId}/policies/external/organization-users?organization_user_id=${orgUserId}&limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: policies[policiesId],
    }).as(url);
    context.aliases.push(url);
  },
);
