import { WelcomeComponentsRead } from "../../../../src/onboarding/onboarding.types";

export const onboardingWelcomeSteps: { [key: string]: WelcomeComponentsRead } =
  {
    "001-no-step-completed": {
      components: [
        {
          component: "ConnectYourApplication",
          completed: false,
        },
        {
          component: "ConfigureAccessRequirements",
          completed: false,
        },
        {
          component: "IntegrateAndGoLive",
          completed: false,
        },
        {
          component: "AddYourCustomers",
          completed: false,
        },
        {
          component: "SetupYourOrganization",
          completed: false,
        },
      ],
      completed: false,
      completed_percentage: 0,
    },
    "002-first-step-completed": {
      components: [
        {
          component: "ConnectYourApplication",
          completed: true,
        },
        {
          component: "ConfigureAccessRequirements",
          completed: false,
        },
        {
          component: "IntegrateAndGoLive",
          completed: false,
        },
        {
          component: "AddYourCustomers",
          completed: false,
        },
        {
          component: "SetupYourOrganization",
          completed: false,
        },
      ],
      completed: false,
      completed_percentage: 20,
    },
    "003-second-step-completed": {
      components: [
        {
          component: "ConnectYourApplication",
          completed: true,
        },
        {
          component: "ConfigureAccessRequirements",
          completed: true,
        },
        {
          component: "IntegrateAndGoLive",
          completed: false,
        },
        {
          component: "AddYourCustomers",
          completed: false,
        },
        {
          component: "SetupYourOrganization",
          completed: false,
        },
      ],
      completed: false,
      completed_percentage: 40,
    },
    "004-fourth-step-completed": {
      components: [
        {
          component: "ConnectYourApplication",
          completed: true,
        },
        {
          component: "ConfigureAccessRequirements",
          completed: true,
        },
        {
          component: "IntegrateAndGoLive",
          completed: true,
        },
        {
          component: "AddYourCustomers",
          completed: true,
        },
        {
          component: "SetupYourOrganization",
          completed: false,
        },
      ],
      completed: false,
      completed_percentage: 80,
    },
    "005-last-step-completed": {
      components: [
        {
          component: "ConnectYourApplication",
          completed: true,
        },
        {
          component: "ConfigureAccessRequirements",
          completed: true,
        },
        {
          component: "IntegrateAndGoLive",
          completed: true,
        },
        {
          component: "AddYourCustomers",
          completed: true,
        },
        {
          component: "SetupYourOrganization",
          completed: true,
        },
      ],
      completed: true,
      completed_percentage: 100,
    },
  };

export const userWelcomeComponents = {
  "001-welcome-component": {
    name: "ConnectYourApplication",
  },
  "002-welcome-component": {
    name: "ConfigureAccessRequirements",
  },
  "003-welcome-component": {
    name: "IntegrateAndGoLive",
  },
  "004-welcome-component": {
    name: "AddYourCustomers",
  },
  "005-welcome-component": {
    name: "SetupYourOrganization",
  },
  "006-welcome-component": {
    name: "InviteYourColleagues",
  },
  "007-welcome-component": {
    name: "SetupOrganizationStructure",
  },
  "008-welcome-component": {
    name: "ViewLicensesAndPolicies",
  },
};
