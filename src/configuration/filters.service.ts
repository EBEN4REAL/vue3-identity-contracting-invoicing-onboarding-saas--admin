import ClientService from "~/common/services/client.service";
import config from "~/mm.config.json";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  FilterCreate,
  FilterRead,
  FilterUpdate,
} from "~/service-providers/Filters/filters.types";
import { AxiosResponse } from "axios";
import { reactive } from "vue";

class FiltersService {
  client: ClientService;
  state: {
    filter: FilterRead | null;
  };

  constructor() {
    this.client = new ClientService(
      `${config.configuration.url}/service-providers`,
    );
    this.state = reactive({
      filter: null,
    });
  }

  async getFilters(
    serviceProviderId: string,
    params?: TableRequestParams,
  ): Promise<TableResponse<FilterRead>> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/filters`,
      params,
    );
    return response.data;
  }

  async getFilterById(
    serviceProviderId: string,
    filterId: string,
  ): Promise<FilterRead> {
    const response: AxiosResponse = await this.client.get(
      `/${serviceProviderId}/filters/${filterId}`,
    );
    return response.data;
  }

  async postFilter(
    form: FilterCreate,
    serviceProviderId: string,
  ): Promise<FilterRead> {
    const response: AxiosResponse = await this.client.post(
      `/${serviceProviderId}/filters`,
      form,
    );

    return response.data;
  }

  async patchFilter(
    filterId: string,
    form: FilterUpdate,
    serviceProviderId: string,
  ): Promise<FilterRead> {
    const response: AxiosResponse = await this.client.patch(
      `/${serviceProviderId}/filters/${filterId}`,
      form,
    );

    return response.data;
  }

  async deleteFilter(
    service_provider_id: string,
    filter_id: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/${service_provider_id}/filters/${filter_id}`,
    );

    return response.data;
  }
}

export const filtersService: FiltersService = new FiltersService();
