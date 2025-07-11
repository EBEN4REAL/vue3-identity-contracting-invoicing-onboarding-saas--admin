import { Before, Given, Then, When } from "cypress-cucumber-preprocessor/steps";
import config from "../../../src/mm.config.json";

export enum Mode {
  CI = "ci",
}

export const getMode = (): string => Cypress.env("MODE") || "";

export const cypressIdElementSelector = (cypressId: string): string =>
  `[data-cy=${cypressId}]`;

export const getTheLastElementByCypressID = (elementSelector: string) => {
  const formattedSelector = elementSelector
    .split(" ")
    .map((selector: string) => cypressIdElementSelector(selector))
    .join(" ");
  return cy.get(formattedSelector).each(($el, index, $list) => {
    cy.get($el).should("exist"); // Ensure each element in the chain exists
    if (index === $list.length - 1) {
      return cy.wrap($el);
    }
  });
};

type Context = {
  aliases: [string?];
};

export const context: Context = {
  aliases: [],
};

Before((): void => {
  context.aliases = [];
});

Given("the User navigates to {string}", (url): void => {
  cy.visit(url);
});

Then("the User should be redirected to {string}", (url): void => {
  cy.url().should("include", url).should("not.include", `=${url}`);
  if (url !== "/") {
    cy.url().should("not.include", `${url}/`);
  }
});

Then(
  "the User should be redirected to the SC App {string}",
  (url: string): void => {
    cy.url().should("include", `${config.scApp.url}${url}`);
  },
);

When(
  "the User types {string} in the Element with Cypress ID {string}",
  (value: string, cypressId: string): void => {
    cy.getByCypressID(cypressId).find("input").clear().type(value);
  },
);

const theUserClicksOnTheElementWithSelector = (
  elementSelector: string,
): void => {
  cy.get(elementSelector).first().click({ scrollBehavior: "center" });
};

When(
  "the User clicks on the Element with selector {string}",
  (elementSelector: string): void => {
    theUserClicksOnTheElementWithSelector(elementSelector);
  },
);

When(
  "the User clicks on the Element with Cypress ID {string}",
  (cypressId: string): void => {
    cy.getByCypressID(cypressId).click();
  },
);

When(
  "the User force clicks on the Element with Cypress ID {string}",
  (cypressId: string): void => {
    cy.getByCypressID(cypressId).click({ force: true });
  },
);

Given(
  "the User selects option with Cypress ID {string} in the Select with Cypress ID {string}",
  (optionCypressID: string, selectCypressID: string): void => {
    cy.getByCypressID(`${selectCypressID} mm-select-wrapper`).click({
      force: true,
    });
    cy.getByCypressID(`${selectCypressID} ${optionCypressID}`).click({
      force: true,
    });
  },
);

Given("the intercepted requests have resolved", (): void => {
  if (context.aliases.length === 0) {
    return;
  }
  cy.wait(context.aliases.map((alias: string): string => `@${alias}`));
  context.aliases = [];
});

Given("the User is using an {string} device", (deviceName: string): void => {
  cy.viewport(deviceName);
});
