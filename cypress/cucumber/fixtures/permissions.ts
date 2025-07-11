import {
  PolicyTypePermissionRead,
  PermissionUsageRead,
} from "../../../src/service-providers/ConfigurationTabs/Policies/policies.types";
import { PermissionRead } from "../../../src/service-providers/Permissions/permissions.type";
import { TableResponse } from "../../../src/mm_ui_kit/src/types/table.types";

export const permissionUsages: Record<string, PermissionUsageRead> = {
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

export const policyTypePermissionByPermissionId: Record<
  string,
  PermissionRead
> = {
  "001": {
    id: "5cf7be11-35e0-4eee-9e12-7225182496da",
    name: "permission1",
    description: "permission1 description",
  },
  "002": {
    id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
    name: "permission2",
    description: "permission2 description",
  },
  "003": {
    id: "121bd333-2ea0-4ea6-99dd-f63aef432363",
    name: "permission3",
    description: "permission3 description",
  },
};

export const policyTypePermissions: Record<string, PolicyTypePermissionRead[]> =
  {
    "000": [],
    "001": [
      {
        id: "cf8c40fa-70f7-42f9-bec7-aa4c13f16ecb",
        entitlement_id: "5cf7be11-35e0-4eee-9e12-7225182496da",
        status: "PENDING",
      },
      {
        id: "97a30488-6a4b-4737-b2fa-07d9393cf8ce",
        entitlement_id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
        status: "PENDING",
      },
    ],
    "002": [
      {
        id: "cf8c40fa-70f7-42f9-bec7-aa4c13f16ecb",
        entitlement_id: "5cf7be11-35e0-4eee-9e12-7225182496da",
        status: "PENDING",
      },
      {
        id: "97a30488-6a4b-4737-b2fa-07d9393cf8ce",
        entitlement_id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
        status: "PENDING",
      },
      {
        id: "17a30488-6a4b-4737-b2fa-07d9393cf8ce",
        entitlement_id: "121bd333-2ea0-4ea6-99dd-f63aef432363",
        status: "PENDING",
      },
    ],
    "003": [
      {
        id: "97a30488-6a4b-4737-b2fa-07d9393cf8ce",
        entitlement_id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
        status: "PENDING",
      },
    ],
  };

export const permission: Record<string, PermissionRead> = {
  "001": {
    name: "permission1",
    description: "permission1 description",
    id: "5cf7be11-35e0-4eee-9e12-7225182496da",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: permissionUsages["001"],
  },
  "001-Updated": {
    name: "permission1updated",
    description: "permission1updated description",
    id: "5cf7be11-35e0-4eee-9e12-7225182496da",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: permissionUsages["000"],
  },
  "002": {
    name: "permission2",
    description: "permission2 description",
    id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: permissionUsages["000"],
  },
  "003": {
    name: "permission3",
    description: "permission3 description",
    id: "121bd333-2ea0-4ea6-99dd-f63aef432363",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: permissionUsages["000"],
  },
  "004": {
    name: "permission4",
    description: "permission4 description",
    id: "421bd333-2ea0-4ea6-99dd-f63aef432363",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    usages: permissionUsages["000"],
  },
};

export const permissions: Record<string, TableResponse<PermissionRead>> = {
  "001": {
    offset: 0,
    limit: 10,
    results: [permission["001"], permission["002"], permission["003"]],
    total: 3,
    size: 3,
  },
  "001-Updated": {
    offset: 0,
    limit: 10,
    results: [permission["001-Updated"], permission["002"], permission["003"]],
    total: 3,
    size: 3,
  },
  "002": {
    offset: 0,
    limit: 10,
    results: [
      permission["001"],
      permission["002"],
      permission["003"],
      permission["004"],
    ],
    total: 4,
    size: 4,
  },
  "003": {
    offset: 0,
    limit: 10,
    results: [permission["001"], permission["003"]],
    total: 4,
    size: 4,
  },
};
