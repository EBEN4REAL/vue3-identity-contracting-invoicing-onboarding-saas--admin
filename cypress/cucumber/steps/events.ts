import config from "../../../src/mm.config.json";
import { Given } from "cypress-cucumber-preprocessor/steps";
import { events } from "../fixtures/event_log";
import serviceProviders, {
  ServiceProvider,
} from "../fixtures/service_providers";
import { PaginationSchema_EventRead_ } from "../../../src/events/events.types";
import { context } from "./app";
import { agreementMetricsFixtures } from "../fixtures/agreement_metrics";

Given(
  "the Events request has been intercepted to return the Events {string} for Service Provider {string}",
  (eventIds: string, serviceProviderId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderId];
    const eventIdsArr: string[] = eventIds.split(",");
    const eventsPagination: PaginationSchema_EventRead_ = {
      offset: 0,
      limit: 10,
      results: eventIdsArr.map((eventId: string) => events[eventId]),
      size: eventIdsArr.length > 10 ? 10 : eventIdsArr.length,
      total: eventIdsArr.length,
    };
    const url: string = `${config.events.url}/events?service_provider_id=${serviceProvider.id}*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: eventsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Events request has been intercepted to return the Events {string} for Service Provider {string} with query params {string}",
  (eventIds: string, serviceProviderId: string, queryParams: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderId];
    const eventIdsArr: string[] = eventIds.split(",");
    const eventsData = eventIdsArr.map((eventId: string) => events[eventId]);

    const sortTimestampDescending = queryParams.includes("sort=timestamp:desc");
    const sortTypeAscending = queryParams.includes("sort=type:asc");

    /** Sorting logic */
    if (sortTimestampDescending) {
      eventsData.sort((a, b) => {
        const timestampA = new Date(a.timestamp).getTime();
        const timestampB = new Date(b.timestamp).getTime();
        return timestampB - timestampA;
      });
    } else if (sortTypeAscending) {
      eventsData.sort((a, b) => {
        if (a.type < b.type) return -1;
        if (a.type > b.type) return 1;
        return 0;
      });
    }

    const eventsPagination: PaginationSchema_EventRead_ = {
      offset: 0,
      limit: 10,
      results: eventsData.slice(0, 10),
      size: eventsData.length > 10 ? 10 : eventsData.length,
      total: eventsData.length,
    };

    const url: string = `${config.events.url}/events?service_provider_id=${serviceProvider.id}${queryParams}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: eventsPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the User waits for the event log to be populated with query params {string}",
  (queryParams: string) => {
    cy.wait(`@getEventLog-${queryParams}`);
  },
);

Given("the User waits for the event log to be populated", () => {
  cy.wait("@getEventLog");
});

Given(
  "the Events request has been intercepted to return the Agreement Metrics {string} for Service Provider {string}",
  (
    agreementMetricsFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const agreementMetrics =
      agreementMetricsFixtures[agreementMetricsFixtureId];
    const url: string = `${config.events.url}/service-providers/${serviceProvider.id}/agreements-metrics`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: agreementMetrics,
    }).as(url);
    context.aliases.push(url);
  },
);
