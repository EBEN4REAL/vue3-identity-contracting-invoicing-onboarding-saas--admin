import { AxiosResponse } from "axios";
import ClientService from "~/common/services/client.service";
import config from "../mm.config.json";
import {
  HubspotTokenRead,
  UserRead,
  UserSessionRead,
  UserSocialAccountRead,
  UserUpdate,
} from "~/iam/iam.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";

class UsersService {
  client: ClientService;

  constructor() {
    this.client = new ClientService(`${config.iam.url}/iam/users`);
  }

  async getUserMe(): Promise<UserRead> {
    const response: AxiosResponse = await this.client.get(`/@me`);

    return response.data;
  }

  async getUserMeSessions(
    params: TableRequestParams,
  ): Promise<TableResponse<UserSessionRead>> {
    const urlParams: string = new URLSearchParams(params).toString();
    const query: string = `${urlParams.length > 0 ? "?" : ""}${urlParams}`;

    const response: AxiosResponse = await this.client.get(
      `/@me/sessions${query}`,
    );

    return response.data;
  }

  async getUserMeSocialAccounts(): Promise<UserSocialAccountRead[]> {
    const response: AxiosResponse =
      await this.client.get(`/@me/social-accounts`);

    return response.data;
  }

  async deleteUserMeSession(token: string): Promise<string> {
    const response: AxiosResponse = await this.client.delete(
      `/@me/sessions/${token}`,
    );

    return response.data;
  }

  async deleteUserMeSocialAccount(type: string): Promise<void> {
    await this.client.delete(`/@me/social-accounts/${type}`);
  }

  async changeUserMePassword(
    oldPassword: string,
    newPassword: string,
  ): Promise<string> {
    const response: AxiosResponse = await this.client.put(`/@me/password`, {
      old: oldPassword,
      new: newPassword,
    });

    return response.data;
  }

  async updateUserMe(userUpdate: UserUpdate): Promise<UserRead> {
    const response: AxiosResponse = await this.client.patch("/@me", userUpdate);

    return response.data;
  }
  async getUserMeHubspotChatToken(): Promise<HubspotTokenRead> {
    const response: AxiosResponse = await this.client.post(
      "/@me/hubspot-visitor-token",
      null,
      { isShowError: false },
    );
    return response.data;
  }
}

export const usersService: UsersService = new UsersService();
