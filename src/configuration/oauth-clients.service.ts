import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import { AxiosResponse } from "axios";
import {
  OauthClientCreate,
  OauthClientCreateResponseWithValidator,
  OauthClientRead,
  OauthClientSecretCreateResponse,
  OauthClientUpdate,
  PaginationSchema_OauthClientRead_,
} from "~/configuration/configuration.types";
import { reactive } from "vue";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";

export type GetServiceProviderOAuthClientsRequest = {
  offset?: string;
  limit?: string;
  service_provider_id: string;
  name?: string;
};

class OAuthClientsService {
  client: ClientService;
  state: {
    oAuthClient: OauthClientRead | null;
  };

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
    this.state = reactive({
      oAuthClient: null,
    });
  }

  async createServiceProviderOauthClient(
    service_provider_id: string,
    payload: OauthClientCreate,
  ): Promise<OauthClientCreateResponseWithValidator> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/oauth-clients`,
      payload,
    );
    return response.data;
  }

  async createServiceProviderOauthClientSecret(
    oauth_client_id: string,
    service_provider_id: string,
  ): Promise<OauthClientSecretCreateResponse> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/oauth-clients/${oauth_client_id}/secrets`,
    );

    return response.data;
  }

  async deleteServiceProviderOauthClient(
    oauth_client_id: string,
    service_provider_id: string,
  ): Promise<void> {
    await this.client.delete(
      `/${service_provider_id}/oauth-clients/${oauth_client_id}`,
    );
  }

  async deleteServiceProviderOAuthClientSecret(
    oauth_client_id: string,
    service_provider_id: string,
    client_secret_id: string,
  ): Promise<void> {
    await this.client.delete(
      `/${service_provider_id}/oauth-clients/${oauth_client_id}/secrets/${client_secret_id}`,
    );
  }

  async getServiceProviderOauthClient(
    oauth_client_id: string,
    service_provider_id: string,
  ): Promise<OauthClientRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/oauth-clients/${oauth_client_id}`,
    );

    this.state.oAuthClient = response.data;

    return response.data;
  }

  async getServiceProviderOauthClients(
    serviceProviderId: string,
    params: TableRequestParams,
  ): Promise<PaginationSchema_OauthClientRead_> {
    const response: AxiosResponse = await this.client.get(
      `${serviceProviderId}/oauth-clients`,
      params,
    );

    return response.data;
  }

  async updateServiceProviderOauthClient(
    oauth_client_id: string,
    service_provider_id: string,
    payload: OauthClientUpdate,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.patch(
      `/${service_provider_id}/oauth-clients/${oauth_client_id}`,
      payload,
    );

    this.state.oAuthClient = response.data;
  }

  async deleteAttributeSetFromOAuthClient(
    serviceProviderId: string,
    oAuthClientId: string,
    attributeSetId: string,
  ): Promise<void> {
    await this.client.delete(
      `/${serviceProviderId}/oauth-clients/${oAuthClientId}/attribute-sets/${attributeSetId}`,
    );
  }

  async postAttributeSetToOAuthClient(
    serviceProviderId: string,
    oAuthClientId: string,
    attribute_set_ids: string[],
  ): Promise<OauthClientRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/oauth-clients/${oAuthClientId}/attribute-sets`,
      { attribute_set_ids },
    );
    return response.data;
  }
}

export const oAuthClientsService: OAuthClientsService =
  new OAuthClientsService();
