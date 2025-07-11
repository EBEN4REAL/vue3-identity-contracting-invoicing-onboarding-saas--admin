import { Given } from "cypress-cucumber-preprocessor/steps";
import config from "../../../../src/mm.config.json";
import { invoices } from "../../fixtures/service-provider/invoices";

Given(
  "the Billing and Invoicing request has been intercepted to return the Invoices {string} for Service Provider {string}",
  (invoice_id: string, serviceProviderId: string): void => {
    const url: string = `${config.billing_and_invoicing.url}/service-providers/${serviceProviderId}/invoices?limit=10&offset=0*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results: [invoices[invoice_id]],
        size: 10,
        total: 1,
      },
    }).as(url);
  },
);

Given(
  "the Billing and Invoicing request has been intercepted to return the Invoices {string} for Service Consumer {string}",
  (invoice_id: string, serviceConsumerId: string): void => {
    const url: string = `${config.billing_and_invoicing.url}/service-consumers/${serviceConsumerId}/invoices?limit=10&offset=0&sort=invoice.date`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: {
        offset: 0,
        limit: 10,
        results: [invoices[invoice_id]],
        size: 10,
        total: 1,
      },
    }).as(url);
  },
);
