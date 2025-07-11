import {
  PaginationSchema_ServiceProviderOrganizationUserRead_,
  OrganizationImportRead,
  ServiceProviderOrganizationRead,
} from "../../../../src/iam/iam.types";

export const customers: {
  [key: string]: ServiceProviderOrganizationRead | null;
} = {
  "001": {
    organization: {
      id: "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d",
      name: "Acme Inc. SP",
      is_service_provider: true,
    },
    is_active: true,
    created_date: "2024-04-15T13:13:51.058355",
  },
  "002": {
    organization: {
      id: "a9606141-c93f-4090-be32-eca2e2494a36",
      name: "Vibes, Inc",
      is_service_provider: true,
    },
    is_active: true,
    created_date: "2024-07-29T11:31:28.932357",
  },
  "003": {
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
      is_service_provider: true,
    },
    is_active: true,
    created_date: "2024-04-15T13:13:51.058355",
  },
  "004": {
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Vibes 007, Inc",
      is_service_provider: true,
    },
    is_active: true,
    created_date: "2024-07-29T11:31:34.393999",
  },
  "005": {
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Acme, Inc",
      is_service_provider: true,
    },
    is_active: true,
    created_date: "2024-07-29T11:31:34.393999",
  },
};

export const serviceProviderUsers: {
  [key: string]: PaginationSchema_ServiceProviderOrganizationUserRead_ | null;
} = {
  "001": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "8f970a74-4a32-4690-b1cf-20286505fed0",
        user: {
          email: "test@metricsmatter.com",
          first_name: "test",
          last_name: "test",
        },
        organization_user: {
          id: "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d",
        },
        last_login_date: "2024-04-15T13:14:09.318238",
        last_login_access: null,
      },
    ],
    size: 1,
    total: 1,
  },
  "002": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "21697fd7-8f71-4e32-9834-d5cfbf3d5d3d",
        user: {
          email: "test@metricsmatter.com",
          first_name: "test",
          last_name: "test",
        },
        last_login_date: "2024-11-11T14:30:29.670866",
        last_login_access: "ALLOW",
        organization: {
          id: "00000000-0000-0000-0002-000000000001",
          name: "Veriam",
          is_service_provider: false,
        },
        organization_user: {
          id: "16fc4458-e3a1-4a05-9d58-85a1d20c9411",
        },
      },
    ],
    size: 1,
    total: 1,
  },
};

export const importing: {
  [key: string]: OrganizationImportRead;
} = {
  "001": {
    id: "af2cc343-e245-465c-89e1-3fcb7db62504",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "3a413a79-2ce3-4884-9277-a5c298f0cca6",
    file_name: "test.csv",
    organizations_count: 3,
    organizations_created: null,
    users_count: 1,
    users_created: null,
    import_status: "P",
  },
  "001-P": {
    id: "af2cc343-e245-465c-89e1-3fcb7db62504",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "3a413a79-2ce3-4884-9277-a5c298f0cca6",
    file_name: "test.csv",
    organizations_count: 3,
    organizations_created: null,
    users_count: 1,
    users_created: null,
    import_status: "P",
  },
  "001-S": {
    id: "af2cc343-e245-465c-89e1-3fcb7db62504",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "3a413a79-2ce3-4884-9277-a5c298f0cca6",
    file_name: "test.csv",
    organizations_count: 3,
    organizations_created: null,
    users_count: 1,
    users_created: null,
    import_status: "S",
  },
  "001-F": {
    id: "af2cc343-e245-465c-89e1-3fcb7db62504",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    user_id: "3a413a79-2ce3-4884-9277-a5c298f0cca6",
    file_name: "test.csv",
    organizations_count: 3,
    organizations_created: null,
    users_count: 1,
    users_created: null,
    import_status: "F",
  },
};
