import { AxiosResponse } from "axios";
import ClientService from "~/common/services/client.service";
import config from "../mm.config.json";
import {
  OrganizationRead,
  PaginationSchema_OrganizationUserRead_,
  PaginationSchema_OrganizationRead_,
} from "~/iam/iam.types";
import { reactive } from "vue";
import { AttributeSetRead } from "~/onboarding/onboarding.types";

export type GetOrganizationsRequest = {
  offset?: string;
  limit?: string;
  sort?: string;
  query?: string;
};

class OrganizationsService {
  client: ClientService;
  state: {
    organization: OrganizationRead | null;
  };

  constructor() {
    this.client = new ClientService(`${config.iam.url}/iam/organizations`);
    this.state = reactive({
      organization: null,
    });
  }

  async getOrganizations(
    getOrganizationsRequest: GetOrganizationsRequest,
  ): Promise<PaginationSchema_OrganizationRead_> {
    const urlParams: string = new URLSearchParams(
      getOrganizationsRequest,
    ).toString();
    const url: string = `${urlParams.length > 0 ? "?" : ""}${urlParams}`;

    const response: AxiosResponse = await this.client.get(url);

    return response.data;
  }

  async getOrganization(organizationId: string): Promise<OrganizationRead> {
    const response = await this.client
      .get(`/${organizationId}`)
      .catch((error) => {
        if (error.response && error.response.status === 403) {
          return;
        }
      });
    this.state.organization = response?.data;
    return response?.data;
  }

  async getOrganizationUsersName(
    organization_id: string,
    organization_user_ids: (string | null)[],
  ): Promise<PaginationSchema_OrganizationUserRead_> {
    const orgIds = {
      organization_id: organization_user_ids,
    };

    const params = new URLSearchParams();
    orgIds.organization_id.forEach((id) => {
      if (id) {
        params.append("organization_user_id", id);
      }
    });

    const urlParams: string = params.toString();
    const queryString: string = `/${organization_id}/users${urlParams.length > 0 ? "?" : ""}${urlParams}`;

    const response: AxiosResponse = await this.client.get(queryString);

    return response.data;
  }

  async registerOrgAsSP(organizationId: string): Promise<AttributeSetRead> {
    const response: AxiosResponse = await this.client.post(
      `/${organizationId}/service-providers`,
    );
    return response.data;
  }
}

export const organizationsService: OrganizationsService =
  new OrganizationsService();
