import { Given } from "cypress-cucumber-preprocessor/steps";
import {
  OrganizationImportRead,
  PaginationSchema_ServiceProviderRead_,
  ServiceProviderOrganizationRead,
} from "../../../../src/iam/iam.types";
import serviceProviders, {
  ServiceProvider,
} from "../../fixtures/service_providers";
import config from "../../../../src/mm.config.json";
import {
  servicesProvidersMetrics,
  servicesProvidersMetricsActiveUsers,
  servicesProvidersMetricsFailedLogins,
  servicesProvidersMetricsSignups,
} from "../../fixtures/service-provider/metrics";
import {
  organizations,
  serviceProviderOrganizations,
} from "../../fixtures/service-provider/organizations";
import {
  customers,
  importing,
  serviceProviderUsers,
} from "../../fixtures/service-provider/customers";
import { settings } from "../../fixtures/settings";
import { context } from "../app";

Given(
  "the IAM Service Provider Metrics request has been intercepted to return the Metrics for Service Provider {string}",
  (serviceProviderId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderId];
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/service-providers/${serviceProvider.id}/metrics`,
      {
        statusCode: 200,
        body: servicesProvidersMetrics[serviceProviderId],
      },
    );
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/service-providers/${serviceProvider.id}/metrics/active-users?*`,
      {
        statusCode: 200,
        body: servicesProvidersMetricsActiveUsers[serviceProviderId],
      },
    );
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/service-providers/${serviceProvider.id}/metrics/signups?*`,
      {
        statusCode: 200,
        body: servicesProvidersMetricsSignups[serviceProviderId],
      },
    );
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/service-providers/${serviceProvider.id}/metrics/failed-logins?*`,
      {
        statusCode: 200,
        body: servicesProvidersMetricsFailedLogins[serviceProviderId],
      },
    );
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Service Provider {string}",
  (serviceProviderFixtureId: string): void => {
    const serviceProvider: ServiceProvider =
      serviceProviders[serviceProviderFixtureId];
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProvider.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: serviceProvider,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return All Service Providers",
  (): void => {
    const serviceProvidersPrepared: ServiceProvider[] =
      Object.values(serviceProviders);
    const serviceProvidersPagination: PaginationSchema_ServiceProviderRead_ = {
      offset: 0,
      limit: 10,
      results: serviceProvidersPrepared,
      size:
        serviceProvidersPrepared.length > 10
          ? 10
          : serviceProvidersPrepared.length,
      total: serviceProvidersPrepared.length,
    };
    const url: string = `${config.iam.url}/iam/service-providers`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: serviceProvidersPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Organizations {string} for Service Provider {string}",
  (filterId: string, serviceProviderId: string): void => {
    const orgIdsArr: string[] = filterId.split(",");
    const customerPagination = {
      offset: 0,
      limit: 10,
      results: orgIdsArr.map((customer: string) => customers[customer]),
      size: orgIdsArr.length > 10 ? 10 : orgIdsArr.length,
      total: orgIdsArr.length,
    };
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: customerPagination,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to create customer {string} for Service Provider {string}",
  (organization: string, serviceProviderId: string): void => {
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations*`;
    cy.intercept("POST", url, {
      statusCode: 201,
      body: {
        organization: {
          name: organization,
        },
      },
    });
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Organizations {string} for Service Provider {string} for Autocomplete",
  (filterId: string, serviceProviderId: string): void => {
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations?limit=50&offset=0*`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: customers[filterId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Organization with id {string} for Service Provider {string}",
  (organizationId: string, serviceProviderId: string): void => {
    const orgId = organizations[organizationId]?.results[0].organization.id;
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/${orgId}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: organizations[organizationId]?.results[0],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM GET Service Provider Organization request has been intercepted to return the Organization {string} for Service Provider with ID {string}",
  (organizationId: string, serviceProviderId: string): void => {
    const serviceProviderOrganization: ServiceProviderOrganizationRead =
      serviceProviderOrganizations[organizationId];
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/${serviceProviderOrganization.organization.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: serviceProviderOrganization,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Users {string} for Service Provider {string} and Organization {string}",
  (userId: string, serviceProviderId: string, organizationId: string): void => {
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/${organizationId}/users?limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: serviceProviderUsers[userId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Organization Users {string} for Service Provider {string}",
  (userId: string, serviceProviderId: string): void => {
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organization-users?limit=10&offset=0`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: serviceProviderUsers[userId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Organization User {string} for Service Provider {string}",
  (orgUserId: string, serviceProviderId: string): void => {
    const org = serviceProviderUsers[orgUserId]?.results[0];
    const url: string = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organization-users/${org?.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: org,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the SP Users {string} for Service Provider {string} and Organization {string}",
  (
    service_provider_user_id: string,
    serviceProviderId: string,
    organizationId: string,
  ): void => {
    const spUserId =
      serviceProviderUsers[service_provider_user_id]?.results[0].id;
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/${organizationId}/users/${spUserId}`,
      {
        statusCode: 200,
        body: serviceProviderUsers[service_provider_user_id]?.results[0],
      },
    );
  },
);

Given(
  "the IAM Service Providers request has been intercepted to return the Organization with Service Provider {string} for filter {string} and with ids {string}",
  (
    serviceProviderId: string,
    filterId: string,
    organization_id: string,
  ): void => {
    cy.intercept(
      "GET",
      `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations?organization_id=${organization_id}`,
      {
        statusCode: 200,
        body: organizations[filterId],
      },
    );
  },
);

Given(
  "the IAM Service Providers has been intercepted to upload a logo for Service Provider {string}",
  (serviceProviderId: string): void => {
    cy.intercept(
      "POST",
      `${config.iam.url}/iam/service-providers/${serviceProviderId}/logo`,
      {
        statusCode: 201,
        body: {},
      },
    );
  },
);

Given(
  "the IAM Service Providers has been intercepted to update button colors for Service Provider {string}",
  (serviceProviderId: string): void => {
    cy.intercept(
      "PATCH",
      `${config.iam.url}/iam/service-providers/${serviceProviderId}`,
      {
        statusCode: 201,
        body: settings,
      },
    );
  },
);

Given(
  "the IAM Service Providers Organization Imports has been intercepted to return error 409 for Service provider {string}",
  (serviceProviderId: string): void => {
    const url = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/imports`;
    cy.intercept("POST", url, {
      statusCode: 409,
      body: {
        detail: "Conflict",
      },
    });
  },
);

Given(
  "the IAM Service Providers Organization Imports has been intercepted to return error 400 for Service provider {string}",
  (serviceProviderId: string): void => {
    const url = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/imports`;
    cy.intercept("POST", url, {
      statusCode: 400,
      body: {
        detail: "Bad Request",
      },
    });
  },
);

Given(
  "the IAM Service Providers Organization Imports has been intercepted to return Accepted for import {string} for Service provider {string}",
  (importFixtureId: string, serviceProviderId: string): void => {
    const importRead: OrganizationImportRead = importing[importFixtureId];
    const url = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/imports`;
    cy.intercept("POST", url, {
      statusCode: 202,
      body: importRead,
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the IAM Service Providers Organization Imports has been intercepted to return status for import {string} for Service provider {string}",
  (importFixtureId: string, serviceProviderId: string): void => {
    const importRead: OrganizationImportRead = importing[importFixtureId];
    const url = `${config.iam.url}/iam/service-providers/${serviceProviderId}/organizations/imports/${importRead.id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: importRead,
    }).as(url);
    context.aliases.push(url);
  },
);
