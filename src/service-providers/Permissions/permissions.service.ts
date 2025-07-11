import { defineStore } from "pinia";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  PermissionRead,
  TypePermissionForm,
} from "~/service-providers/Permissions/permissions.type";

type PermissionsState = {
  client: ClientService;
};

export const usePermissionsStore = defineStore("permissions", {
  state: (): PermissionsState => ({
    client: new ClientService(`${config.configuration.url}/service-providers`),
  }),
  actions: {
    async fetchPermissions(
      service_provider_id: string,
      params: TableRequestParams,
    ): Promise<TableResponse<PermissionRead>> {
      const response = await this.client.get(
        `/${service_provider_id}/entitlements`,
        params,
        { isShowError: false },
      );

      return response.data;
    },
    async createPermission(
      service_provider_id: string,
      payload: TypePermissionForm,
    ): Promise<PermissionRead> {
      const response = await this.client.post(
        `/${service_provider_id}/entitlements`,
        payload,
      );

      return response.data;
    },
    async updatePermission(
      service_provider_id: string,
      permission_id: string,
      payload: TypePermissionForm,
    ): Promise<void> {
      await this.client.patch(
        `/${service_provider_id}/entitlements/${permission_id}`,
        payload,
      );
    },
    async fetchPermission(
      service_provider_id: string,
      id: string,
    ): Promise<PermissionRead> {
      const response = await this.client.get(
        `/${service_provider_id}/entitlements/${id}`,
        null,
        { isShowError: false },
      );

      return response.data;
    },
    async deletePermission(
      service_provider_id: string,
      permission_id: string,
    ): Promise<void> {
      await this.client.delete(
        `/${service_provider_id}/entitlements/${permission_id}`,
      );
    },
  },
});
