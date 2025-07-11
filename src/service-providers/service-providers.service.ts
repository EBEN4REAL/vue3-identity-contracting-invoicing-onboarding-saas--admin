import { AxiosResponse } from "axios";
import ClientService from "~/common/services/client.service";
import config from "../mm.config.json";
import {
  MetricsChart,
  OrganizationImportRead,
  OrganizationMetrics,
  OrganizationUserRead,
  OrganizationUsersCreate,
  OrganizationUserStatusUpdate,
  PaginationSchema_OrganizationRead_,
  PaginationSchema_ServiceProviderOrganizationUserRead_,
  PaginationSchema_ServiceProviderRead_,
  ServiceProviderOrganizationRead,
  ServiceProviderOrganizationUserRead,
  ServiceProviderRead,
  ServiceProviderUpdate,
  UploadLogo,
} from "~/iam/iam.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { TypeCreateOrganizationForm } from "./AccessControl/Organizations/Organizations.types";
import { reactive } from "vue";

export type GetServiceProvidersRequest = {
  offset?: string;
  limit?: string;
  sort?: string;
  query?: string;
};

type AdditionalParams = {
  organization_id?: string[];
};

type ExtendedTableRequestParams = TableRequestParams & AdditionalParams;

class ServiceProvidersService {
  client: ClientService;
  state: {
    importCustomersStatus: OrganizationImportRead | null;
  };

  constructor() {
    this.client = new ClientService(`${config.iam.url}/iam/service-providers`);
    this.state = reactive({
      importCustomersStatus: null,
    });
  }

  async getServiceProviders(
    getServiceProvidersRequest: GetServiceProvidersRequest,
  ): Promise<PaginationSchema_ServiceProviderRead_> {
    const urlParams: string = new URLSearchParams(
      getServiceProvidersRequest,
    ).toString();
    const url: string = `${urlParams.length > 0 ? "?" : ""}${urlParams}`;

    const response: AxiosResponse = await this.client.get(url);
    return response.data;
  }

  async createSPOrganizationUsers(
    service_provider_id: string,
    organization_id: string,
    spOrganizationUsers: OrganizationUsersCreate,
  ): Promise<OrganizationUserRead[]> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/organizations/${organization_id}/users`,
      spOrganizationUsers,
    );

    return response.data;
  }

  async getServiceProvider(
    service_provider_id: string,
  ): Promise<ServiceProviderRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}`,
    );
    return response.data;
  }

  async updateServiceProvider(
    service_provider_id: string,
    body: ServiceProviderUpdate,
  ): Promise<ServiceProviderRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${service_provider_id}`,
      body,
    );
    return response.data;
  }

  async getServiceProviderMetrics(
    serviceProviderId: string,
  ): Promise<OrganizationMetrics> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/metrics`,
    );

    return response.data;
  }

  async getServiceProviderMetricsShared(
    metrics: string,
    serviceProviderId: string,
    fromDate: string,
    untilDate: string,
  ): Promise<MetricsChart> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/metrics/${metrics}?from_date=${fromDate}&until_date=${untilDate}`,
    );

    return response.data;
  }

  async getServiceProviderMetricsActiveUsers(
    serviceProviderId: string,
    fromDate: string,
    untilDate: string,
  ): Promise<MetricsChart> {
    return this.getServiceProviderMetricsShared(
      "active-users",
      serviceProviderId,
      fromDate,
      untilDate,
    );
  }

  async getServiceProviderMetricsFailedLogins(
    serviceProviderId: string,
    fromDate: string,
    untilDate: string,
  ): Promise<MetricsChart> {
    return this.getServiceProviderMetricsShared(
      "failed-logins",
      serviceProviderId,
      fromDate,
      untilDate,
    );
  }

  async getServiceProviderMetricsSignups(
    serviceProviderId: string,
    fromDate: string,
    untilDate: string,
  ): Promise<MetricsChart> {
    return this.getServiceProviderMetricsShared(
      "signups",
      serviceProviderId,
      fromDate,
      untilDate,
    );
  }

  async getServiceProviderOrganizations(
    service_provider_id: string,
    params?: ExtendedTableRequestParams,
  ): Promise<TableResponse<ServiceProviderOrganizationRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/organizations`,
      params,
    );

    return response.data;
  }

  async getServiceProviderOrganizationNames(
    service_provider_id: string,
    organizationIds: (string | null)[],
  ): Promise<PaginationSchema_OrganizationRead_> {
    const orgIds = {
      organization_id: organizationIds,
    };

    const params = new URLSearchParams();
    orgIds.organization_id.forEach((id) => {
      if (id) {
        params.append("organization_id", id);
      }
    });

    const urlParams: string = params.toString();
    const queryString: string = `/${service_provider_id}/organizations${urlParams.length > 0 ? "?" : ""}${urlParams}`;

    const response: AxiosResponse = await this.client.get(queryString);
    return response.data;
  }

  async getServiceProviderOrganizationDetails(
    service_provider_id: string,
    organization_id: string,
  ): Promise<ServiceProviderOrganizationRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/organizations/${organization_id}`,
    );

    return response.data;
  }

  async getServiceProviderOrganizationUsers(
    service_provider_id: string,
    organization_id: string,
    params?: TableRequestParams,
  ): Promise<PaginationSchema_ServiceProviderOrganizationUserRead_> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/organizations/${organization_id}/users`,
      params,
    );

    return response.data;
  }

  async getServiceProviderOrganizationUserDetails(
    service_provider_id: string,
    organization_id: string,
    service_provider_user_id: string,
  ): Promise<ServiceProviderOrganizationUserRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/organizations/${organization_id}/users/${service_provider_user_id}`,
    );

    return response.data;
  }

  async getServiceProviderUsers(
    serviceProviderId: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<ServiceProviderOrganizationUserRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/organization-users`,
      params,
    );
    return response.data;
  }

  async getServiceProviderUserDetails(
    service_provider_id: string,
    service_provider_organization_user_id: string,
  ): Promise<ServiceProviderOrganizationUserRead> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/organization-users/${service_provider_organization_user_id}`,
    );

    return response.data;
  }

  async uploadLogoForSP(
    service_provider_id: string,
    body: UploadLogo,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/logo`,
      body,
    );

    return response.data;
  }

  async createCustomer(
    service_provider_id: string,
    body: TypeCreateOrganizationForm,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/organizations`,
      body,
    );
    return response.data;
  }

  async postImportCustomers(
    service_provider_id: string,
    body: FormData,
  ): Promise<OrganizationImportRead> {
    const response: AxiosResponse = await this.client.post(
      `/${service_provider_id}/organizations/imports`,
      body,
    );

    return response.data;
  }

  async getImportCustomers(
    service_provider_id: string,
    organization_import_id: string,
  ): Promise<void> {
    const response: AxiosResponse = await this.client.get(
      `/${service_provider_id}/organizations/imports/${organization_import_id}`,
    );

    this.state.importCustomersStatus = response.data;
  }

  async createInvitationEmailForSPUser(
    service_provider_id: string,
    organization_id: string,
    user_id: string,
  ): Promise<void> {
    await this.client.post(
      `/${service_provider_id}/organizations/${organization_id}/users/${user_id}/invitation`,
    );
  }

  async updateSPUserStatus(
    service_provider_id: string,
    organization_id: string,
    user_id: string,
    payload: OrganizationUserStatusUpdate,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.put(
      `${service_provider_id}/organizations/${organization_id}/users/${user_id}/status`,
      payload,
    );

    return response.data;
  }
}

export const serviceProvidersService: ServiceProvidersService =
  new ServiceProvidersService();
