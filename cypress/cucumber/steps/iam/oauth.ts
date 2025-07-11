import { Given, Then } from "cypress-cucumber-preprocessor/steps";
import { CyHttpMessages } from "cypress/types/net-stubbing";
import config from "../../../../src/mm.config.json";
import { context } from "../app";

Given("the IAM OAuth Authorize redirects to the Login page", (): void => {
  cy.intercept(
    "GET",
    `${config.idp.url}/oauth2/authorize?*`,
    async (req: CyHttpMessages.IncomingHttpRequest): Promise<void> => {
      const nextUrl: string = `${config.idp.url}/oauth2/authorize`;
      req.redirect(
        `${config.app.url}/login?next_url=${encodeURIComponent(nextUrl)}&csrf_token=CSRF_TOKEN`,
        307,
      );
    },
  );
});

Given("the IAM OAuth Authorize redirects to the Signup page", (): void => {
  cy.intercept(
    "GET",
    `${config.idp.url}/oauth2/authorize?*`,
    async (req: CyHttpMessages.IncomingHttpRequest): Promise<void> => {
      const nextUrl: string = `${config.idp.url}/oauth2/authorize`;
      req.redirect(
        `${config.scApp.url}/signup?next_url=${encodeURIComponent(nextUrl)}&csrf_token=CSRF_TOKEN`,
        307,
      );
    },
  );
});

Given("the SC App Signup has been intercepted", (): void => {
  cy.intercept("GET", `${config.scApp.url}/signup*`, {
    statusCode: 200,
    body: "<html lang='en'>SC App Signup</html>",
  });
});

Given(
  "the POST request for login to organization has been intercepted with id {string}",
  (organizationId): void => {
    cy.intercept(
      "GET",
      `${config.idp.url}/oauth2/*`,
      async (req: CyHttpMessages.IncomingHttpRequest): Promise<void> => {
        req.redirect(`${config.app.url}/sp/customers/${organizationId}`, 302);
      },
    ).as("postLoginToOrganization");
  },
);

Then(
  "verify that the user is currently in the organization dashboard with the id {string}",
  (organizationId) => {
    cy.wait("@postLoginToOrganization");
    cy.url().should("include", `/customers/${organizationId}`);
  },
);

Given("the IAM Logout redirects to {string}", (path: string): void => {
  const url: string = `${config.idp.url}/oauth2/logout?*`;
  cy.intercept(
    "GET",
    url,
    async (req: CyHttpMessages.IncomingHttpRequest): Promise<void> => {
      req.redirect(`${config.app.url}${path}`, 307);
    },
  ).as(url);
  context.aliases.push(url);
});
