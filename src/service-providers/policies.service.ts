import { AxiosResponse } from "axios";
import { reactive } from "vue";
import ClientService from "~/common/services/client.service";
import config from "../mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AgreementCreate, SPAgreementRead } from "./Licenses/licenses.types";
import {
  AgreementTypePoliciesCountAllocatedRead,
  OAuthClientPolicyAssignmentCreate,
  OrganizationPolicyAssignmentRead,
  OrganizationPolicyTypeAssign,
  OrganizationRead,
  OrganizationUserPolicyAssignmentRead,
  OrganizationUserPolicyAssignmentUserIDRead,
  PolicyTypeRead,
  PolicyTypeUsageRead,
} from "~/policies/policies.types";
import { OrganizationUserPolicyTypeAssign } from "~/policies/policies.types";
import {
  PaginationSchema_AllPolicyRead_,
  PaginationSchema_PolicyRead_,
} from "./Policies/policies.types";
import {
  OAuthClientPolicyAssignmentRead,
  PermissionUsageRead,
  PolicyCategoryReadLimited,
  PolicyTypeBaseRead,
  UxBehavior,
} from "./ConfigurationTabs/Policies/policies.types";
import { RoleRead } from "~/service-providers/Roles/roles.type";
import { PermissionRead } from "~/service-providers/Permissions/permissions.type";

class PoliciesService {
  client: ClientService;
  state: {
    category_id: string | null;
    rolesSelected: RoleRead[];
    permissionsSelected: PermissionRead[];
  };

  constructor() {
    this.client = new ClientService(`${config.policies.url}`);
    this.state = reactive({
      category_id: null,
      rolesSelected: [],
      permissionsSelected: [],
    });
  }

