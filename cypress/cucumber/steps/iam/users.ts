import { Given } from "cypress-cucumber-preprocessor/steps";
import users, { User } from "../../fixtures/users";
import config from "../../../../src/mm.config.json";

Given(
  "the IAM User @me request has been intercepted to return the User {string}",
  (userId: string): void => {
    const user: User = users[userId];
    cy.intercept("GET", `${config.iam.url}/iam/users/@me`, {
      statusCode: 200,
      body: user,
    }).as("iamUserRead");
  },
);
