<script setup lang="ts">
import {
  onMounted,
  ref,
  Ref,
  computed,
  ComputedRef,
  onUnmounted,
  watch,
} from "vue";
import { authService } from "~/auth/auth.service";
import config from "~/mm.config.json";
import { useFlag } from "@unleash/proxy-client-vue";
import { toggleMobileNav } from "~/mm_ui_kit/src/helpers/toggleMobileNav";
import { useGettingStartedStore } from "~/stores/gettingStarted";
import { useTranslation } from "i18next-vue";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import MMOrgSwitcher from "./MMOrgSwitcher.vue";
import {
  TypeNavigationItemsInCategory,
  TypeNavigationItem,
} from "~/mm_ui_kit/src/components/MMAppNavigationItem/types";
import { Menu } from "~/common/components/app/types";
import { useRouter } from "vue-router";
const router = useRouter();
import { useRoute } from "vue-router";
import { useUiStore } from "~/stores/useUiStore";
const organizationId: Ref<string | null> = ref(null);
const serviceProviderId: Ref<string | null> = ref(null);
const isMMAdmin: Ref<boolean> = ref(false);
const isSPViewer: Ref<boolean> = ref(false);
const isSCViewer: Ref<boolean> = ref(false);
const isSupportViewer: Ref<boolean> = ref(false);
const isSPOrg: Ref<boolean> = ref(false);

const gettingStartedStore = useGettingStartedStore();
const uiStore = useUiStore();

// feature flags
const subscriptionsEnabled = useFlag("subscriptions");
const legalDocsEnabled = useFlag("legal_documents");
const resourcesEnabled = useFlag("resources_config");
const attributeSetsEnabled = useFlag("attribute_sets");
const pricingEnabled = useFlag("self_service_plan_page");
const plansEnabled = useFlag("plans");

const { t } = useTranslation();
const route = useRoute();

const isMobile: Ref<boolean> = ref(window.innerWidth < 1025);
const currentMenu: Ref<Menu> = ref(Menu.MAIN);
const routeMenuMap: Ref<Map<string, Menu>> = ref(new Map());

const handleResize = () => {
  isMobile.value = window.innerWidth < 1025;
};

const mainNavigationItems: ComputedRef<TypeNavigationItemsInCategory[]> =
  computed(() => [
    {
      categoryLabel: null,
      items: [
        {
          to: "/sp/getting-started",
          label: t("getting_started.nav_label"),
          icon: sectionIcons["gettingStarted"],
          isHidden: gettingStartedStore.isAllStepsCompleted,
          menuType: Menu.MAIN,
        },
        {
          to: "/sp/accounts",
          label: t("accounts.nav_label"),
          icon: sectionIcons["allOrganizations"],
          menuType: Menu.MAIN,
        },
        {
          id: "app-navigation-access-control-users",
          to: "/sp/users",
          label: t("users.nav_label"),
          icon: sectionIcons["users"],
          menuType: Menu.MAIN,
        },
      ],
    },
    {
      categoryLabel: t("access_control.nav_label"),
      items: [
        {
          to: "/sp/applications",
          label: t("applications.nav_label"),
          icon: sectionIcons["applications"],
          menuType: Menu.MAIN,
        },
        {
          to: "/sp/access-control/role-based",
          label: t("access_control.role_based.nav_label"),
          icon: sectionIcons["roleBased"],
          menuType: Menu.MAIN,
        },
        {
          to: "/sp/access-control/policy-based",
          label: t("access_control.policy_based.nav_label"),
          icon: sectionIcons["policyBased"],
          menuType: Menu.MAIN,
        },
      ],
    },
    {
      categoryLabel: t("subscriptions.nav_label"),
      items: [
        {
          to: "/sp/subscriptions",
          label: t("subscriptions.subscriptions.nav_label"),
          icon: sectionIcons["subscriptions"],
          isHidden: !subscriptionsEnabled.value,
          menuType: Menu.MAIN,
        },
        {
          to: "/sp/invoices",
          label: t("subscriptions.invoices.nav_label"),
          icon: sectionIcons["invoices"],
          menuType: Menu.MAIN,
        },
        {
          to: "/sp/payments",
          label: t("subscriptions.payments.nav_label"),
          icon: sectionIcons["payments"],
          menuType: Menu.MAIN,
        },
        {
          to: "/sp/plans",
          label: t("subscriptions.plans.nav_label"),
          icon: sectionIcons["plans"],
          menuType: Menu.MAIN,
        },
      ],
    },
  ]);

