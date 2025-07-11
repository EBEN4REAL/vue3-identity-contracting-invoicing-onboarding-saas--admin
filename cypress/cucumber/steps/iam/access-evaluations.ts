import { Given } from "cypress-cucumber-preprocessor/steps";
import config from "../../../../src/mm.config.json";
import {
  accessEvaluationDetails,
  accessEvaluations,
} from "../../fixtures/access_evaluations";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import { context } from "../app";

Given(
  "the IAM Access Evaluations request has been intercepted to return Access Logs {string} for Service Provider {string}",
  (auditEventId: string, serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.iam.url}/iam/access-evaluations?service_provider_id=${serviceProvider.id}*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: accessEvaluations[auditEventId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Access Evaluations request has been intercepted to return Access Log Details {string} for Service Provider {string}",
  (
    accessEvaluationDetailsFixtureId: string,
    serviceProviderFixtureId: string,
  ): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.iam.url}/iam/service_providers/${serviceProvider.id}/access-evaluations/${accessEvaluationDetails[accessEvaluationDetailsFixtureId].id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: accessEvaluationDetails[accessEvaluationDetailsFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
