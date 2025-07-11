<script setup lang="ts">
import { Ref, ref } from "vue";
import { PaginationSchema_PolicyTypeRead_ } from "../../ConfigurationTabs/Policies/policies.types";
import { PaginationSchema_AllPolicyRead_ } from "../../Policies/policies.types";
import {
  ServiceProviderOrganizationRead,
  PaginationSchema_ServiceProviderOrganizationUserRead_,
} from "~/iam/iam.types";
import { authService } from "../../../auth/auth.service";
import { serviceProvidersService } from "../../service-providers.service";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import RolesTab from "./Tabs/Roles.vue";
import AssignedRolesTab from "./Tabs/AssignedRoles.vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import useActiveTab from "~/mm_ui_kit/src/composables/activeTabIndexBasedOnURL";
import { groupByField } from "~/mm_ui_kit/src/helpers/groupBy";
import { policyTypesService } from "~/configuration/policy-types.service";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { policiesService } from "~/service-providers/policies.service";
import { ITEMS_PER_PAGE } from "~/common/constants";

const initialQueryParams = {
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
  category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
};

const isLoading: Ref<boolean> = ref(true);
const roles: Ref<PaginationSchema_PolicyTypeRead_ | null> = ref(null);
const assignedRoles: Ref<PaginationSchema_AllPolicyRead_ | null> = ref(null);
const serviceProviderId: Ref<string> = ref("");
const organizationName: Ref<Record<string, string> | null> = ref({});
const userName: Ref<Record<string, string> | null> = ref({});
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const TABS: TypeTab[] = [
  { label: "Roles", name: "Roles", isRequired: false },
  { label: "Assigned roles", name: "Assigned roles", isRequired: false },
];

const activeTab = useActiveTab(TABS[0].name);

const getRoles = async (params?: TableRequestParams) => {
  isLoading.value = true;

  const updatedParams = {
    ...params,
    category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
  };

  if (!Object.hasOwn(updatedParams, "sort")) {
    updatedParams.sort = "name:asc";
  }

  try {
    const response = await policyTypesService.getPolicyTypes(
      serviceProviderId.value,
      updatedParams,
    );
    if (response?.results?.length) {
      response?.results.forEach((role) => {
        role.hidden = role?.wizard?.hidden || false;
      });
    }
    roles.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const getAssignedRoles = async (params?: TableRequestParams) => {
  isLoading.value = true;
  const updatedParams = {
    ...params,
    category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
  };

  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }

  assignedRoles.value = await policiesService.getAllExternalPolicies(
    serviceProviderId.value,
    params ? updatedParams : initialQueryParams,
  );

  if (assignedRoles.value) {
    assignedRoles.value?.results.map(async (role) => {
      const organization: ServiceProviderOrganizationRead =
        await serviceProvidersService.getServiceProviderOrganizationDetails(
          serviceProviderId.value,
          role.organization_id,
        );
      role.organizationName = organization.organization.name;
    });

    const groupByOrgId = groupByField(
      assignedRoles.value?.results,
      "organization_id",
    );

    const userIds = assignedRoles.value?.results
      .filter(
        (policy) =>
          policy.assigned_id !== null &&
          policy.policy_assignment === "ORGANIZATION_USER",
      )
      .map((policy) => policy.assigned_id);

    Object.entries(groupByOrgId).forEach(async (group) => {
      if (userIds.length > 0) {
        const users: PaginationSchema_ServiceProviderOrganizationUserRead_ =
          await serviceProvidersService.getServiceProviderOrganizationUsers(
            serviceProviderId.value,
            group[0],
            userIds,
          );
        users.results.forEach((item) => {
          if (userName.value) {
            userName.value[item?.organization_user.id] =
              item?.user?.first_name && item?.user?.last_name
                ? `${item.user.first_name} ${item.user.last_name}`
                : "-";
          }
        });
      }
    });
  }
  isLoading.value = false;
};

const handleDeleteRole = async () => {
  await getRoles();
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const handleDeleteAssignedRole = async () => {
  await getAssignedRoles();
};

const updateTabRoles = async (params: TableRequestParams) => {
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getRoles(params);
};

const updateTabAssignedRoles = async (params: TableRequestParams) => {
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getAssignedRoles(params);
};
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="access_control.role_based"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs v-model="activeTab" :items="TABS" />
    </m-m-teleport>
    <m-m-tab-items :current-tab="activeTab">
      <m-m-tab-item :name="TABS[0].name">
        <roles-tab
          :items="roles"
          :service-provider-id="serviceProviderId"
          :is-loading="isLoading"
          @update="updateTabRoles"
          @delete-role="handleDeleteRole"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[1].name">
        <assigned-roles-tab
          :items="assignedRoles"
          :service-provider-id="serviceProviderId"
          :organization-name="organizationName"
          :user-name="userName"
          :is-loading="isLoading"
          @update="updateTabAssignedRoles"
          @delete-assigned-role="handleDeleteAssignedRole"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </m-m-overview-page>
</template>
