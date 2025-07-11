import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  AgreementTypeCreate,
  AgreementTypeUpdate,
} from "~/policies/policies.types";
import { AxiosResponse } from "axios";
import {
  AgreementTypePoliciesRead,
  SPAgreementTypeRead,
} from "~/configuration/configuration.types";
import {
  AgreementTypeToLegalDocumentTypeUpdate,
  LegalDocumentTypeWithPdfSyncStatusRead,
  TypeAllocateDocToLicense,
} from "~/service-providers/LegalDocuments/legal-documents.types";
import { reactive } from "vue";

class AgreementTypesService {
  client: ClientService;
  state: {
    license: AgreementTypePoliciesRead | null;
  };

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
    this.state = reactive({
      license: null,
    });
  }

  async getAgreementTypes(
    service_provider_id: string,
    params: TableRequestParams | URLSearchParams,
  ): Promise<TableResponse<AgreementTypePoliciesRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/agreement-types`,
      params,
    );

    return response.data;
  }

  async getAgreementType(
    service_provider_id: string,
    agreement_id: string,
  ): Promise<AgreementTypePoliciesRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/agreement-types/${agreement_id}`,
    );

    return response.data;
  }

  async postAgreementType(
    serviceProviderId: string,
    form: AgreementTypeCreate,
  ): Promise<SPAgreementTypeRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/agreement-types`,
      form,
    );
    return response.data;
  }

  async patchAgreementType(
    serviceProviderId: string,
    agreementTypeId: string,
    form: AgreementTypeUpdate,
  ): Promise<AgreementTypePoliciesRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${serviceProviderId}/agreement-types/${agreementTypeId}`,
      form,
    );
    return response.data;
  }

  async deleteAgreementType(
    serviceProviderId: string,
    agreementTypeId: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${serviceProviderId}/agreement-types/${agreementTypeId}`,
    );
    return response.data;
  }

  async getAgreementTypeLegalDocumentTypes(
    service_provider_id: string,
    agreement_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<LegalDocumentTypeWithPdfSyncStatusRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/agreement-types/${agreement_id}/legal-document-types`,
      params,
      { isShowError: false },
    );

    return response.data;
  }

  async postAgreementTypeLegalDocumentTypes(
    service_provider_id: string,
    agreement_type_id: string,
    body: AgreementTypeToLegalDocumentTypeUpdate,
  ): Promise<TypeAllocateDocToLicense> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/agreement-types/${agreement_type_id}/legal-document-types`,
      body,
    );

    return response.data;
  }

  async deleteAgreementTypeLegalDocumentTypes(
    service_provider_id: string,
    agreement_type_id: string,
    legal_document_type_id: string,
  ): Promise<void> {
    await this.client.delete(
      `/${service_provider_id}/agreement-types/${agreement_type_id}/legal-document-types/${legal_document_type_id}`,
    );
  }
}

export const agreementTypesService: AgreementTypesService =
  new AgreementTypesService();
