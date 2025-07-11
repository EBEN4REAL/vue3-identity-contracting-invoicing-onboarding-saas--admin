import { FlowSchema } from "../../../../src/onboarding/onboarding.types";

const flows: { [key: string]: FlowSchema } = {
  user_details_without_job_role: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: true,
        completed: false,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
        },
      },
      {
        index: 2,
        title: "Tell us about your organization",
        active: false,
        completed: false,
        component: "CreateOrganization",
        data: {},
      },
    ],
  },
  user_details_with_job_role: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: false,
        completed: true,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "Sales",
        },
      },
      {
        index: 2,
        title: "Tell us about your organization",
        active: true,
        completed: false,
        component: "CreateOrganization",
        data: {},
      },
    ],
  },
  user_details_active_with_job_role: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: true,
        completed: false,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "Sales",
        },
      },
      {
        index: 2,
        title: "Tell us about your organization",
        active: false,
        completed: false,
        component: "CreateOrganization",
        data: {},
      },
    ],
  },
  create_organization: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: false,
        completed: true,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "CEO",
        },
      },
      {
        index: 2,
        title: "Tell us about your organization",
        active: true,
        completed: false,
        component: "CreateOrganization",
        data: {},
      },
    ],
  },
  create_organization_before_update: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: false,
        completed: true,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "Sales",
        },
      },
      {
        index: 2,
        title: "Tell us about your organization",
        active: true,
        completed: false,
        component: "CreateOrganization",
        data: {
          id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
          name: "Org 001",
          industry: "SaaS",
          number_of_employees_range: "11-50",
        },
      },
    ],
  },
  create_organization_after_update: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: false,
        completed: true,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "Sales",
        },
      },
      {
        index: 2,
        title: "Tell us about your organization",
        active: true,
        completed: false,
        component: "CreateOrganization",
        data: {
          id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
          name: "Org 001",
          industry: "ESG",
          number_of_employees_range: "51-200",
        },
      },
    ],
  },
  request_to_join_organization: {
    completed: false,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        completed: true,
        component: "CreateAccount",
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: false,
        completed: true,
        component: "UserDetails",
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "CEO",
        },
      },
      {
        index: 2,
        title: "Your organization",
        active: true,
        completed: false,
        component: "RequestOrganizationAccess",
        data: {
          organizations: [
            {
              id: "1ac3ce81-6132-4145-851d-10450644ce46",
              name: "Org 001",
            },
            {
              id: "1ac3ce81-6132-4145-851d-10450644ce45",
              name: "Org 002",
            },
            {
              id: "1ac3ce81-6132-4145-851d-10450644ce44",
              name: "Org 003",
            },
          ],
        },
      },
    ],
  },
  joined_organization: {
    completed: true,
    stages: [
      {
        index: 0,
        title: "Create Account",
        active: false,
        component: "CreateAccount",
        completed: true,
        data: {},
      },
      {
        index: 1,
        title: "Tell us about yourself",
        active: false,
        component: "UserDetails",
        completed: true,
        data: {
          first_name: "User",
          last_name: "001",
          job_role: "MAR",
        },
      },
      {
        index: 2,
        title: "Your organization",
        active: true,
        component: "JoinedOrganization",
        completed: true,
        data: {
          name: "Org 001",
        },
      },
    ],
    organization_id: "1ac3ce81-6132-4145-851d-10450644ce46",
  },
};

export default flows;
