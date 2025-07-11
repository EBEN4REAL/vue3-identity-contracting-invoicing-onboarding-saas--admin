import { components } from "./events.schemas";

export type EventType = components["schemas"]["EventType"];

export type EventPayloadRequest = components["schemas"]["EventPayloadRequest"];

export type EventRead = components["schemas"]["EventRead"];

export type AuditEventRead = components["schemas"]["AuditEventRead"];

export type PaginationSchema_EventRead_ =
  components["schemas"]["PaginationSchema_EventRead_"];
export type AgreementMetricsRead =
  components["schemas"]["AgreementMetricsRead"];

export type TimeBasedValuesType = {
  startTimeValue: number;
  endTimeValue: number;
};

export type CustomerOrganizationMetricsRead =
  components["schemas"]["CustomerOrganizationMetricsRead"];