const advancedNavigationItems: ComputedRef<TypeNavigationItemsInCategory[]> =
  computed(() => [
    {
      categoryLabel: t("identity.nav_label"),
      isHidden: !attributeSetsEnabled.value,
      items: [
        {
          to: "/sp/config/attribute-sets",
          label: t("configuration.attribute_sets.nav_label"),
          icon: sectionIcons["attributeSets"],
          isHidden: !attributeSetsEnabled.value,
          menuType: Menu.ADVANCED,
        },
      ],
    },
    {
      categoryLabel: t("access_control.nav_label"),
      items: [
        {
          to: "/sp/applications",
          label: t("configuration.applications.nav_label"),
          icon: sectionIcons["applications"],
          isHidden: !attributeSetsEnabled.value,
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/access-control/policy-based",
          label: t("configuration.policies.nav_label"),
          icon: sectionIcons["policies"],
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/access-control/role-based",
          label: t("configuration.roles.nav_label"),
          icon: sectionIcons["roleBased"],
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/config/resources",
          label: t("configuration.resources.nav_label"),
          icon: sectionIcons["resources"],
          isHidden: !resourcesEnabled.value,
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/config/attributes",
          label: t("configuration.resource_attributes.nav_label"),
          icon: sectionIcons["resourceAttributes"],
          menuType: Menu.ADVANCED,
        },
      ],
    },
    {
      categoryLabel: t("subscriptions.nav_label"),
      items: [
        {
          to: "/sp/plans",
          label: t("configuration.plans.nav_label"),
          icon: sectionIcons["plans"],
          isHidden: !plansEnabled.value,
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/config/pricing",
          label: t("configuration.pricing_page.nav_label"),
          icon: sectionIcons["pricing"],
          isHidden: !pricingEnabled.value,
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/contracting",
          label: t("contracting.nav_label"),
          icon: sectionIcons["documents"],
          isHidden: !legalDocsEnabled.value,
          menuType: Menu.ADVANCED,
        },
      ],
    },
    {
      categoryLabel: t("oidc_claims.nav_label"),
      items: [
        {
          to: `/sp/${serviceProviderId.value}/roles`,
          label: t("oidc_claims.roles.nav_label"),
          icon: sectionIcons["oidcClaimsRoles"],
          menuType: Menu.ADVANCED,
        },
        {
          to: `/sp/${serviceProviderId.value}/permissions`,
          label: t("oidc_claims.permissions.nav_label"),
          icon: sectionIcons["oidcClaimsPermissions"],
          menuType: Menu.ADVANCED,
        },
      ],
    },
    {
      categoryLabel: t("other.nav_label"),
      items: [
        {
          to: "/sp/config/filters",
          label: t("configuration.filters.nav_label"),
          icon: sectionIcons["filters"],
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/settings",
          label: t("settings.nav_label"),
          icon: sectionIcons["settings"],
          menuType: Menu.ADVANCED,
        },
        {
          to: "/sp/logs",
          label: t("logs.nav_label"),
          icon: sectionIcons["logs"],
          menuType: Menu.ADVANCED,
        },
      ],
    },
  ]);

const scPortalUrl: ComputedRef<string> = computed(() =>
  organizationId.value
    ? `${config.scApp.url}?organization_id=${organizationId.value}`
    : config.app.url,
);

const isProvideSupportVisible: ComputedRef<boolean> = computed(
  () => isMMAdmin.value && !isSupportViewer.value,
);

const mmAppNavigationMainClassList = computed(() => [
  "mm-app-navigation--main",
  { "mm-app-navigation--active": currentMenu.value === Menu.MAIN },
]);

