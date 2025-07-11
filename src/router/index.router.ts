import { createRouter, createWebHistory, Router } from "vue-router";
import config from "~/mm.config.json";
import Home from "~/common/Home.vue";
import PageNotFound from "~/common/PageNotFound.vue";
import AppLayout from "~/mm_ui_kit/src/layouts/AppLayout.vue";
import AuthLayout from "~/mm_ui_kit/src/layouts/AuthLayout.vue";
import EmptyLayout from "~/mm_ui_kit/src/layouts/EmptyLayout.vue";
import { hideMobileNav } from "~/mm_ui_kit/src/helpers/toggleMobileNav";
import {
  isFeatureEnabled,
  isUserMMAdmin,
  isUserSP,
  PAGE_NOT_FOUND,
  redirectToPlatform,
} from "./middleware.router";
import Logout from "~/auth/Logout.vue";
import LogoutCallback from "~/auth/LogoutCallback.vue";
import { useRouteStore } from "~/stores/routeStore";

const routes = [
  // Landing page
  {
    path: "/",
    meta: { layout: AuthLayout },
    component: Home,
    beforeEnter: [redirectToPlatform],
  },
  // Auth routes
  {
    path: "/authorized",
    meta: { layout: AuthLayout },
    component: () => import("../auth/OAuthAuthorizeResponse.vue"),
  },
  {
    path: "/signup",
    meta: { layout: AuthLayout },
    component: () => import("../auth/Signup.vue"),
  },
  {
    path: "/login/support",
    meta: { layout: AuthLayout },
    component: () => import("../auth/LoginAsSupport.vue"),
    props: true,
  },
  {
    path: "/logout",
    meta: { layout: AuthLayout },
    component: Logout,
  },
  {
    path: "/logout/callback",
    meta: { layout: AuthLayout },
    component: LogoutCallback,
  },
  // SC Org to SP Journey
  {
    path: "/login-sc-to-sp",
    meta: { layout: AuthLayout },
    component: () => import("../auth/LoginSCToSP.vue"),
    props: true,
  },
  // Access Denied Page
  {
    path: "/access-denied",
    meta: { layout: EmptyLayout },
    name: "Access Denied",
    component: () => import("~/auth/AccessDenied.vue"),
    props: true,
  },
  // Service Provider
  {
    path: "/sp",
    meta: {
      layout: AppLayout,
      platform: "sp",
    },
    children: [
      {
        name: "GettingStarted",
        path: "getting-started",
        component: () => import("~/onboarding/getting-started/Index.vue"),
      },
      {
        name: "ConfigPublishOverview",
        path: "configuration/overview/publish",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: false,
          hasBreadcrumbs: true,
        },
        component: () =>
          import("~/service-providers/ConfigPublish/Overview.vue"),
      },
      {
        path: "",
        redirect: "/sp/accounts",
      },
      {
        path: "dashboard",
        component: () => import("~/service-providers/Dashboard.vue"),
      },
      {
        path: ":service_provider_id/applications/:application_id",
        name: "ApplicationDetails",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/ApplicationDetails/ApplicationDetails.vue"
          ),
      },
      {
        path: "application/role-based-wizard",
        name: "ApplicationRoleBasedWizard",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/Applications/ApplicationRoleBasedWizard/Index.vue"
          ),
      },
      {
        path: ":service_provider_id/applications/new",
        name: "ApplicationDetailsNew",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/ApplicationDetails/ApplicationDetailsNew.vue"
          ),
      },
      {
        path: ":service_provider_id/resources/new",
        name: "ResourceDetailsNew",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/Resources/ResourceDetails/ResourceDetailsNew.vue"
          ),
        props: true,
      },
      {
        path: ":service_provider_id/resources/:resource_id",
        name: "ResourceDetails",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/Resources/ResourceDetails/ResourceDetails.vue"
          ),
        props: true,
      },
      {
        path: ":service_provider_id/filters/:filter_id",
        name: "FilterDetails",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import("~/service-providers/Filters/Filter/Filter.vue"),
      },
      {
        name: "FilterDetailsNew",
        path: ":service_provider_id/filters/new",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import("~/service-providers/Filters/Filter/FilterNew.vue"),
        props: true,
      },
      {
        path: ":service_provider_id/policy-types/new",
        name: "NewPolicyType",
        component: () =>
          import("~/service-providers/PolicyTypeDetail/PolicyTypeDetail.vue"),
        props: true,
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
      },
      {
        path: ":service_provider_id/policy-types/:policy_type_id",
        name: "PolicyTypeDetail",
        component: () =>
          import("~/service-providers/PolicyTypeDetail/PolicyTypeDetail.vue"),
        props: true,
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
      },
      //new routes for configuration
      {
        name: "Applications",
        path: "/sp/applications",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Applications.vue"),
      },
      {
        name: "Filters",
        path: "/sp/config/filters",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Filters/Filters.vue"),
      },
      {
        name: "Policies",
        path: "/sp/policies",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import("~/service-providers/ConfigurationTabs/Policies/Policies.vue"),
      },
      {
        name: "Roles",
        path: "/sp/roles",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/ConfigRoles.vue"),
      },
      {
        name: "Resources",
        path: "/sp/config/resources",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Resources/Resources.vue"),
      },
      {
        name: "Access Licenses",
        path: "/sp/config/access-licenses",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import("~/service-providers/AccessLicenses/AccessLicenses.vue"),
      },
      {
        name: "Legal Documents",
        path: "/sp/config/legal-documents",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import("~/service-providers/LegalDocuments/LegalDocuments.vue"),
      },
      {
        name: "Attribute Sets",
        path: "/sp/config/attribute-sets",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import("~/service-providers/AttributeSets/AttributeSets.vue"),
      },
      {
        name: "ResourceAttributes",
        path: "/sp/config/attributes",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import(
            "~/service-providers/ResourceAttributes/ResourceAttributes.vue"
          ),
      },
      {
        name: "Plans",
        path: "/sp/plans",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/policies/Plans.vue"),
      },
      {
        name: "Pricing Page",
        path: "/sp/config/pricing",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Pricing/Pricing.vue"),
      },
      {
        path: "events",
        component: () => import("~/events/EventsServiceProvider.vue"),
      },
      {
        path: "logs",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/logs/Index.vue"),
      },
      {
        name: "AccessLogDetails",
        path: "logs/:id",
        meta: {
          layoutName: "CommonPageLayout",
          backTo: {
            label: "Logs",
            link: "/sp/logs",
          },
        },
        component: () => import("~/logs/Tabs/AccessLog/Details.vue"),
      },
      {
        path: "plans",
        name: "PlansOverview",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Plans/Plans.vue"),
      },
      {
        path: "subscriptions",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Licenses/Licenses.vue"),
      },
      {
        path: "/sp/invoices",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Invoices/Invoices.vue"),
      },
      {
        path: "/sp/applications",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import("~/service-providers/Applications/Applications.vue"),
      },
      {
        path: "/sp/contracting",
        name: "Contracting",
        meta: { layoutName: "CommonPageLayout" },
        component: () =>
          import("~/service-providers/Contracting/Contracting.vue"),
      },
      {
        path: "Payments",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Payments/Payments.vue"),
      },
      {
        path: "subscription/:license_id",
        name: "LicenseDetails",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: false,
          backTo: {
            label: "Subscriptions",
            link: "/sp/subscriptions",
          },
        },
        component: () =>
          import("~/service-providers/Licenses/LicenseDetails.vue"),
        props: true,
      },
      {
        name: "PlanDetailsNew",
        path: ":service_provider_id/plans/new",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () => import("~/policies/License/LicenseNew.vue"),
      },
      {
        name: "PlanDetails",
        path: ":service_provider_id/plans/:license_id",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () => import("~/policies/License/License.vue"),
      },
      {
        name: "SPAccessLicensesNew",
        path: ":service_provider_id/licenses/new",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () => import("~/policies/License/LicenseNew.vue"),
      },
      {
        name: "accessLicenseDetails",
        path: ":service_provider_id/licenses/:license_id",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () => import("~/policies/License/License.vue"),
      },
      {
        path: "Settings",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/Settings/Settings.vue"),
      },
      {
        name: "SPLegalDocumentsCreate",
        path: ":service_provider_id/legal-documents/new",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/LegalDocumentsDetail/LegalDocumentsEdit.vue"
          ),
      },
      {
        name: "LegalDocumentDetails",
        path: ":service_provider_id/legal-documents/:legalDocumentTypeId",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/LegalDocumentsDetail/LegalDocumentDetails.vue"
          ),
      },
      {
        name: "AttributeSetsDetails",
        path: ":service_provider_id/attribute-sets/:attribute_set_id",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/AttributeSets/AttributeSet/AttributeSet.vue"
          ),
      },
      {
        name: "SPAttributeSetsNew",
        path: ":service_provider_id/attribute-sets/new",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          hasBreadcrumbs: true,
        },
        component: () =>
          import(
            "~/service-providers/AttributeSets/AttributeSet/AttributeSetNew.vue"
          ),
      },
      {
        name: "ServiceProviderRoles",
        path: ":service_provider_id/roles",
        meta: {
          layoutName: "CommonPageLayout",
        },
        component: () => import("~/service-providers/Roles/Roles.vue"),
        props: true,
      },
      {
        name: "Accounts",
        meta: { layoutName: "CommonPageLayout" },
        path: "/sp/accounts",
        component: () =>
          import(
            "~/service-providers/AccessControl/Organizations/Organizations.vue"
          ),
      },
      {
        path: "/sp/accounts/:id",
        meta: {
          layoutName: "CommonPageLayout",
          backTo: {
            label: "Accounts",
            link: "/sp/accounts",
          },
        },
        component: () =>
          import(
            "~/service-providers/AccessControl/Organizations/OrganizationDetails.vue"
          ),
        props: true,
      },
      {
        path: "/sp/accounts/:organizationId/user_details/:id",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          backTo: {
            label: "Accounts",
            link: "/sp/accounts",
            withParams: true,
          },
        },
        component: () =>
          import(
            "~/service-providers/AccessControl/Organizations/UserDetails/UserDetails.vue"
          ),
        props: true,
      },
      {
        name: "Users",
        path: "/sp/users",
        meta: { layoutName: "CommonPageLayout" },
        component: () => import("~/service-providers/AccessControl/Users.vue"),
      },
      {
        path: "/sp/users/:organizationId/user_details/:id",
        meta: {
          layoutName: "CommonPageLayout",
          hasIcon: true,
          backTo: {
            label: "Users",
            link: "/sp/users",
            withParams: true,
          },
        },
        component: () =>
          import(
            "~/service-providers/AccessControl/Organizations/UserDetails/UserDetails.vue"
          ),
        props: true,
      },
      // Access Control
      {
        path: "access-control",
        meta: { layoutName: "CommonPageLayout" },
        children: [
          {
            name: "RoleBased",
            path: "role-based",
            component: () =>
              import("~/service-providers/AccessControl/RoleBased/Index.vue"),
          },
          {
            name: "PolicyBased",
            path: "policy-based",
            component: () =>
              import("~/service-providers/AccessControl/PolicyBased/Index.vue"),
          },
          {
            name: "AccessLicense",
            path: "access-license",
            component: () =>
              import(
                "~/service-providers/AccessControl/AccessLicense/Index.vue"
              ),
          },
          {
            path: "access-license/:license_id",
            name: "AccessLicenseDetails",
            meta: {
              hasIcon: false,
              backTo: {
                label: "Access Licenses",
                link: "/sp/access-control/access-license#allocated_licenses",
              },
            },
            component: () =>
              import("~/service-providers/Licenses/LicenseDetails.vue"),
          },
        ],
      },
      {
        name: "Permissions",
        path: ":service_provider_id/permissions",
        meta: {
          layoutName: "CommonPageLayout",
        },
        component: () =>
          import("~/service-providers/Permissions/Permissions.vue"),
        props: true,
      },
      {
        path: "wizards",
        meta: {
          feature: "wizards",
        },
        children: [
          {
            name: "Basic Application Overview",
            path: "basic-application/:wizard_id",
            component: () => import("~/wizards/BasicApplication.vue"),
          },
          {
            name: "Basic Application",
            path: "basic-application",
            component: () => import("~/wizards/BasicApplication.vue"),
          },
        ],
        beforeEnter: [isFeatureEnabled],
      },
    ],
    beforeEnter: [isUserSP],
  },
  // Dynamic form POC page
  {
    path: "/veriam-user-experience",
    meta: {
      layout: AppLayout,
      layoutName: "CommonPageLayout",
      hasIcon: false,
      hasBreadcrumbs: true,
    },
    component: () => import("~/VUXPocPage.vue"),
    beforeEnter: [isUserMMAdmin],
  },

  // UI Components Library
  {
    path: "/components-library",
    meta: { layout: EmptyLayout },
    name: "ComponentsLibrary",
    component: config.componentsLibEnabled
      ? () => import("~/components-library/MMComponentsLibrary.vue")
      : PageNotFound,
    beforeEnter: [isUserMMAdmin],
  },
  // 404
  {
    path: "/:pathMatch(.*)*",
    meta: { layout: EmptyLayout },
    name: PAGE_NOT_FOUND,
    component: PageNotFound,
  },
];

const router: Router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  hideMobileNav();
  next();
});

router.beforeEach((to, from, next) => {
  const routeStore = useRouteStore();
  routeStore.$state.previousRouteName = from.name;
  routeStore.$state.previousRoutePath = from.path;
  next();
});

// Reload the page if the module fails to load on new build - set maxRetries to avoid infinite loop
const maxRetries = 2;

router.onError((error, to) => {
  if (
    error.message.includes("Failed to fetch dynamically imported module") ||
    error.message.includes("Importing a module script failed")
  ) {
    let retryCount = parseInt(sessionStorage.getItem("retryCount") || "0", 10);

    if (retryCount < maxRetries) {
      retryCount++;
      sessionStorage.setItem("retryCount", retryCount.toString());
      window.location.href = to.fullPath;
    } else {
      console.error("Failed to load module after multiple attempts:", error);
      sessionStorage.removeItem("retryCount");
    }
  }
});

export default router;
