type Feature = {
  name: string;
  enabled: boolean;
  variant: {
    name: string;
    enabled: boolean;
    feature_enabled: boolean;
    featureEnabled: boolean;
  };
};

const FEATURES: Feature[] = [
  {
    name: "settings_page",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "legal_documents",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "resources_config",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "totp",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "subscriptions",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "organization_selection",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "organization_selection_dashboard",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "create_customer",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "import_customers",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "license_details_page",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "marketing_feature_list",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "pricing",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "invoices_overview",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "access_licenses",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "plans",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
  {
    name: "billing_and_invoicing",
    enabled: true,
    variant: {
      name: "disabled",
      enabled: false,
      feature_enabled: true,
      featureEnabled: true,
    },
  },
];

export default FEATURES;
