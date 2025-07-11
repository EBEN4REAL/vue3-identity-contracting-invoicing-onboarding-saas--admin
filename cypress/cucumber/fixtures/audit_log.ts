import { AuditEventRead } from "../../../src/events/events.types";

export const auditEvents: { [key: string]: AuditEventRead } = {
  "001": {
    id: "ff244e39-eb00-4799-a4b1-58647a56515f",
    date: "2024-07-09T14:18:39.930194Z",
    user_id: null,
    action: "CREATE",
    resource: {
      id: "80dd658f-820c-4fc6-b064-eab55adca3c5",
      type: "user_social_account",
      name: null,
    },
    payload: {
      ip_address: "192.168.0.1",
    },
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    oauth_client_id: "dc742b28-47f6-11ee-be56-0242ac120002",
    organization_id: null,
    service_provider_user_id: "03cd5b5d-0a6a-4a63-8bac-511e5e358e65",
  },
};
