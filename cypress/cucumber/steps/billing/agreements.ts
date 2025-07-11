import { Given } from "cypress-cucumber-preprocessor/steps";
import { agreements } from "../../fixtures/service-provider/agreements";
import { context } from "../app";
import serviceProviders from "../../fixtures/service_providers";
import config from "../../../../src/mm.config.json";

Given(
  "the billing request has been intercepted to return the agreement with id {string} for Service Provider {string}",
  (agreementId: string, serviceProviderId: string): void => {
    const url: string = `${config.billing_and_invoicing.url}/service-providers/${serviceProviderId}/agreements/${agreements[agreementId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: agreements[agreementId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the billing request has been intercepted to return the charges for the Agreement {string} of Service Provider {string}",
  (agreement_id: string, service_provider_id: string): void => {
    const agreement = agreements[agreement_id];
    const serviceProvider = serviceProviders[service_provider_id];
    const url: string = `${config.billing_and_invoicing.url}/service-providers/${serviceProvider.id}/agreements/${agreement.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: agreement,
    }).as(url);
    context.aliases.push(url);
  },
);
