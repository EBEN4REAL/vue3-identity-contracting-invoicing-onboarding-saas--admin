import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AxiosResponse } from "axios";
import { ResourceAttributeTypeInUseRead } from "~/configuration/configuration.types";
import { ResourceAttributeTypeCreate } from "~/policies/policies.types";

class ResourceAttributeTypesService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
  }

  async getResourceAttributeTypes(
    serviceProviderId: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<ResourceAttributeTypeInUseRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/resource-attribute-types`,
      params,
    );
    return response.data;
  }

  async getResourceAttributeType(
    serviceProviderId: string,
    resourceAttributeTypeId: string,
  ): Promise<ResourceAttributeTypeInUseRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/resource-attribute-types/${resourceAttributeTypeId}`,
    );

    return response.data;
  }

  async postResourceAttributeType(
    service_provider_id: string,
    resource_attribute_types: ResourceAttributeTypeCreate[],
  ) {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/resource-attribute-types`,
      {
        resource_attribute_types: resource_attribute_types.map((obj) => ({
          ...obj,
        })),
      },
    );
    return response.data;
  }

  async patchResourceAttributeType(
    service_provider_id: string,
    resourceAttributeType: ResourceAttributeTypeCreate,
  ) {
    const { name, format_option } = resourceAttributeType;
    const response: AxiosResponse = await this.client.patch(
      `/${service_provider_id}/resource-attribute-types/${resourceAttributeType.id}`,
      { name, format_option },
    );
    return response.data;
  }

  async deleteResourceAttributeType(
    service_provider_id: string,
    resource_attribute_type_id: string,
  ) {
    const response: AxiosResponse = await this.client.delete(
      `/${service_provider_id}/resource-attribute-types/${resource_attribute_type_id}`,
    );
    return response.data;
  }
}

export const resourceAttributeTypesService: ResourceAttributeTypesService =
  new ResourceAttributeTypesService();
