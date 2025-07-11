import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AxiosResponse } from "axios";
import {
  AttributeSetAttributesOf,
  AttributeSetCreate,
  AttributeSetUpdate,
  AttributeSetWithAttributeTypesRead,
  AttributeSetWithCountsRead,
  OAuthClientBaseRead,
} from "~/onboarding/onboarding.types";
import { reactive } from "vue";
import { attributeSetAttributeOfItems } from "~/service-providers/AttributeSets/attributeSetAttributeOfHelper";

class AttributeSetsService {
  client: ClientService;
  state: {
    attributeSetAttributeOf: AttributeSetAttributesOf | null;
  };

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
    this.state = reactive({
      attributeSetAttributeOf: null,
    });
  }

  get getAttributeSetAttributeOfLabel(): string | null {
    return this.state.attributeSetAttributeOf
      ? attributeSetAttributeOfItems[this.state.attributeSetAttributeOf]
      : null;
  }

  setAttributeSetAttributeOf(attributeOf: AttributeSetAttributesOf) {
    this.state.attributeSetAttributeOf = attributeOf;
  }

  async getAttributeSets(
    serviceProviderId: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<AttributeSetWithCountsRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/attribute-sets`,
      params,
    );
    return response.data;
  }

  async createAttributeSet(
    serviceProviderId: string,
    payload: AttributeSetCreate,
  ): Promise<AttributeSetWithAttributeTypesRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/attribute-sets`,
      payload,
    );
    return response.data;
  }

  async getAttributeSet(
    serviceProviderId: string,
    attributeSetId: string,
  ): Promise<AttributeSetWithAttributeTypesRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/attribute-sets/${attributeSetId}`,
    );
    this.state.attributeSetAttributeOf = response.data.type;
    return response.data;
  }

  async updateAttributeSet(
    serviceProviderId: string,
    attributeSetId: string,
    payload: AttributeSetUpdate,
  ): Promise<AttributeSetWithAttributeTypesRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${serviceProviderId}/attribute-sets/${attributeSetId}`,
      payload,
    );
    return response.data;
  }

  async deleteAttributeSet(
    serviceProviderId: string,
    attributeSetId: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${serviceProviderId}/attribute-sets/${attributeSetId}`,
    );
    return response.data;
  }

  async getAttributeSetUsages(
    serviceProviderId: string,
    attribute_set_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<OAuthClientBaseRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/attribute-sets/${attribute_set_id}/usage`,
      params,
    );
    return response.data;
  }
}

export const attributeSetsService: AttributeSetsService =
  new AttributeSetsService();
