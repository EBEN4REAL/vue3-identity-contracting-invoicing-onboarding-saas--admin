import { AxiosResponse } from "axios";
import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import { AuditEventRead } from "~/iam/iam.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  AgreementMetricsRead,
  CustomerOrganizationMetricsRead,
} from "~/events/events.types";

export type GetAuditEventsRequest = {
  offset?: string;
  limit?: string;
  service_provider_id?: string;
};

class AuditEventsService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(`${config.events.url}`);
  }

  async getAuditEvents(
    service_provider_id: string,
    params: TableRequestParams,
  ): Promise<TableResponse<AuditEventRead>> {
    const response: AxiosResponse<TableResponse<AuditEventRead>> =
      await this.client.get(
        `/audit-events?service_provider_id=${service_provider_id}`,
        params,
      );

    return response.data;
  }

  async getAgreementMetrics(
    service_provider_id: string,
    category?: string,
  ): Promise<AgreementMetricsRead> {
    const response: AxiosResponse<AgreementMetricsRead> = await this.client.get(
      `/service-providers/${service_provider_id}/agreements-metrics`,
      { category },
    );

    return response.data;
  }

  async getCustomerOrganizationMetrics(
    service_provider_id: string,
  ): Promise<CustomerOrganizationMetricsRead> {
    const response: AxiosResponse<CustomerOrganizationMetricsRead> =
      await this.client.get(
        `/service-providers/${service_provider_id}/customer-organization-metrics`,
      );

    return response.data;
  }
}

export const auditEventsService: AuditEventsService = new AuditEventsService();
