import { components } from "../../../policies/policies.schemas";

export type TypeDialogPoliciesDeleteData = {
  policyName: string;
  policyId: string;
};

export type PaginationSchema_PolicyTypeRead_ =
  components["schemas"]["PaginationSchema_PolicyTypeRead_"];

export type PaginationSchema_OAuthClientPolicyAssignmentRead_ =
  components["schemas"]["PaginationSchema_OAuthClientPolicyAssignmentRead_"];

export type OAuthClientPolicyAssignmentRead =
  components["schemas"]["OAuthClientPolicyAssignmentRead"];

export type PolicyCategoryReadLimited =
  components["schemas"]["PolicyCategoryReadLimited"][];

export type UxBehavior = components["schemas"]["UXBehaviour"][];

export type PolicyTypePermissionRead =
  components["schemas"]["PolicyTypeEntitlementRead"];

export type PolicyTypeRoleRead = components["schemas"]["PolicyTypeRoleRead"];

export type RoleUsageRead = components["schemas"]["RoleUsageRead"];

export type PolicyTypeBaseRead = components["schemas"]["PolicyTypeBaseRead"];

export type PermissionUsageRead = components["schemas"]["EntitlementUsageRead"];

export type PolicyType = {
  id: string;
  name: string;
  description?: string | null;
  policy_type: {
    name: string;
    description?: string | null;
  };
};
