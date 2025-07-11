import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AxiosResponse } from "axios";
import {
  LegalDocumentTypeCreate,
  LegalDocumentTypeDocUpload,
  LegalDocumentTypeIdAndSP,
  LegalDocumentTypePdfPreSignUrl,
  LegalDocumentTypeUpdate,
} from "~/service-providers/LegalDocuments/legal-documents.types";
import { LegalDocumentTypeRead } from "./configuration.types";

class LegalDocumentTypesService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
  }

  async getLegalDocumentTypes(
    serviceProviderId: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<LegalDocumentTypeRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/legal-document-types`,
      params,
      { isShowError: false },
    );

    return response.data;
  }

  async getLegalDocumentType(
    serviceProviderId: string,
    legalDocumentTypeId: string,
  ): Promise<LegalDocumentTypeRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}`,
      null,
      { isShowError: false },
    );

    return response.data;
  }

  async getLegalDocumentTypePdfUrl(
    service_provider_id: string,
    legalDocumentTypeId: string,
  ): Promise<LegalDocumentTypePdfPreSignUrl> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/legal-document-types/${legalDocumentTypeId}/pdf`,
      null,
      { isShowError: false },
    );

    return response.data;
  }

  async postLegalDocumentType(
    serviceProviderId: string,
  ): Promise<LegalDocumentTypeIdAndSP> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/legal-document-types`,
    );
    return response.data;
  }

  async postDocumentToLegalDocumentType(
    serviceProviderId: string,
    legalDocumentTypeId: string,
    body: LegalDocumentTypeDocUpload,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}/pdf`,
      body,
      { isShowError: false },
    );
    return response.data;
  }

  async patchLegalDocumentType(
    serviceProviderId: string,
    legalDocumentTypeId: string,
    body: LegalDocumentTypeCreate | LegalDocumentTypeUpdate,
  ): Promise<LegalDocumentTypeRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}`,
      body,
    );
    return response.data;
  }

  async deleteLegalDocumentType(
    serviceProviderId: string,
    legalDocumentTypeId: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${serviceProviderId}/legal-document-types/${legalDocumentTypeId}`,
    );
    return response.data;
  }
}

export const legalDocumentTypesService: LegalDocumentTypesService =
  new LegalDocumentTypesService();
