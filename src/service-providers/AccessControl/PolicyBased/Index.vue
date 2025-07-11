<script setup lang="ts">
import { Ref, ref } from "vue";
import { PaginationSchema_PolicyTypeRead_ } from "../../ConfigurationTabs/Policies/policies.types";
import {
  AllPolicyRead,
  PaginationSchema_AllPolicyRead_,
} from "../../Policies/policies.types";
import { policiesService } from "../../policies.service";
import { authService } from "../../../auth/auth.service";
import { serviceProvidersService } from "../../service-providers.service";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import PoliciesTab from "./Tabs/Policies.vue";
import AssignedPoliciesTab from "./Tabs/AssignedPolicies.vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import useActiveTab from "~/mm_ui_kit/src/composables/activeTabIndexBasedOnURL";
import { groupByField } from "~/mm_ui_kit/src/helpers/groupBy";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  ServiceProviderOrganizationRead,
  PaginationSchema_ServiceProviderOrganizationUserRead_,
} from "~/iam/iam.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";

const isLoading: Ref<boolean> = ref(true);
const policies: Ref<PaginationSchema_PolicyTypeRead_ | null> = ref(null);
const assignedPolicies: Ref<PaginationSchema_AllPolicyRead_ | null> = ref(null);
const serviceProviderId: Ref<string> = ref("");
const organizationName: Ref<Record<string, string> | null> = ref({});
const userName: Ref<Record<string, string> | null> = ref({});
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const TABS: TypeTab[] = [
  { label: "Policies", name: "Policies", isRequired: false },
  { label: "Assigned policies", name: "assigned_policies", isRequired: false },
];

const activeTab = useActiveTab(TABS[0].name);

const getPolicies = async (params?: TableRequestParams) => {
  isLoading.value = true;

  const updatedParams = {
    ...params,
    exclude_category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
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
      response?.results.forEach((policy) => {
        policy.hidden = policy?.wizard?.hidden || false;
      });
    }
    policies.value = response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const getAssignedPolicies = async (params?: TableRequestParams) => {
  isLoading.value = true;
  const updatedParams = {
    ...params,
    exclude_category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
  };

  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }
  assignedPolicies.value = await policiesService.getAllExternalPolicies(
    serviceProviderId.value,
    params
      ? updatedParams
      : {
          limit: ITEMS_PER_PAGE[0],
          offset: "0",
          exclude_category_id: "a7a82589-c6ae-481d-b87c-16a7009b0d8f",
        },
  );

  if (assignedPolicies.value) {
    assignedPolicies.value?.results.map(async (policy: AllPolicyRead) => {
      const organization: ServiceProviderOrganizationRead =
        await serviceProvidersService.getServiceProviderOrganizationDetails(
          serviceProviderId.value,
          policy.organization_id,
        );
      policy.organizationName = organization.organization.name;
    });

    const groupByOrgId = groupByField(
      assignedPolicies.value?.results,
      "organization_id",
    );

    const userIds = assignedPolicies.value?.results
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

const handleDeletePolicy = async () => {
  await getPolicies();
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const handleDeleteAssignedPolicy = async () => {
  await getAssignedPolicies();
};

const updateTabPolicies = async (params: TableRequestParams) => {
  // activeTab.value = TABS[0].name;
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getPolicies(params);
};

const updateTabAssignedPolicies = async (params: TableRequestParams) => {
  // activeTab.value = TABS[1].name;
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getAssignedPolicies(params);
};
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="access_control.policy_based"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs v-model="activeTab" :items="TABS" />
    </m-m-teleport>
    <m-m-tab-items :current-tab="activeTab">
      <m-m-tab-item :name="TABS[0].name">
        <policies-tab
          :items="policies"
          :service-provider-id="serviceProviderId"
          :is-loading="isLoading"
          @update="updateTabPolicies"
          @delete-policy="handleDeletePolicy"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[1].name">
        <assigned-policies-tab
          :items="assignedPolicies"
          :service-provider-id="serviceProviderId"
          :organization-name="organizationName"
          :user-name="userName"
          :is-loading="isLoading"
          @update="updateTabAssignedPolicies"
          @delete-assigned-policy="handleDeleteAssignedPolicy"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </m-m-overview-page>
</template>
