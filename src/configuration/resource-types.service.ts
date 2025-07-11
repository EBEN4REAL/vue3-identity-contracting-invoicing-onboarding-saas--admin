import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  ResourceTypeCreate,
  ResourceTypeExtendedRead,
  ResourceTypeRead,
  ResourceTypeUpdate,
} from "~/policies/policies.types";
import { AxiosResponse } from "axios";
import { reactive } from "vue";

class ResourceTypesService {
  client: ClientService;
  state: {
    resourceType: ResourceTypeExtendedRead | null;
  };

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
    this.state = reactive({
      resourceType: null,
    });
  }

  async getResourcesTypes(
    service_provider_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<ResourceTypeRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/resource-types`,
      params,
    );
    return response.data;
  }

  async getResourceType(
    service_provider_id: string,
    resource_type_id: string,
  ): Promise<ResourceTypeExtendedRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/resource-types/${resource_type_id}`,
    );
    return response.data;
  }

  async postResourceType(
    service_provider_id: string,
    resourceType: ResourceTypeCreate,
  ): Promise<ResourceTypeRead> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/resource-types`,
      { ...resourceType, service_provider_id },
    );
    return response.data;
  }

  async patchResourceType(
    service_provider_id: string,
    resource_type_id: string,
    resourceType: ResourceTypeUpdate,
  ) {
    const response: AxiosResponse = await this.client.patch(
      `/${service_provider_id}/resource-types/${resource_type_id}`,
      resourceType,
    );
    return response.data;
  }

  async deleteResourceType(
    service_provider_id: string,
    resourceTypeId: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${service_provider_id}/resource-types/${resourceTypeId}`,
    );
    return response.data;
  }
}

export const resourceTypesService: ResourceTypesService =
  new ResourceTypesService();
