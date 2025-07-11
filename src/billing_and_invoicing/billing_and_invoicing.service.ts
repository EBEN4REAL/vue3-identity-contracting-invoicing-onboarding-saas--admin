import config from "../mm.config.json";
import { AxiosResponse } from "axios";
import ClientService from "~/common/services/client.service";
import {
  AgreementCancelPreviewRead,
  AgreementTypeExtendedRead,
  AgreementTypeRead,
  AgreementTypeUpdate,
  InvoiceRead,
  PaginationSchema_BillingAddressRead_,
  PaymentIntentRead,
  ServiceConsumerRead,
} from "./billing_and_invoicing.schemas.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AgreementExtendedRead } from "~/service-providers/billing-types";

class BillingAndInvoicingService extends ClientService {
  client: ClientService;
  constructor() {
    super(`${config.billing_and_invoicing.url}`);
    this.client = new ClientService(`${config.billing_and_invoicing.url}`);
  }

  async getPayments(
    service_provider_id: string,
    params: TableRequestParams,
  ): Promise<TableResponse<PaymentIntentRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/payment-intents`,
      params,
    );
    return response.data;
  }
  async getInvoices(
    service_provider_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<InvoiceRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/invoices`,
      params,
    );
    return response.data;
  }

  async getServiceConsumerInvoices(
    service_consumer_id: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<InvoiceRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-consumers/${service_consumer_id}/invoices`,
      params,
    );
    return response.data;
  }

  async getBillingAddress(
    service_consumer_id: string,
  ): Promise<PaginationSchema_BillingAddressRead_> {
    const response: AxiosResponse = await this.client.get(
      `/service-consumers/${service_consumer_id}/billing-address`,
    );
    return response.data;
  }

  async getAgreementBillingDetails(
    service_provider_id: string,
    agreement_id: string,
  ): Promise<AgreementExtendedRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreements/${agreement_id}`,
    );
    return response.data;
  }

  async getServiceConsumerPayments(
    service_consumer_id: string,
    params: TableRequestParams,
  ): Promise<TableResponse<PaymentIntentRead>> {
    const response: AxiosResponse = await this.client.get(
      `/service-consumers/${service_consumer_id}/payment-intents`,
      params,
    );
    return response.data;
  }
  async updateAgreementType(
    service_provider_id: string,
    agreement_type_id: string,
    agreement_type_update: AgreementTypeUpdate,
  ): Promise<TableResponse<AgreementTypeRead>> {
    const response: AxiosResponse = await this.client.patch(
      `/service-providers/${service_provider_id}/agreement-types/${agreement_type_id}`,
      agreement_type_update,
    );
    return response.data;
  }

  async getAgreementTypeExtendedRead(
    service_provider_id: string,
    agreement_type_id: string,
  ): Promise<AgreementTypeExtendedRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreement-types/${agreement_type_id}`,
    );
    return response.data;
  }

  async getInvoicePdf(
    service_consumer_id: string,
    invoice_id: string,
  ): Promise<Blob> {
    const response: AxiosResponse = await this.client.getWithConfigs(
      `/service-consumers/${service_consumer_id}/invoices/${invoice_id}/pdf`,
      { responseType: "blob" },
    );
    return response.data;
  }

  async getSPInvoicePdf(
    service_provider_id: string,
    invoice_id: string,
  ): Promise<Blob> {
    const response: AxiosResponse = await this.client.getWithConfigs(
      `/service-providers/${service_provider_id}/invoices/${invoice_id}/pdf`,
      { responseType: "blob" },
    );
    return response.data;
  }

  async getServiceConsumerDetails(
    service_provider_id: string,
    service_consumer_id: string,
  ): Promise<ServiceConsumerRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/service-consumers/${service_consumer_id}`,
      null,
      { isShowError: false },
    );
    return response.data;
  }
  async getServiceProviderAgreementCancellationPreview(
    service_provider_id: string,
    agreement_id: string,
  ): Promise<AgreementCancelPreviewRead> {
    const response: AxiosResponse = await this.client.get(
      `/service-providers/${service_provider_id}/agreements/${agreement_id}/cancel-preview`,
    );
    return response.data;
  }
}

export const billingAndInvoicingService: BillingAndInvoicingService =
  new BillingAndInvoicingService();
