import { defineAsyncComponent, Ref, ref } from "vue";
import { TypeComponentMapEntry } from "./types";
import { authService } from "~/auth/auth.service";
import { UserProfileMM } from "~/auth/auth.types";
import config from "~/mm.config.json";

const userProfile: Ref<UserProfileMM | null> = ref(null);

const getUserProfile = async () => {
  userProfile.value = await authService.getProfile();
};

await getUserProfile();

export const welcomeComponentsMap: Record<string, TypeComponentMapEntry> = {
  ConnectYourApplication: {
    component: defineAsyncComponent(
      () => import("./components/ConnectYourApplication.vue"),
    ),
    icon: "connect-app",
    title: "Connect your application",
    buttons: [
      {
        label: "Configure Application",
        icon: "arrow-right-fill",
        path: "/sp/applications",
        props: { "icon-height": "12px" },
      },
    ],
  },
  ConfigureAccessRequirements: {
    component: defineAsyncComponent(
      () => import("./components/ConfigureAccessRequirements.vue"),
    ),
    icon: "arrows-right-left",
    title: "Configure access requirements",
    buttons: [
      {
        label: "Configure Access",
        icon: "arrow-right-fill",
        path: "/sp/access-control/policy-based",
        hash: "#Policies",
        props: { "icon-height": "12px" },
      },
    ],
  },
  IntegrateAndGoLive: {
    component: defineAsyncComponent(
      () => import("./components/IntegrateAndGoLive.vue"),
    ),
    icon: "integrate",
    title: "Integrate & go-live",
    buttons: [],
  },
  AddYourCustomers: {
    component: defineAsyncComponent(
      () => import("./components/AddYourCustomers.vue"),
    ),
    icon: "setup-organization-structure",
    title: "Add your customers",
    badge: {
      text: "Optional",
      status: "inactive",
    },
    buttons: [
      {
        label: "Add Customers",
        icon: "arrow-right-fill",
        path: "/sp/accounts",
        props: { "icon-height": "12px" },
      },
    ],
  },
  ConfigurePlans: {
    component: defineAsyncComponent(
      () => import("./components/ConfigurePlans.vue"),
    ),
    icon: "shopping-cart",
    title: "Configure your subscription plans",
    badge: {
      text: "Optional",
      status: "inactive",
    },
    buttons: [
      {
        label: "Configure plans",
        icon: "arrow-right-fill",
        path: "/sp/plans",
        props: { "icon-height": "12px" },
      },
    ],
  },
  SetupPricingPage: {
    component: defineAsyncComponent(
      () => import("./components/SetupPricingPage.vue"),
    ),
    icon: "clipboard-document-list",
    title: "Set up your pricing page",
    badge: {
      text: "Optional",
      status: "inactive",
    },
    buttons: [
      {
        label: "Set up pricing page",
        icon: "arrow-right-fill",
        path: "/sp/config/pricing",
        props: { "icon-height": "12px" },
      },
    ],
  },
  SetupYourOrganization: {
    component: defineAsyncComponent(
      () => import("./components/SetupYourOrganization.vue"),
    ),
    icon: "invite-colleagues",
    title: "Setup your organization & invite your colleagues",
    badge: {
      text: "Optional",
      status: "inactive",
    },
    buttons: [
      {
        label: "Go to Customer Portal",
        icon: "arrow-top-right-square-outline",
        path: config.scApp.url,
        props: { iconStroke: "#0F172A" },
        opensInNewTab: true,
      },
    ],
  },
};
