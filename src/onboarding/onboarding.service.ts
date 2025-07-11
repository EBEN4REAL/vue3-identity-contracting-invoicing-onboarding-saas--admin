import config from "~/mm.config.json";
import { AxiosResponse } from "axios";
import {
  UserWelcomeComponentRead,
  WelcomeComponentsCreateParams,
  WelcomeComponentsRead,
  WelcomeComponentsReadParams,
} from "~/onboarding/onboarding.types";
import ClientService from "~/common/services/client.service";

class OnboardingServiceAuth {
  client: ClientService;

  constructor() {
    this.client = new ClientService(config.onboarding.url);
  }

  async getWelcomeComponents(
    params: WelcomeComponentsReadParams,
  ): Promise<WelcomeComponentsRead> {
    const response: AxiosResponse = await this.client.get(
      `/welcome/${params.app}`,
    );
    return response.data;
  }

  async createWelcomeComponent(
    params: WelcomeComponentsCreateParams,
  ): Promise<UserWelcomeComponentRead> {
    const response: AxiosResponse = await this.client.post(
      `/welcome/${params.app}/${params.component}`,
    );
    return response.data;
  }

  async deleteWelcomeComponent(
    params: WelcomeComponentsCreateParams,
  ): Promise<UserWelcomeComponentRead> {
    const response: AxiosResponse = await this.client.delete(
      `/welcome/${params.app}/${params.component}`,
    );
    return response.data;
  }
}

export const onboardingServiceAuth: OnboardingServiceAuth =
  new OnboardingServiceAuth();
