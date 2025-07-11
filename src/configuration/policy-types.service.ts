import ClientService from "~/common/services/client.service";
import { RoleRead } from "~/service-providers/Roles/roles.type";
import { PermissionRead } from "~/service-providers/Permissions/permissions.type";
import config from "~/mm.config.json";
import { reactive } from "vue";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  FilterBaseRead,
  PolicyTypeChildPolicyTypeRead,
  PolicyTypeChildPolicyTypeUpdate,
  PolicyTypeCreate,
  PolicyTypeFilterCreate,
  PolicyTypeRead,
} from "~/policies/policies.types";
import { AxiosResponse } from "axios";
import { PolicyTypeDetailForm } from "~/service-providers/PolicyTypeDetail/policyTypeDetail.types";
import {
  PolicyTypePermissionRead,
  PolicyTypeRoleRead,
} from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { SPPolicyTypeRead } from "./configuration.types";

class PolicyTypesService {
  client: ClientService;
  state: {
    category_id: string | null;
    rolesSelected: RoleRead[];
    permissionsSelected: PermissionRead[];
    roleSelected: RoleRead | null;
  };

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
    this.state = reactive({
      category_id: null,
      rolesSelected: [],
      permissionsSelected: [],
      roleSelected: null,
    });
  }

  get getRolesSelectedIds() {
    return this.state.rolesSelected.map((role) => role.id);
  }

  get getPermissionsSelectedIds() {
    return this.state.permissionsSelected.map((permission) => permission.id);
  }

  async getPolicyTypes(
    service_provider_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<SPPolicyTypeRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/policy-types`,
      params,
    );
    return response.data;
  }

  async getPolicyType(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<SPPolicyTypeRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/policy-types/${policy_type_id}`,
    );
    return response.data;
  }

  async deletePolicyType(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${service_provider_id}/policy-types/${policy_type_id}`,
    );
    return response.data;
  }

  async postPolicyType(
    service_provider_id: string,
    body: PolicyTypeCreate,
  ): Promise<SPPolicyTypeRead> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/policy-types`,
      body,
    );
    return response.data;
  }

  async patchPolicyType(
    service_provider_id: string,
    policy_type_id: string,
    body: PolicyTypeDetailForm,
  ): Promise<PolicyTypeRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${service_provider_id}/policy-types/${policy_type_id}`,
      body,
    );
    return response.data;
  }

  async addChildPolicyTypeToPolicyType(
    service_provider_id: string,
    policy_type_id: string,
    body: PolicyTypeChildPolicyTypeUpdate,
  ): Promise<PolicyTypeChildPolicyTypeRead> {
    const response: AxiosResponse = await this.client.put(
      `/${service_provider_id}/policy-types/${policy_type_id}/child-policy-types`,
      body,
    );
    return response.data;
  }

  async removeChildPolicyTypeFromPolicyType(
    service_provider_id: string,
    policy_type_id: string,
    child_policy_type_id: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${service_provider_id}/policy-types/${policy_type_id}/child-policy-types/${child_policy_type_id}`,
    );
    return response.data;
  }

  async addFilterToPolicyType(
    service_provider_id: string,
    policy_type_id: string,
    body: PolicyTypeFilterCreate,
  ): Promise<FilterBaseRead> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/policy-types/${policy_type_id}/filters`,
      body,
    );
    return response.data;
  }

  async removeFilterFromPolicyType(
    service_provider_id: string,
    policy_type_id: string,
    filter_id: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${service_provider_id}/policy-types/${policy_type_id}/filters/${filter_id}`,
    );
    return response.data;
  }

  async fetchPermissions(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<PolicyTypePermissionRead[]> {
    const response = await this.client.get(
      `/${service_provider_id}/policy-types/${policy_type_id}/entitlements`,
      null,
      { isShowError: false },
    );

    return response.data.entitlements;
  }

  async addPermissions(
    service_provider_id: string,
    policy_type_id: string,
    entitlement_ids: string[],
  ): Promise<void> {
    await this.client.post(
      `/${service_provider_id}/policy-types/${policy_type_id}/entitlements`,
      {
        entitlement_ids,
      },
    );
  }

  async deletePermission(
    service_provider_id: string,
    policy_type_id: string,
    permission_id: string,
  ): Promise<void> {
    await this.client.delete(
      `/${service_provider_id}/policy-types/${policy_type_id}/entitlements/${permission_id}`,
    );
  }

  async fetchRoles(
    service_provider_id: string,
    policy_type_id: string,
  ): Promise<PolicyTypeRoleRead[]> {
    const response = await this.client.get(
      `/${service_provider_id}/policy-types/${policy_type_id}/roles`,
      null,
      { isShowError: false },
    );

    return response.data.roles;
  }

  async addRoles(
    service_provider_id: string,
    policy_type_id: string,
    role_ids: string[],
  ): Promise<void> {
    await this.client.post(
      `/${service_provider_id}/policy-types/${policy_type_id}/roles`,
      {
        role_ids,
      },
    );
  }

  async putRoles(
    service_provider_id: string,
    policy_type_id: string,
    role_ids: string[],
  ): Promise<void> {
    await this.client.put(
      `/${service_provider_id}/policy-types/${policy_type_id}/roles`,
      {
        role_ids,
      },
    );
  }

  async deleteRole(
    service_provider_id: string,
    policy_type_id: string,
    role_id: string,
  ): Promise<void> {
    await this.client.delete(
      `/${service_provider_id}/policy-types/${policy_type_id}/roles/${role_id}`,
    );
  }
}

export const policyTypesService: PolicyTypesService = new PolicyTypesService();
