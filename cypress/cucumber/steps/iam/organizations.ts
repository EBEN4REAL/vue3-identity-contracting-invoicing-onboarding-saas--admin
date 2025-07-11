import { Given } from "cypress-cucumber-preprocessor/steps";
import organizations, { Organization } from "../../fixtures/organizations";
import config from "../../../../src/mm.config.json";
import { orgUsers } from "../../fixtures/service-provider/organizations";
import serviceProviders from "../../fixtures/service_providers";

Given(
  "the IAM Organization request has been intercepted to return the Organization {string}",
  (organizationId: string): void => {
    const organization: Organization = organizations[organizationId];
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/organizations/${organization.id}`,
      {
        statusCode: 200,
        body: organization,
      },
    );
  },
);

Given(
  "the IAM Organization request has been intercepted to return the Organization with id {string} for filter {string} and with user id {string}",
  (
    organization_id: string,
    filterId: string,
    organization_user_id: string,
  ): void => {
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/organizations/${organization_id}/users?organization_user_id=${organization_user_id}`,
      {
        statusCode: 200,
        body: orgUsers[filterId],
      },
    );
  },
);

Given(
  "the IAM Organization request has been intercepted to register as a SP the Organization {string}",
  (organizationId: string): void => {
    cy.intercept(
      "POST",
      `${config.iam.url}/iam/organizations/${organizationId}/service-providers`,
      {
        statusCode: 200,
        body: serviceProviders,
      },
    );
  },
);