const mmAppNavigationAdvancedClassList = computed(() => [
  "mm-app-navigation--advanced",
  { "mm-app-navigation--active": currentMenu.value === Menu.ADVANCED },
]);

const isAdvancedNavigationCategoryLabelVisible = (
  advancedNavigationItemCategoryData: TypeNavigationItemsInCategory,
) =>
  advancedNavigationItemCategoryData.categoryLabel &&
  !advancedNavigationItemCategoryData.isHidden;

const setInitialData = async () => {
  const [spViewer, scViewer, profile] = await Promise.all([
    authService.isUserSPViewer(),
    authService.isUserOrgViewer(),
    authService.getProfile(),
  ]);

  isSPViewer.value = spViewer;
  isSCViewer.value = scViewer;

  if (profile?.onboarding_completed) {
    organizationId.value = profile.org || null;
    serviceProviderId.value = profile.sp_org || null;
    isMMAdmin.value = authService.isUserMMAdmin(profile);
    isSupportViewer.value = authService.isUserMMSupport(profile);
    isSPOrg.value = authService.isSPOrg(profile);
  }
};

const onSetCurrentMenu = (menuType: Menu) => {
  currentMenu.value = menuType;
};

const menuPreferencesStorage = {
  get(route?: string): Record<string, Menu> | Menu | null {
    try {
      const menuPreferences = JSON.parse(
        localStorage.getItem("menuPreferences") || "{}",
      );
      return menuPreferences[route] || null;
    } catch (e) {
      console.error("Failed to get menu preference", e);
      return null;
    }
  },

  save(route: string, menuType: Menu): void {
    try {
      const menuPreferences = JSON.parse(
        localStorage.getItem("menuPreferences") || "{}",
      );
      menuPreferences[route] = menuType;
      localStorage.setItem("menuPreferences", JSON.stringify(menuPreferences));
    } catch (e) {
      console.error("Failed to save menu preference", e);
    }
  },
};

const handleNavigationClick = (item: TypeNavigationItem) => {
  routeMenuMap.value.set(item.to, item.menuType);
  menuPreferencesStorage.save(item.to, item.menuType);
  router.push(item.to);
};
const flattenedMainItems = computed(() =>
  mainNavigationItems.value.flatMap((category) => category.items),
);
const flattenedAdvancedItems = computed(() =>
  advancedNavigationItems.value.flatMap((category) => category.items),
);
const determineActiveMenu = () => {
  let savedMenu = routeMenuMap.value.get(route.path);

  if (!savedMenu) {
    savedMenu = menuPreferencesStorage.get(route.path);
  }

  if (savedMenu) {
    currentMenu.value = savedMenu;
    return;
  }

  const isMainMenuItemActive = Boolean(
    flattenedMainItems.value.find((item) => route.path.startsWith(item.to)),
  );

  if (isMainMenuItemActive) currentMenu.value = Menu.MAIN;
  else {
    const isAdvancedMenuItemActive = Boolean(
      flattenedAdvancedItems.value.find((item) =>
        route.path.startsWith(item.to),
      ),
    );
    if (isAdvancedMenuItemActive) currentMenu.value = Menu.ADVANCED;
  }
};

onMounted(async () => {
  determineActiveMenu();
  window.addEventListener("resize", handleResize);
  await setInitialData();
  await uiStore.setUserPermissions();
});

onUnmounted(() => {
  window.removeEventListener("resize", handleResize);
});

watch(() => route.path, determineActiveMenu);
</script>

