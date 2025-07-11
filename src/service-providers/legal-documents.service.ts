import { AxiosResponse } from "axios";
import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  GetLegalDocumentsParams,
  LegalDocumentRead,
  SPLegalDocumentRead,
} from "./LegalDocuments/legal-documents.types";
import { TableResponse } from "~/mm_ui_kit/src/types/table.types";

class LegalDocumentsService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(`${config.contracting.url}`);
  }

  async getLegalDocuments(
    serviceProviderId: string,
    params?: GetLegalDocumentsParams,
  ): Promise<TableResponse<SPLegalDocumentRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${serviceProviderId}/legal-documents`,
      params,
    );

    return response.data;
  }

  async getAgreementLegalDocuments(
    serviceProviderId: string,
    agreementId: string,
    params?: GetLegalDocumentsParams,
  ): Promise<TableResponse<LegalDocumentRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${serviceProviderId}/agreements/${agreementId}/legal-documents`,
      params,
    );
    return response.data;
  }
}

export const legalDocumentsService: LegalDocumentsService =
  new LegalDocumentsService();
