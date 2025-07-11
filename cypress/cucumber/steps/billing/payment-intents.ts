import { Given } from "cypress-cucumber-preprocessor/steps";
import config from "../../../../src/mm.config.json";
import { context } from "../app";
import { charges } from "../../fixtures/service-provider/charges";
import { PaymentIntentRead } from "../../../../src/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { TableResponse } from "../../../../../mm_ui_kit/src/types/table.types";

Given(
  "the billing request has been intercepted to return the charges for Service Provider {string}",
  (serviceProviderId: string): void => {
    const chagesPagination: TableResponse<PaymentIntentRead> = {
      offset: 0,
      limit: 10,
      results: Object.values(charges),
      size: Object.values(charges).length,
      total: Object.values(charges).length,
    };
    const url: string = `${config.billing_and_invoicing.url}/service-providers/${serviceProviderId}/payment-intents?limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: chagesPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the billing request has been intercepted to return the charges for Service Consumer {string}",
  (service_consumer_id: string): void => {
    const chagesPagination: TableResponse<PaymentIntentRead> = {
      offset: 0,
      limit: 10,
      results: Object.values(charges),
      size: Object.values(charges).length,
      total: Object.values(charges).length,
    };
    const url: string = `${config.billing_and_invoicing.url}/service-consumers/${service_consumer_id}/payment-intents?limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: chagesPagination,
    }).as(url);
    context.aliases.push(url);
  },
);
