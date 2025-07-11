import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import { AxiosResponse } from "axios";
import { ServiceProviderConfigRead } from "~/stores/unpublishedConfig/types";
import {
  ApplicationWizardCreate,
  ApplicationWizardRead,
  ConfigChangeRead,
  ConfigRead,
  OAuthClientGlobalSettingsRead,
  OAuthClientGlobalSettingsUpdate,
  SectionRead,
  SectionReadWithData,
  SectionStatusRead,
  SectionUpdate,
  WizardCreate,
  WizardUpdate,
  WizardRead,
  WizardReadWithSections,
} from "./configuration.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";

class ConfigurationService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
  }

  async getConfig(
    serviceProviderId: string,
  ): Promise<ServiceProviderConfigRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}`,
      null,
      { isShowError: false },
    );
    return response.data;
  }

  async getUnpublishedConfigChanges(
    serviceProviderId: string,
    config_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<ConfigChangeRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/configs/${config_id}/changes`,
      params,
    );
    return response.data;
  }

  async getConfigDetails(
    serviceProviderId: string,
    config_id: string,
  ): Promise<ConfigRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/configs/${config_id}`,
    );
    return response.data;
  }

  async publishConfigChanges(
    serviceProviderId: string,
    config_id: string,
  ): Promise<ConfigRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/configs/${config_id}/publish`,
    );
    return response.data;
  }

  async createApplicationRoleBasedWizard(
    serviceProviderId: string,
    payload: ApplicationWizardCreate,
  ): Promise<ApplicationWizardRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/wizards/application-wizard`,
      payload,
    );
    return response.data;
  }

  async updateGlobalOAuthClientSettings(
    service_provider_id: string,
    body: OAuthClientGlobalSettingsUpdate,
  ): Promise<OAuthClientGlobalSettingsRead> {
    const response: AxiosResponse = await this.client.put(
      `/${service_provider_id}/global-oauth-client-settings`,
      body,
    );
    return response.data;
  }

  async getGlobalOAuthClientSettings(
    service_provider_id: string,
  ): Promise<OAuthClientGlobalSettingsRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/global-oauth-client-settings`,
      {},
      { isShowError: false },
    );
    return response.data;
  }

  async createWizard(
    serviceProviderId: string,
    payload: WizardCreate,
  ): Promise<WizardReadWithSections> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/wizards`,
      payload,
    );
    return response.data;
  }

  async getWizard(
    serviceProviderId: string,
    wizardId: string,
  ): Promise<WizardReadWithSections> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/wizards/${wizardId}`,
    );
    return response.data;
  }

  async updateWizard(
    serviceProviderId: string,
    wizardId: string,
    payload: WizardUpdate,
  ): Promise<WizardRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${serviceProviderId}/wizards/${wizardId}`,
      payload,
    );
    return response.data;
  }

  async publishWizard(
    serviceProviderId: string,
    wizardId: string,
  ): Promise<WizardRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/wizards/${wizardId}/publish`,
    );
    return response.data;
  }

  async deleteWizard(
    serviceProviderId: string,
    wizardId: string,
    options?: { disconnect?: boolean },
  ): Promise<void> {
    const query = options?.disconnect ? "?disconnect=true" : ""; // Append query string if disconnect is true
    await this.client.delete(
      `/${serviceProviderId}/wizards/${wizardId}${query}`,
    );
  }

  async getSection(
    serviceProviderId: string,
    sectionId: string,
  ): Promise<SectionReadWithData> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/sections/${sectionId}`,
    );
    return response.data;
  }

  async updateSection(
    serviceProviderId: string,
    sectionId: string,
    payload: SectionUpdate,
  ): Promise<SectionRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${serviceProviderId}/sections/${sectionId}`,
      payload,
    );
    return response.data;
  }

  async getSectionStatus(
    serviceProviderId: string,
    sectionId: string,
  ): Promise<SectionStatusRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/sections/${sectionId}/status`,
    );
    return response.data;
  }
}

export const configurationService: ConfigurationService =
  new ConfigurationService();
