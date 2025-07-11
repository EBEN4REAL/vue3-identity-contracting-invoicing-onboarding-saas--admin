import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import { AxiosResponse } from "axios";
import { AttributeTypeRead } from "~/onboarding/onboarding.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";

class AttributeTypesService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(`${config.onboarding.url}`);
  }

  async getAttributeTypesPerServiceProvider(
    serviceProviderId: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<AttributeTypeRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${serviceProviderId}/attribute-types`,
      params,
    );
    return response.data;
  }

  async getAttributeType(
    serviceProviderId: string,
    attributeTypeId: string,
  ): Promise<AttributeTypeRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${serviceProviderId}/attribute-types/${attributeTypeId}`,
      null,
      { isShowError: false },
    );
    return response.data;
  }
}

export const attributeTypesService: AttributeTypesService =
  new AttributeTypesService();
