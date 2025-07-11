import { defineStore } from "pinia";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import { RoleRead, TypeRoleForm } from "~/service-providers/Roles/roles.type";

type RolesState = {
  client: ClientService;
};

export const useRolesStore = defineStore("roles", {
  state: (): RolesState => ({
    client: new ClientService(`${config.configuration.url}/service-providers`),
  }),
  actions: {
    async fetchRoles(
      service_provider_id: string,
      params: TableRequestParams,
    ): Promise<TableResponse<RoleRead>> {
      const response = await this.client.get(
        `/${service_provider_id}/roles`,
        params,
        { isShowError: false },
      );

      return response.data;
    },
    async createRole(
      service_provider_id: string,
      payload: TypeRoleForm,
    ): Promise<RoleRead> {
      const response = await this.client.post(
        `/${service_provider_id}/roles`,
        payload,
      );

      return response.data;
    },
    async updateRole(
      service_provider_id: string,
      role_id: string,
      payload: TypeRoleForm,
    ): Promise<void> {
      await this.client.patch(
        `/${service_provider_id}/roles/${role_id}`,
        payload,
      );
    },
    async fetchRole(
      service_provider_id: string,
      id: string,
    ): Promise<RoleRead> {
      const response = await this.client.get(
        `/${service_provider_id}/roles/${id}`,
        null,
        { isShowError: false },
      );

      return response.data;
    },
    async deleteRole(
      service_provider_id: string,
      role_id: string,
    ): Promise<void> {
      await this.client.delete(`/${service_provider_id}/roles/${role_id}`);
    },
  },
});
