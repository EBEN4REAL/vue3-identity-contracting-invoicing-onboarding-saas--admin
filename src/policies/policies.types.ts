import { components } from "./policies.schemas";

export type ResourceTypeRead = components["schemas"]["ResourceTypeRead"];
export type ResourceTypeUpdate = components["schemas"]["ResourceTypeUpdate"];
export type ResourceTypeExtendedRead =
  components["schemas"]["ResourceTypeExtendedRead"];
export type ResourceTypeCreate = components["schemas"]["ResourceTypeCreate"];
export type ResourceAttributeTypeCreate =
  components["schemas"]["ResourceAttributeTypeCreate"];
export type ResourceAttributeTypeRead =
  components["schemas"]["ResourceAttributeTypeRead"];
export type PaginationSchema_ResourceAttributeTypeInUseRead_ =
  components["schemas"]["PaginationSchema_ResourceAttributeTypeInUseRead_"];
export type ResourceAttributeTypeInUseRead =
  components["schemas"]["ResourceAttributeTypeInUseRead"];
export type PolicyTypeRead = components["schemas"]["PolicyTypeRead"];
export type PolicyTypeUpdate = components["schemas"]["PolicyTypeUpdate"];
export type PolicyTypeFilterCreate =
  components["schemas"]["PolicyTypeFilterCreate"];
export type PolicyTypeChildPolicyTypeUpdate =
  components["schemas"]["PolicyTypeChildPolicyTypeUpdate"];
export type PolicyTypeCreate = components["schemas"]["PolicyTypeCreate"];
export type OAuthClientPolicyAssignmentMultipleClientsCreate =
  components["schemas"]["OAuthClientPolicyAssignmentMultipleClientsCreate"];
export type OAuthClientPolicyAssignmentCreate =
  components["schemas"]["OAuthClientPolicyAssignmentCreate"];
export type PolicyTypeChildPolicyTypeRead =
  components["schemas"]["PolicyTypeChildPolicyTypeRead"];
export type OAuthClientPolicyAssignmentRead =
  components["schemas"]["OAuthClientPolicyAssignmentRead"];

export type FilterBaseRead = components["schemas"]["FilterBaseRead"];

export type PolicyTypeUsageRead = components["schemas"]["PolicyTypeUsageRead"];

export type AgreementTypeRead = components["schemas"]["AgreementTypeRead"];
export type AgreementTypeWithPoliciesRead =
  components["schemas"]["AgreementTypeWithPoliciesRead"];
export type AgreementTypeCreate = components["schemas"]["AgreementTypeCreate"];
export type AgreementTypeUpdate = components["schemas"]["AgreementTypeUpdate"];
export type AgreementTypePoliciesCountAllocatedRead =
  components["schemas"]["AgreementTypePoliciesCountAllocatedRead"];

export type OrganizationUserPolicyTypeAssign =
  components["schemas"]["OrganizationUserPolicyTypeAssign"];

export type OrganizationPolicyAssignmentRead =
  components["schemas"]["OrganizationPolicyAssignmentRead"];

export type OrganizationPolicyTypeAssign =
  components["schemas"]["OrganizationPolicyTypeAssign"];

export type OrganizationUserPolicyAssignmentRead =
  components["schemas"]["OrganizationUserPolicyAssignmentRead"];

export type AttributeOf = components["schemas"]["AttributeOf"];

export type AgreementTypePoliciesCountAllocatedReadExtended =
  AgreementTypePoliciesCountAllocatedRead & {
    agreement_count: number;
  } & {
    allocated: boolean;
  };

export type OrganizationRead = components["schemas"]["OrganizationRead"];
export type OrganizationUserPolicyAssignmentUserIDRead =
  components["schemas"]["OrganizationUserPolicyAssignmentUserIDRead"];
