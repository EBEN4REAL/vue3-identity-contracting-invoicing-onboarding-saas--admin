import { RouteLocationNormalized } from "vue-router";
import { authService } from "~/auth/auth.service";
import { UserProfileMM } from "~/auth/auth.types";
import { User } from "oidc-client-ts";
import { useGettingStartedStore } from "~/stores/gettingStarted";
import { useFlag } from "@unleash/proxy-client-vue";

export const PAGE_NOT_FOUND: string = "Page Not Found";

export const isUserLoggedIn = async (
  to: RouteLocationNormalized,
): Promise<boolean> => {
  const user: User | null = await authService.getUser();
  if (user === null) {
    authService.loginToUrlState(to.fullPath);
    return false;
  }
  if (user.expired) {
    authService.logout();
    return false;
  }
  return true;
};

export const isUserSP = async (to: RouteLocationNormalized) => {
  if (await isUserLoggedIn(to)) {
    const profile: UserProfileMM | null = await authService.getProfile();

    if (profile && !profile.sp_org) {
      return {
        name: PAGE_NOT_FOUND,
      };
    }
  }
};

export const isUserMMAdmin = async (to: RouteLocationNormalized) => {
  if (await isUserLoggedIn(to)) {
    const profile: UserProfileMM | null = await authService.getProfile();

    if (profile && !authService.isUserMMAdmin(profile)) {
      return {
        name: PAGE_NOT_FOUND,
      };
    }
  }
};

export const isFeatureEnabled = (to: RouteLocationNormalized) => {
  if (!to.meta.feature || !useFlag(to.meta.feature as string).value) {
    return {
      name: PAGE_NOT_FOUND,
    };
  }
};

export const redirectToPlatform = async () => {
  const userProfile: UserProfileMM | null = await authService.getProfile();
  if (userProfile) {
    const urlParams: URLSearchParams = new URLSearchParams(
      window.location.search,
    );
    const organizationId: string | null = urlParams.get("organization_id");
    const isUserSPViewer: boolean = await authService.isUserSPViewer();
    if (organizationId && organizationId !== userProfile.org) {
      authService.loginToOrganization(organizationId);
    } else if (isUserSPViewer) {
      const gettingStartedStore = useGettingStartedStore();
      if (gettingStartedStore.isAllStepsCompleted) {
        return "/sp/accounts";
      }
      return "/sp/getting-started";
    } else if (userProfile.sp_org === null) {
      window.location.href = "/login-sc-to-sp";
    } else {
      return "/access-denied";
    }
  } else {
    authService.login();
  }
};
