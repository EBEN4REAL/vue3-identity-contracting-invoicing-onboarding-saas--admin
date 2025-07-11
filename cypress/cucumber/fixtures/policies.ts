import { TableResponse } from "../../../src/mm_ui_kit/src/types/table.types";
import { OAuthClientPolicyAssignmentCreate } from "../../../src/policies/policies.types";
import { OAuthClientPolicyAssignmentRead } from "../../../src/service-providers/ConfigurationTabs/Policies/policies.types";

export const policyServiceProviders: Record<
  string,
  OAuthClientPolicyAssignmentRead
> = {
  "001": {
    oauth_client_id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
    policy_id: "8bf88b4c-74d8-434b-8a38-28fdf80985c2",
    policy_type: {
      id: "a6505d8f-a5ba-4c55-b168-826fc7c417d0",
      name: "Policy #1",
      description: "Policy #1 Description",
    },
  },
  "002": {
    oauth_client_id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
    policy_id: "92b980db-4b60-48e0-b15d-edfc96e1f3bf",
    policy_type: {
      id: "fb9bb098-bada-4e49-bb7e-5d71d0712f35",
      name: "Policy #2",
      description: "Policy #2 Description",
    },
  },
  "003": {
    oauth_client_id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
    policy_id: "a9b73028-c4d5-4a49-ae8c-9921337228e0",
    policy_type: {
      id: "d8accda1-0c91-4830-b49d-dcef3a871a37",
      name: "Policy #3",
      description: "Policy #3 Description",
    },
  },
};

export const policiesServiceProviders: Record<
  string,
  TableResponse<OAuthClientPolicyAssignmentRead>
> = {
  "000": {
    offset: 0,
    limit: 10,
    results: [],
    size: 3,
    total: 3,
  },
  "001": {
    offset: 0,
    limit: 10,
    results: [
      policyServiceProviders["001"],
      policyServiceProviders["002"],
      policyServiceProviders["003"],
    ],
    size: 3,
    total: 3,
  },
  "001-Updated": {
    offset: 0,
    limit: 10,
    results: [policyServiceProviders["002"]],
    size: 3,
    total: 3,
  },
};

export const policiesServiceProvidersUpdate: Record<
  string,
  OAuthClientPolicyAssignmentCreate
> = {
  "001": {
    ids: [policyServiceProviders["002"].policy_type.id],
  },
};
