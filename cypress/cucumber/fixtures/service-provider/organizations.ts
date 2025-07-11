import {
  PaginationSchema_OrganizationUserRead_,
  PaginationSchema_ServiceProviderOrganizationRead_,
  ServiceProviderOrganizationRead,
} from "../../../../src/iam/iam.types";
import { PaginationSchema_PolicyRead_ } from "../../../../src/service-providers/Policies/policies.types";

export const organizations: {
  [key: string]: PaginationSchema_ServiceProviderOrganizationRead_ | null;
} = {
  "001": {
    offset: 0,
    limit: 10,
    results: [
      {
        organization: {
          id: "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d",
          name: "Acme Inc. SP",
        },
        is_active: true,
        created_date: "2024-04-15T15:32:19.604557",
      },
    ],
    size: 1,
    total: 1,
  },
};

export const serviceProviderOrganizations: {
  [key: string]: ServiceProviderOrganizationRead;
} = {
  "001": {
    organization: {
      id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 001",
      is_service_provider: false,
    },
    is_active: true,
    created_date: "2024-04-15T15:32:19.604557",
  },
  "002": {
    organization: {
      id: "3a6f01d0-f3c6-4923-ad98-112d6d97355b",
      name: "Org 002",
      is_service_provider: false,
    },
    is_active: true,
    created_date: "2024-04-15T15:32:19.604557",
  },
};

export const orgUsers: {
  [key: string]: PaginationSchema_OrganizationUserRead_;
} = {
  "001": {
    offset: 0,
    limit: 0,
    results: [
      {
        email: "user@example.com",
        first_name: "string",
        last_name: "string",
        job_role: "MAR",
        id: "1edfc35c-e116-4c2e-8e35-8a28b68d5f6d",
        user_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        organization: {
          id: "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d",
          name: "string",
        },
        status: "P",
        created_date: "2024-04-23T20:01:03.921Z",
        updated_date: "2024-04-23T20:01:03.921Z",
        is_active: true,
        unit: {
          id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          name: "string",
        },
      },
    ],
    size: 1,
    total: 1,
  },
};

export const orgUsersPolicies: {
  [key: string]: PaginationSchema_PolicyRead_;
} = {
  "001": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "d0734fcc-5edd-4d20-8308-5273420aff8c",
        owner_id: "00000000-0000-0000-0002-000000000001",
        assigned_by_id: "00000000-0000-0000-0002-000000000001",
        resource_owner_id: "00000000-0000-0000-0002-000000000001",
        type_id: "001",
        valid_from: null,
        valid_until: null,
        optional: false,
        agreement_id: null,
        name: "Policy 1",
        description: "Policy 1 description",
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
        id: "d0734fcc-5edd-4d20-8308-5273420aff8c",
        owner_id: "00000000-0000-0000-0002-000000000001",
        assigned_by_id: "00000000-0000-0000-0002-000000000001",
        resource_owner_id: "00000000-0000-0000-0002-000000000001",
        type_id: "001",
        valid_from: null,
        valid_until: null,
        optional: false,
        agreement_id: null,
        name: "Policy 2",
        description: "Policy 2 description",
      },
    ],
    size: 1,
    total: 1,
  },
  "003": {
    offset: 0,
    limit: 10,
    results: [],
    size: 0,
    total: 0,
  },
};