<template>
  <div
    v-if="organizationId"
    class="mm-app-navigation"
    data-cy="mm-app-navigation"
  >
    <div class="mm-app-navigation--logo">
      <m-m-portal-switcher
        :sc-portal="scPortalUrl"
        :disabled="isSupportViewer"
        :is-sp-org="isSPOrg"
      />

      <m-m-link
        class="mobile-close"
        cy="close-mobile-nav"
        @click.prevent="toggleMobileNav"
      >
        <m-m-icon icon="close" />
      </m-m-link>
    </div>
    <div v-if="isSPViewer" class="mm-app-navigation--wrapper">
      <div :class="mmAppNavigationMainClassList">
        <div v-if="isMobile" class="org-switcher-container">
          <m-m-org-switcher is-mobile />
        </div>

        <div
          v-for="(
            mainNavigationItemCategoryData, mainNavigationItemCategoryDataIndex
          ) in mainNavigationItems"
          :key="`${mainNavigationItemCategoryDataIndex}-${mainNavigationItemCategoryData.categoryLabel}`"
          class="mm-app-navigation--group"
        >
          <div
            v-if="mainNavigationItemCategoryData.categoryLabel"
            class="mm-app-navigation--title"
          >
            {{ mainNavigationItemCategoryData.categoryLabel }}
          </div>
          <m-m-app-navigation-item
            v-for="(
              mainNavigationItemCategoryItem,
              mainNavigationItemCategoryItemIndex
            ) in mainNavigationItemCategoryData.items"
            :key="`${mainNavigationItemCategoryDataIndex}-${mainNavigationItemCategoryItemIndex}-${mainNavigationItemCategoryItem.label}`"
            :to="mainNavigationItemCategoryItem.to"
            :label="mainNavigationItemCategoryItem.label"
            :icon-prepend="mainNavigationItemCategoryItem.icon"
            :is-hidden="mainNavigationItemCategoryItem.isHidden"
            @click.prevent="
              handleNavigationClick(mainNavigationItemCategoryItem)
            "
          />
        </div>

        <div class="mm-app-navigation--separator" />

        <m-m-app-navigation-item
          :label="$t('nav_menu.advanced')"
          :icon-prepend="sectionIcons['configuration']"
          icon-append="chevron-right-outline"
          icon-append-size="16px"
          @click="onSetCurrentMenu(Menu.ADVANCED)"
        />

        <m-m-app-navigation-item
          v-if="isProvideSupportVisible"
          id="app-navigation-admin-service-providers"
          to="/login/support"
          :icon-prepend="sectionIcons['provideSupport']"
          :label="$t('provide_support.nav_label')"
          class="mm-mt-auto mm-mb-6"
          is-reload
        />
      </div>
      <div :class="mmAppNavigationAdvancedClassList">
        <div class="app-navigation-back-button">
          <m-m-app-navigation-item
            :label="t('nav_menu.back')"
            icon-prepend="arrow-left"
            @click="onSetCurrentMenu(Menu.MAIN)"
          />
        </div>

        <div
          v-for="(
            advancedNavigationItemCategoryData,
            advancedNavigationItemCategoryDataIndex
          ) in advancedNavigationItems"
          :key="`${advancedNavigationItemCategoryDataIndex}-${advancedNavigationItemCategoryData.categoryLabel}`"
          class="mm-app-navigation--group"
        >
          <div
            v-if="
              isAdvancedNavigationCategoryLabelVisible(
                advancedNavigationItemCategoryData,
              )
            "
            class="mm-app-navigation--title"
          >
            {{ advancedNavigationItemCategoryData.categoryLabel }}
          </div>
          <m-m-app-navigation-item
            v-for="(
              advancedNavigationItemCategoryItem,
              advancedNavigationItemCategoryItemIndex
            ) in advancedNavigationItemCategoryData.items"
            :key="`${advancedNavigationItemCategoryDataIndex}-${advancedNavigationItemCategoryItemIndex}-${advancedNavigationItemCategoryItem.label}`"
            :to="advancedNavigationItemCategoryItem.to"
            :label="advancedNavigationItemCategoryItem.label"
            :icon-prepend="advancedNavigationItemCategoryItem.icon"
            :is-hidden="advancedNavigationItemCategoryItem.isHidden"
            @click.prevent="
              handleNavigationClick(advancedNavigationItemCategoryItem)
            "
          />
        </div>
      </div>
    </div>
  </div>
</template>
<style lang="scss">
.app-navigation-back-button {
  position: sticky;
  top: 0;
  background: #f2f4f6;
  z-index: 10;
  padding-bottom: 1rem;
}
</style>
