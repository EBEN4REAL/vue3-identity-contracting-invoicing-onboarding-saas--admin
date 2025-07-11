import {
  PolicyTypeRoleRead,
  RoleUsageRead,
} from "../../../src/service-providers/ConfigurationTabs/Policies/policies.types";
import { RoleRead } from "../../../src/service-providers/Roles/roles.type";
import { TableResponse } from "../../../src/mm_ui_kit/src/types/table.types";

export const roleUsages: Record<string, RoleUsageRead> = {
  "000": {
    policy_types: [],
  },
  "001": {
    policy_types: [
      {
        id: "251cfcd5-06ab-4731-abed-21a43655d4d0",
        name: "Policy #1",
      },
      {
        id: "320a769e-4a05-4d3a-b1df-da2382320920",
        name: "Policy #2",
      },
    ],
  },
};

export const policyTypeRoleByRoleId: Record<string, RoleRead> = {
  "001": {
    id: "5cf7be11-35e0-4eee-9e12-7225182496da",
    name: "role1",
    description: "role1 description",
  },
  "002": {
    id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
    name: "role2",
    description: "role2 description",
  },
  "003": {
    id: "121bd333-2ea0-4ea6-99dd-f63aef432363",
    name: "role3",
    description: "role3 description",
  },
};

export const policyTypeRoles: Record<string, PolicyTypeRoleRead[]> = {
  "000": [],
  "001": [
    {
      id: "cf8c40fa-70f7-42f9-bec7-aa4c13f16ecb",
      role_id: "5cf7be11-35e0-4eee-9e12-7225182496da",
      status: "PENDING",
    },
    {
      id: "97a30488-6a4b-4737-b2fa-07d9393cf8ce",
      role_id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
      status: "PENDING",
    },
  ],
  "002": [
    {
      id: "cf8c40fa-70f7-42f9-bec7-aa4c13f16ecb",
      role_id: "5cf7be11-35e0-4eee-9e12-7225182496da",
      status: "PENDING",
    },
    {
      id: "97a30488-6a4b-4737-b2fa-07d9393cf8ce",
      role_id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
      status: "PENDING",
    },
    {
      id: "17a30488-6a4b-4737-b2fa-07d9393cf8ce",
      role_id: "121bd333-2ea0-4ea6-99dd-f63aef432363",
      status: "PENDING",
    },
  ],
  "003": [
    {
      id: "97a30488-6a4b-4737-b2fa-07d9393cf8ce",
      role_id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
      status: "PENDING",
    },
  ],
};

export const role: Record<string, RoleRead> = {
  "001": {
    name: "role1",
    description: "role1 description",
    id: "5cf7be11-35e0-4eee-9e12-7225182496da",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: roleUsages["001"],
  },
  "001-Updated": {
    name: "role1updated",
    description: "role1updated description",
    id: "5cf7be11-35e0-4eee-9e12-7225182496da",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: roleUsages["000"],
  },
  "002": {
    name: "role2",
    description: "role2 description",
    id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: roleUsages["000"],
  },
  "003": {
    name: "role3",
    description: "role3 description",
    id: "121bd333-2ea0-4ea6-99dd-f63aef432363",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: roleUsages["000"],
  },
  "004": {
    name: "role4",
    description: "role4 description",
    id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: roleUsages["000"],
  },
};

export const roles: Record<string, TableResponse<RoleRead>> = {
  "001": {
    offset: 0,
    limit: 10,
    results: [role["001"], role["002"], role["003"]],
    total: 3,
    size: 3,
  },
  "001-Updated": {
    offset: 0,
    limit: 10,
    results: [role["001-Updated"], role["002"], role["003"]],
    total: 3,
    size: 3,
  },
  "002": {
    offset: 0,
    limit: 10,
    results: [role["001"], role["002"], role["003"], role["004"]],
    total: 4,
    size: 4,
  },
  "003": {
    offset: 0,
    limit: 10,
    results: [role["001"], role["003"]],
    total: 4,
    size: 4,
  },
};
