import { components } from "../../policies/policies.schemas";

export type PaginationSchema_AllPolicyRead_ =
  components["schemas"]["PaginationSchema_AllPolicyRead_"];

export type AllPolicyRead = components["schemas"]["AllPolicyRead"];

export type PaginationSchema_PolicyRead_ =
  components["schemas"]["PaginationSchema_PolicyRead_"];

export type PolicyRead = components["schemas"]["PolicyRead"];

export type TypeFormattedAutocompletePolicies = {
  name?: string;
  value?: string;
  disabled?: boolean;
};
