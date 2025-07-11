import { Given } from "cypress-cucumber-preprocessor/steps";
import { extended_agreement_types } from "../../fixtures/service-provider/pricing";
import config from "../../../../src/mm.config.json";

Given(
  "the Billing and Invoicing request has been intercepted to return the Agreement Type {string} for Service Provider {string}",
  (agreement_type_fixture_id: string, serviceProviderId: string): void => {
    const agreement_type_id: string =
      extended_agreement_types[agreement_type_fixture_id].id;
    const url: string = `${config.billing_and_invoicing.url}/service-providers/${serviceProviderId}/agreement-types/${agreement_type_id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: extended_agreement_types[agreement_type_fixture_id],
    }).as(url);
  },
);

Given(
  "the Billing and Invoicing request has been intercepted to update and return the Agreement Type {string} for Service Provider {string}",
  (agreement_type_fixture_id: string, serviceProviderId: string): void => {
    const agreement_type_id =
      extended_agreement_types[agreement_type_fixture_id].id;
    const url: string = `${config.billing_and_invoicing.url}/service-providers/${serviceProviderId}/agreement-types/${agreement_type_id}`;
    cy.intercept("PATCH", url, {
      statusCode: 200,
      body: extended_agreement_types[agreement_type_fixture_id],
    }).as(url);
  },
);
