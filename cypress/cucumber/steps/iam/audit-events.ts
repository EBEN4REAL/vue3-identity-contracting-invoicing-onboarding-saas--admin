import { Given } from "cypress-cucumber-preprocessor/steps";
import { auditEvents } from "../../fixtures/audit_log";
import config from "../../../../src/mm.config.json";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import { context } from "../app";

Given(
  "the IAM Audit Events request has been intercepted to return the Audit Events {string} for Service Provider {string}",
  (auditEventIds: string, serviceProviderId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderId];
    const auditEventIdsArr = auditEventIds.split(",");
    const auditEventsPagination = {
      offset: 0,
      limit: 10,
      results: auditEventIdsArr.map(
        (auditEventId: string) => auditEvents[auditEventId],
      ),
      size: auditEventIdsArr.length > 10 ? 10 : auditEventIdsArr.length,
      total: auditEventIdsArr.length,
    };
    const url: string = `${config.events.url}/audit-events?service_provider_id=${serviceProvider.id}&limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: auditEventsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);
