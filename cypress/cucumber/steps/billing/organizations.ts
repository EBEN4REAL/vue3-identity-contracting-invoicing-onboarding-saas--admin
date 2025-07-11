import { BillingAddressRead } from "../../../../src/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { Given } from "cypress-cucumber-preprocessor/steps";
import config from "../../../../src/mm.config.json";
import billing_addresses from "../../fixtures/billing/billing_addresses";

Given(
  "the Billing and Invoicing request has been intercepted to return the billing address {string} from Organization {string}",
  (billingId: string, organizationId: string): void => {
    const billingAddress: BillingAddressRead = billing_addresses[billingId];
    cy.intercept(
      "GET",
      `${config.billing_and_invoicing.url}/service-consumers/${organizationId}/billing-address`,
      {
        statusCode: 200,
        body: {
          results: [billingAddress],
          total: 1,
          offset: 0,
          limit: 10,
          size: 1,
        },
      },
    );
  },
);
