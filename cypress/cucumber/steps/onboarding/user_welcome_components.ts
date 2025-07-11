import { Given, Then } from "cypress-cucumber-preprocessor/steps";
import {
  onboardingWelcomeSteps,
  userWelcomeComponents,
} from "../../fixtures/onboarding/user-welcome-components";
import config from "../../../../src/mm.config.json";
import { context } from "../app";

Given(
  "the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id {string} for {string} app",
  (onboardingStepFixtureId: string, app: string): void => {
    const url: string = `${config.onboarding.url}/welcome/${app}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: onboardingWelcomeSteps[onboardingStepFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding Welcome Components POST request has been intercepted to update progress for Onboarding Step and User Welcome Component with FixtureId {string} for {string} app",
  (userWelcomeComponentFixtureId: string, app: string): void => {
    const componentName =
      userWelcomeComponents[userWelcomeComponentFixtureId].name;

    cy.intercept(
      "POST",
      `${config.onboarding.url}/welcome/${app}/${componentName}`,
      {
        statusCode: 200,
      },
    ).as("updateWelcomeComponentProgress");
  },
);

Given(
  "the Onboarding Welcome Components DELETE request has been intercepted to update progress for Onboarding Step and User Welcome Component with FixtureId {string} for {string} app",
  (userWelcomeComponentFixtureId: string, app: string): void => {
    const componentName =
      userWelcomeComponents[userWelcomeComponentFixtureId].name;

    cy.intercept(
      "DELETE",
      `${config.onboarding.url}/welcome/${app}/${componentName}`,
      {
        statusCode: 200,
      },
    ).as("updateWelcomeComponentProgressUncompleted");
  },
);

Given(
  "the Onboarding Welcome Components GET request has been intercepted to retrieve User updated Onboarding Welcome Components with Fixture Id {string} for {string} app",
  (onboardingStepFixtureId: string, app: string): void => {
    cy.intercept("GET", `${config.onboarding.url}/welcome/${app}`, {
      statusCode: 200,
      body: onboardingWelcomeSteps[onboardingStepFixtureId],
    }).as("getOnboardingWelcomeComponentsUpdated");
  },
);

Then(
  "the Onboarding User Welcome Components DELETE request has been completed",
  (): void => {
    cy.wait("@updateWelcomeComponentProgressUncompleted");
  },
);

Then(
  "the Onboarding User Welcome Components POST request has been completed",
  (): void => {
    cy.wait("@updateWelcomeComponentProgress");
  },
);

Then(
  "the updated Onboarding Welcome Components GET request has been completed",
  (): void => {
    cy.wait("@getOnboardingWelcomeComponentsUpdated");
  },
);
