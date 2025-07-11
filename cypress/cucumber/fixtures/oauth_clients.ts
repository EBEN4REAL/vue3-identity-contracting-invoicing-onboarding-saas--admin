import { OauthClientRead } from "../../../src/configuration/configuration.types";

const oauthClients: { [key: string]: OauthClientRead } = {
  "001": {
    id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
    name: "Auth Client 001",
    client_secret: "eXXKP&TP<<rUwR[x9|8s",
    authorized_redirect_uris: ["https://www.test.com"],
    url: "https://www.test.com",
    description: "Client 001",
    grant_type: "refresh_token client_credentials",
    response_type: "code",
    scopes: "openid profile email",
    created_date: "2024-10-18T10:37:15.433358",
    secrets: [
      {
        id: "ffd6b82d-9a04-4729-8270-89daee30b8c5",
        enabled: true,
        created_date: "2024-10-18T10:37:15.433358Z",
      },
      {
        id: "ffd6b82d-9a04-4729-8270-89daee30b8c6",
        enabled: true,
        created_date: "2024-10-19T10:37:15.433358Z",
      },
    ],
  },
  "001-Updated": {
    id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
    name: "Auth Client 001 UPDATED",
    authorized_redirect_uris: [
      "https://www.test-updated.com",
      "https://www.test-2.com",
    ],
    url: "https://www.test-updated.com",
    description: "Client 001 UPDATED",
    grant_type: "refresh_token authorization_code",
    response_type: "code",
    scopes: "openid profile email",
    created_date: "2024-10-18T10:37:15.433358",
    secrets: [
      {
        id: "ffd6b82d-9a04-4729-8270-89daee30b8c5",
        enabled: true,
        created_date: "2024-10-18T10:37:15.433358Z",
      },
      {
        id: "ffd6b82d-9a04-4729-8270-89daee30b8c6",
        enabled: true,
        created_date: "2024-10-19T10:37:15.433358Z",
      },
    ],
  },
  "001-one-secret": {
    id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
    name: "Auth Client 001",
    authorized_redirect_uris: ["https://www.test.com"],
    url: "https://www.test.com",
    description: "Client 001",
    grant_type: "refresh_token client_credentials",
    response_type: "code",
    scopes: "openid profile email",
    created_date: "2024-10-18T10:37:15.433358",
    secrets: [
      {
        id: "ffd6b82d-9a04-4729-8270-89daee30b8c5",
        enabled: true,
        created_date: "2024-10-18T10:37:15.433358Z",
      },
    ],
  },
  "002": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb842b",
    name: "Auth Client 002",
    description: "Client 002",
    authorized_redirect_uris: ["https://www.test.com"],
    url: "https://www.test.com",
    grant_type: "refresh_token client_credentials",
    response_type: "code",
    scopes: "openid profile email",
    client_secret: "eXXKP&TP<<rUwR[x9|8s[<#H>>HAcm`X8&6",
  },
};

export default oauthClients;
