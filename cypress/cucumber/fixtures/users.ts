export type User = {
  aao?: string;
  id: string;
  user_id?: string;
  first_name: string;
  last_name: string;
  email?: string;
  organization?: {
    id: string;
    name: string;
  };
  organization_users?: {
    organization: { name: string; id: string };
    user_id: string;
    organization_id: string;
    job_role: string;
    is_deleted: string | null;
    created_date: string;
    updated_date: string;
    id: string;
    status: string;
  }[];
  status?: "A" | "E" | "V";
  service_provider_id?: string;
  roles?: string[];
  groups?: string[];
  onboarding_completed?: boolean;
  is_active?: boolean;
  job_role?: "MAR" | "SAL" | "DEV" | "PRO" | "CUS" | "EXE" | "FIN";
  created_date?: string | null;
  updated_date?: string;
  unit?: {
    id: string;
    name: string;
  };
};

const users: { [key: string]: User } = {
  "001": {
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    first_name: "User",
    last_name: "001",
    onboarding_completed: false,
    is_active: true,
    email: "User001@email.com",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    unit: {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
    },
    organization_users: [
      {
        organization: {
          name: "Test org.",
          id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        job_role: "DEV",
        is_deleted: null,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
    ],
  },
  "001-without-organization": {
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    first_name: "123User",
    last_name: "001",
    onboarding_completed: false,
    is_active: true,
    email: "User001@email.com",
    unit: {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
    },
    organization_users: [],
  },
  "001OnboardingCompleted": {
    id: "d8d6d5a4-ee99-4596-9275-a721c37ef4ca",
    first_name: "User",
    last_name: "001",
    onboarding_completed: true,
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
  },
  "001-with-unit-002": {
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    first_name: "User",
    last_name: "001",
    onboarding_completed: false,
    is_active: true,
    email: "User001@email.com",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    unit: {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 2",
    },
  },
  "002": {
    id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    created_date: null,
    first_name: "User",
    last_name: "002",
    email: "User002@email.com",
    onboarding_completed: true,
    is_active: true,
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    unit: {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
    },
    organization_users: [
      {
        organization: {
          name: "Test org.",
          id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        job_role: "DEV",
        is_deleted: null,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
    ],
  },
  "003": {
    id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    created_date: "2024-05-06T12:55:19.127953",
    first_name: "User",
    last_name: "003",
    email: "User003@email.com",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    organization_users: [
      {
        organization: {
          name: "Test org.",
          id: "4a6f01d0-f3c6-4923-ad98-112d6d973553",
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        job_role: "DEV",
        is_deleted: null,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
    ],
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:A:Admins"],
    onboarding_completed: true,
  },
  "003OnboardingNotCompleted": {
    id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    first_name: "User",
    last_name: "003",
    email: "User003@email.com",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:A:Admins"],
    onboarding_completed: false,
  },
  "003Updated": {
    id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    first_name: "UserU",
    last_name: "003U",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:A:Admins"],
    onboarding_completed: true,
  },
  "003With3Orgs": {
    id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    created_date: "2024-05-06T12:55:19.127953",
    first_name: "User",
    last_name: "003",
    job_role: "DEV",
    email: "User003@email.com",
    is_active: true,
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    organization_users: [
      {
        organization: {
          name: "Org 001",
          id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
          is_service_provider: true,
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        job_role: "DEV",
        is_deleted: null,
        is_active: true,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
      {
        organization: {
          name: "Org 002",
          id: "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591",
          is_service_provider: true,
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591",
        job_role: "MAR",
        is_deleted: null,
        is_active: true,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
      {
        organization: {
          name: "Org 004",
          id: "d7fe7362-1d10-4bef-9b8e-0ac891cce7e1",
          is_service_provider: false,
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "d7fe7362-1d10-4bef-9b8e-0ac891cce7e1",
        job_role: "MAR",
        is_deleted: null,
        is_active: true,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
    ],
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:A:Admins"],
    onboarding_completed: true,
  },
  "004": {
    id: "51bc393a-7240-4686-881f-507032fa4b81",
    first_name: "User",
    last_name: "004",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    organization_users: [],
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:E:Editors"],
    onboarding_completed: true,
  },
  "005": {
    id: "2e80ddf8-3563-467d-9413-f336640ff591",
    first_name: "User",
    last_name: "005",
    email: "User005@email.com",
    organization_users: [
      {
        organization: {
          name: "Test org.",
          id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        },
        user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
        organization_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
        job_role: "DEV",
        is_deleted: null,
        created_date: "2023-11-24T09:18:18.949367",
        updated_date: "2023-11-24T09:17:53.794634",
        id: "e9851c9e-20a5-401f-9564-ca6adadae04b",
        status: "A",
      },
    ],
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:V:Viewers"],
    onboarding_completed: true,
  },
  "006": {
    id: "9f8c5b13-e6a2-4d87-ae3f-71b4d2f8c492",
    first_name: "User",
    last_name: "006",
    organization: {
      id: "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591",
      name: "Org 002",
    },
    service_provider_id: "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591",
    groups: ["8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591:V:Viewers"],
    onboarding_completed: true,
    is_active: false,
  },
  MMAdmin001: {
    aao: "None",
    id: "3ac1ec1d-fdc6-4499-9cb7-fea472f5d871",
    first_name: "MMAdmin",
    last_name: "001",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    roles: ["mm:admin"],
    onboarding_completed: true,
    organization_users: [],
  },
  "MMAdmin001-with-aao": {
    aao: "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591",
    id: "3ac1ec1d-fdc6-4499-9cb7-fea472f5d871",
    first_name: "MMAdmin",
    last_name: "001",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    roles: ["mm:admin"],
    onboarding_completed: true,
    organization_users: [],
  },
  "007": {
    id: "2e80ddf8-3563-467d-9413-f336640ff591",
    first_name: "FirstNameUser007",
    last_name: "LastNameUser007",
    email: "user007@email.com",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: ["4a6f01d0-f3c6-4923-ad98-112d6d97355b:A:RegularGroup001"],
    onboarding_completed: true,
  },
  "008": {
    id: "2e80ddf8-3563-467d-9413-f336640ff591",
    first_name: "FirstNameUser008",
    last_name: "LastNameUser008",
    email: "user008@email.com",
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    groups: [],
    onboarding_completed: true,
    job_role: "SAL",
  },
  "009-no-unit": {
    id: "9ae6a77f-718b-4764-bf9a-5fa72b61896d",
    user_id: "d7fe7362-1d10-4bef-9b8e-0ac891cce7e1",
    first_name: "John123",
    last_name: "Doe456",
    onboarding_completed: false,
    is_active: true,
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 004",
    },
  },
  "009-with-unit": {
    id: "9ae6a77f-718b-4764-bf9a-5fa72b61896d",
    user_id: "d7fe7362-1d10-4bef-9b8e-0ac891cce7e1",
    first_name: "John123",
    last_name: "Doe456",
    onboarding_completed: false,
    is_active: true,
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 004",
    },
    unit: {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
    },
  },
  SCOrg: {
    aao: "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591",
    id: "3ac1ec1d-fdc6-4499-9cb7-fea472f5d871",
    first_name: "MMAdmin",
    last_name: "001",
    organization: {
      id: "4236f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
    },
    service_provider_id: "4336f01d0-f3c6-4923-ad98-112d6d97355b",
    roles: [],
    onboarding_completed: true,
  },
};

export default users;