  async getAllExternalPolicies(
    service_provider_id: string,
    params?: TableRequestParams,
  ): Promise<PaginationSchema_AllPolicyRead_> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policies/external/all`,
      params,
      { isShowError: false },
    );
    return response.data;
  }

  async getExternalOrganizationPolicies(
    service_provider_id: string,
    organization_id?: string,
    params?: TableRequestParams,
  ): Promise<PaginationSchema_PolicyRead_> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policies/external/organizations?organization_id=${organization_id}`,
      params,
      { isShowError: false },
    );
    return response.data;
  }

  async getAgreements(
    service_provider_id: string,
    params?: TableRequestParams & { category?: string },
  ): Promise<TableResponse<SPAgreementRead>> {
    // Temporary fix to transform array values like "key=value1&key=value2" and not like "key[]=value1&key[]=value2"
    const queryParts: string[] = [];

    if (params) {
      for (const [key, value] of Object.entries(params)) {
        if (Array.isArray(value)) {
          value.forEach((val) => {
            queryParts.push(
              `${encodeURIComponent(key)}=${encodeURIComponent(val)}`,
            );
          });
        } else {
          queryParts.push(
            `${encodeURIComponent(key)}=${encodeURIComponent(value)}`,
          );
        }
      }
    }

    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreements?${queryParts.join("&")}`,
    );
    return response.data;
  }

  async getAgreement(
    service_provider_id: string,
    agreement_id: string,
  ): Promise<SPAgreementRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreements/${agreement_id}`,
    );
    return response.data;
  }

  async assignAgreement(
    service_provider_id: string,
    agreement_type_id: string,
    organization_id: string,
    body: AgreementCreate,
  ): Promise<AgreementCreate> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/agreement-types/${agreement_type_id}/assign/${organization_id}`,
      body,
    );
    return response.data;
  }

  async cancelAgreements(
    service_provider_id: string,
    agreement_id: string,
  ): Promise<SPAgreementRead> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/agreements/${agreement_id}/cancel`,
    );
    return response.data;
  }

  async getPolicies(
    service_provider_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<PolicyTypeRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policy-types`,
      params,
    );
    return response.data;
  }

  async addPoliciesToOAuth(
    service_provider_id: string,
    oauth_client_id: string,
    body: OAuthClientPolicyAssignmentCreate,
  ): Promise<OAuthClientPolicyAssignmentRead> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/oauth-clients/${oauth_client_id}/policies`,
      body,
    );
    return response.data;
  }

  async unassignPolicyType(
    service_provider_id: string,
    oauth_provider_id: string,
    policy_id: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/service-providers/${service_provider_id}/oauth-clients/${oauth_provider_id}/policies/${policy_id}`,
    );
    return response.data;
  }

  async deletePolicyType(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/service-providers/${service_provider_id}/policy-types/${policy_type_id}`,
    );
    return response.data;
  }

  async getPolicyTypeUsage(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<PolicyTypeUsageRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policy-types/${policy_type_id}/usage`,
      null,
      {
        isShowError: false,
      },
    );
    return response.data;
  }

  async assignPolicy(
    service_provider_id: string,
    body: OrganizationUserPolicyTypeAssign,
  ): Promise<OrganizationUserPolicyAssignmentRead> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/policies/assign/organization_user`,
      body,
    );
    return response.data;
  }

  async assignPolicyToOrganization(
    service_provider_id: string,
    body: OrganizationPolicyTypeAssign,
  ): Promise<OrganizationPolicyAssignmentRead> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/policies/assign/organization`,
      body,
    );
    return response.data;
  }

  async removePolicy(
    service_provider_id: string,
    body: OrganizationUserPolicyTypeAssign,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/policies/unassign/organization_user`,
      body,
    );
    return response.data;
  }

  async removePolicyFromOrganization(
    service_provider_id: string,
    body: OrganizationPolicyTypeAssign,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/policies/unassign/organization`,
      body,
    );
    return response.data;
  }

  async getActiveLicenses(
    service_provider_id: string,
    service_consumer_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<SPAgreementRead>> {
    const queryParts: string[] = [];

    if (params) {
      for (const [key, value] of Object.entries(params)) {
        if (Array.isArray(value)) {
          value.forEach((val) => {
            queryParts.push(
              `${encodeURIComponent(key)}=${encodeURIComponent(val)}`,
            );
          });
        } else {
          queryParts.push(
            `${encodeURIComponent(key)}=${encodeURIComponent(value)}`,
          );
        }
      }
    }

    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreements?cancelled=false&service_consumer_id=${service_consumer_id}&${queryParts.join("&")}`,
    );
    return response.data;
  }

  async getServiceProviderPoliciesOrganizationUsers(
    service_provider_id: string,
    params?: TableRequestParams,
  ): Promise<PaginationSchema_PolicyRead_> {
    const queryParts: string[] = [];

    if (params) {
      for (const [key, value] of Object.entries(params)) {
        if (Array.isArray(value)) {
          value.forEach((val) => {
            queryParts.push(
              `${encodeURIComponent(key)}=${encodeURIComponent(val)}`,
            );
          });
        } else {
          queryParts.push(
            `${encodeURIComponent(key)}=${encodeURIComponent(value)}`,
          );
        }
      }
    }

    const queryString = queryParts.length > 0 ? `?${queryParts.join("&")}` : "";
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policies/external/organization-users${queryString}`,
      null,
      { isShowError: false },
    );
    return response.data;
  }

  async getPolicyTypeCategories(): Promise<PolicyCategoryReadLimited> {
    const response: AxiosResponse = await this.client.get(
      `/policy-type-categories`,
    );
    return response.data;
  }

  async getPolicyTypeCategoryUx(
    policy_type_category_id: string,
  ): Promise<UxBehavior> {
    const response: AxiosResponse = await this.client.get(
      `/policy-type-categories/${policy_type_category_id}/ux`,
    );
    return response.data;
  }

  async getPoliciesForApplication(
    service_provider_id: string,
    oauth_client_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<OAuthClientPolicyAssignmentRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/oauth-clients/${oauth_client_id}/policies`,
      params,
    );
    return response.data;
  }

  async fetchRoleUsage(
    service_provider_id: string,
    role_id: string,
  ): Promise<PolicyTypeBaseRead[]> {
    const response = await this.client.get(
      `/service-providers/${service_provider_id}/roles/${role_id}/usage`,
      null,
      { isShowError: false },
    );

    return response.data.policy_types;
  }

  async fetchPermissionUsage(
    service_provider_id: string,
    permission_id: string,
  ): Promise<PermissionUsageRead[]> {
    const response = await this.client.get(
      `/service-providers/${service_provider_id}/entitlements/${permission_id}/usage`,
      null,
      { isShowError: false },
    );

    return response.data.policy_types;
  }

  async getAgreementTypes(
    service_provider_id: string,
    params?: TableRequestParams & { category?: string },
  ): Promise<TableResponse<AgreementTypePoliciesCountAllocatedRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreement-types`,
      params,
    );
    return response.data;
  }
  async cancelServiceProviderAgreement(
    service_provider_id: string,
    agreement_id: string,
  ): Promise<SPAgreementRead> {
    const response: AxiosResponse = await this.client.post(
      `/service-providers/${service_provider_id}/agreements/${agreement_id}/cancel`,
    );
    return response.data;
  }

  async getOrganizationsAssignedToAgreement(
    service_provider_id: string,
    agreement_type_id: string,
  ): Promise<OrganizationRead[]> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreement-types/${agreement_type_id}/assigned-organizations`,
    );
    return response.data;
  }

  async getOrganizationsAssignedToPolicy(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<OrganizationRead[]> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policy-types/${policy_type_id}/external-policies/assigned-organizations`,
    );
    return response.data;
  }

  async getOrganizationUsersAssignedToPolicy(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<OrganizationUserPolicyAssignmentUserIDRead[]> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/policy-types/${policy_type_id}/external-policies/assigned-organization-users`,
    );
    return response.data;
  }
}

export const policiesService: PoliciesService = new PoliciesService();
