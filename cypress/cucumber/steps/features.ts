import { Given } from "cypress-cucumber-preprocessor/steps";
import config from "../../../src/mm.config.json";

const mockFeatures = (featureName: string, enabled: boolean) => [
  {
    name: "create_customer",
    enabled: featureName === "create_customer" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "import_customers",
    enabled: featureName === "import_customers" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "invoices_overview",
    enabled: featureName === "invoices_overview" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },

  {
    name: "payments_overview",
    enabled: featureName === "payments_overview" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "access_logs",
    enabled: featureName === "access_logs" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "attribute_sets",
    enabled: featureName === "attribute_sets" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "legal_documents",
    enabled: featureName === "legal_documents" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "payments_overview",
    enabled: featureName === "payments_overview" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "billing_and_invoicing",
    enabled: featureName === "billing_and_invoicing" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "license_details_page",
    enabled: featureName === "license_details_page" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "roles_entitlements",
    enabled: featureName === "roles_entitlements" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "pricing",
    enabled: featureName === "pricing" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "access_licenses",
    enabled: featureName === "access_licenses" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "marketing_feature_list",
    enabled: featureName === "marketing_feature_list" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "plans",
    enabled: featureName === "plans" ? enabled : true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
];

Given("the feature flag {string} is enabled", (flag: string): void => {
  cy.intercept("GET", `${config.unleash.url}?*`, {
    statusCode: 200,
    body: {
      toggles: mockFeatures(flag, true),
    },
  });
});

Given("the feature flag {string} is disabled", (flag: string): void => {
  cy.intercept("GET", `${config.unleash.url}?*`, {
    statusCode: 200,
    body: {
      toggles: mockFeatures(flag, false),
    },
  });
});
