import { components } from "./iam.schemas";

export type AuditEventRead = components["schemas"]["AuditEventRead"];

export type MetricsChart = components["schemas"]["MetricsChart"];

export type MetricsDataset = components["schemas"]["MetricsDataset"];

export type PaginationSchema_OrganizationRead_ =
  components["schemas"]["PaginationSchema_OrganizationRead_"];

export type PaginationSchema_ServiceProviderOrganizationUserRead_ =
  components["schemas"]["PaginationSchema_ServiceProviderOrganizationUserRead_"];

export type PaginationSchema_ServiceProviderOrganizationRead_ =
  components["schemas"]["PaginationSchema_ServiceProviderOrganizationRead_"];

export type ServiceProviderUserRead =
  components["schemas"]["ServiceProviderUserRead"];

export type OrganizationUsersCreate =
  components["schemas"]["OrganizationUsersCreate"];

export type ServiceProviderOrganizationUserRead =
  components["schemas"]["ServiceProviderOrganizationUserRead"];

export type ServiceProviderOrganizationUserReadWithAttributes =
  components["schemas"]["ServiceProviderOrganizationUserReadWithAttributes"];

export type AttributeRead = components["schemas"]["AttributeRead"];

export type PaginationSchema_ServiceProviderRead_ =
  components["schemas"]["PaginationSchema_ServiceProviderRead_"];

export type PaginationSchema_OrganizationUserRead_ =
  components["schemas"]["PaginationSchema_OrganizationUserRead_"];

export type OrganizationRead = components["schemas"]["OrganizationRead"];

export type OrganizationGroupRead =
  components["schemas"]["OrganizationGroupRead"];

export type OrganizationUserRead =
  components["schemas"]["OrganizationUserRead"];

export type OrganizationMetrics = components["schemas"]["OrganizationMetrics"];

export type OrganizationUnitRead =
  components["schemas"]["OrganizationUnitRead"];

export type ServiceProviderRead = components["schemas"]["ServiceProviderRead"];

export type ServiceProviderUpdate =
  components["schemas"]["ServiceProviderUpdate"];

export type ServiceProviderMetrics =
  components["schemas"]["ServiceProviderMetrics"];

export type UserRead = components["schemas"]["UserRead"];

export type UserUpdate = components["schemas"]["UserUpdate"];

export type OrganizationUserStatus =
  components["schemas"]["OrganizationUserStatus"];

export type OrganizationUserStatusUpdate =
  components["schemas"]["OrganizationUserStatusUpdate"];

export type ServiceProviderOrganizationRead =
  components["schemas"]["ServiceProviderOrganizationRead"];

export type OrganizationReadWithAttributes =
  components["schemas"]["OrganizationReadWithAttributes"];

export type OrganizationUserJobRole = components["schemas"]["JobRole"];

export type Industry = components["schemas"]["Industry"];

export type OrganizationUserStatusMap = {
  [key: OrganizationUserStatus]: string;
};

export type OrganizationUserJobRoleMap = {
  [key: OrganizationUserJobRole]: string;
};

export type UserSessionRead = components["schemas"]["UserSessionRead"];

export type UserSocialAccountRead =
  components["schemas"]["UserSocialAccountRead"];

export type PasswordRequirementRead =
  components["schemas"]["PasswordRequirementRead"];

export type PasswordRequirementExtended = PasswordRequirementRead & {
  message: string;
};

export type UploadLogo =
  components["schemas"]["Body_upload_service_provider_logo_service_providers__service_provider_id__logo_post"];

export type PasswordRequirementsMap = {
  [key: string]: {
    message: (param: number | string) => string;
    validator: (
      value: string,
      param: number | string,
      username: string,
    ) => boolean;
  };
};

export type OrganizationImportRead =
  components["schemas"]["OrganizationImportRead"];

export type SyncStatus = components["schemas"]["SyncStatus"];

export type AccessEvaluationBaseRead =
  components["schemas"]["AccessEvaluationBaseRead"];

export type AccessEvaluationRead =
  components["schemas"]["AccessEvaluationRead"];

export type PolicyReadIAM = components["schemas"]["PolicyRead"];

export type AgreementReadIAM = components["schemas"]["AgreementRead"];

export type HubspotTokenRead = {
  expire_date: string;
  token: string;
};
