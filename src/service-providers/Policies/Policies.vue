<!-- TODO: Remove File after confirming no need for rollback -->

<script setup lang="ts">
import { Ref, computed, onMounted, ref } from "vue";
import { authService } from "../../auth/auth.service";
import { ITEMS_PER_PAGE } from "../../common/constants";
import { policiesService } from "../policies.service";
import { TableRequestParams } from "../../mm_ui_kit/src/types/table.types";
import {
  AllPolicyRead,
  PaginationSchema_AllPolicyRead_,
} from "./policies.types";
import { organizationsService } from "~/organizations/organizations.service";
import { serviceProvidersService } from "../service-providers.service";
import { groupByField } from "~/mm_ui_kit/src/helpers/groupBy";
import DialogRemovePolicy from "./DialogRemovePolicy.vue";
import { useRouter } from "vue-router";

const router = useRouter();
const serviceProviderId: Ref<string> = ref("");
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const policies: Ref<PaginationSchema_AllPolicyRead_ | null> = ref(null);
const isPoliciesRemoveDialogOpen: Ref<boolean> = ref(false);
const dialogRemovePoliciesData: Ref<AllPolicyRead | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);
const organizationName: Ref<Record<string, string> | null> = ref({});
const userName: Ref<Record<string, string> | null> = ref({});

const headers = [
  {
    key: "name",
    label: "Policy name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "name",
  },
  {
    key: "owner_id",
    label: "Customer",
  },
  {
    key: "assigned_to",
    label: "Assigned to",
  },
  {
    key: "assigned_on",
    label: "Assigned on",
    sortable: true,
    sortIcon: true,
    order: "desc",
    defaultSortItem: true,
    sortName: "assigned_on",
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const mainHeaderDropdownItems = computed(() => [
  {
    label: "Configure policies",
    type: "button",
    onClick: onRedirectToConfigurePolicies,
  },
]);

const onRedirectToConfigurePolicies = () => {
  router.push("/config/policies");
};

const handleUpdateParams = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == "") {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getPolicies(params);
};

const getPolicies = async (params?: TableRequestParams) => {
  isLoading.value = true;
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }
  policies.value = await policiesService.getAllExternalPolicies(
    serviceProviderId.value,
    params ? params : { limit: ITEMS_PER_PAGE[0], offset: "0" },
  );

  if (policies.value) {
    const organizationIds = policies.value?.results
      .filter((policy) => policy.organization_id !== null)
      .map((policy) => policy.organization_id);

    if (organizationIds.length > 0) {
      const organizations =
        await serviceProvidersService.getServiceProviderOrganizationNames(
          serviceProviderId.value,
          organizationIds,
        );

      organizations.results.forEach((item) => {
        if (organizationName.value) {
          organizationName.value[item.organization.id] = item.organization.name;
        }
      });
    }

    const groupByOrgId = groupByField(
      policies.value?.results,
      "organization_id",
    );

    Object.entries(groupByOrgId).forEach(async (group) => {
      const userIds = group[1]
        .filter(
          (policy) =>
            policy.assigned_id !== null && policy.policy_assignment === "OU",
        )
        .map((policy) => policy.assigned_id);

      if (userIds.length > 0) {
        const users = await organizationsService.getOrganizationUsersName(
          group[0],
          userIds,
        );
        users.results.forEach((item) => {
          if (userName.value) {
            userName.value[item.id] = item.first_name + " " + item.last_name;
          }
        });
      }
    });
  }
  isLoading.value = false;
};

const handleRemovePoliciesDialog = (policy: AllPolicyRead) => {
  isPoliciesRemoveDialogOpen.value = true;
  dialogRemovePoliciesData.value = policy;
};

const handleRemovePolicy = async (policy: AllPolicyRead) => {
  if (policy.policy_assignment === "ORGANIZATION") {
    await policiesService.removePolicyFromOrganization(
      serviceProviderId.value,
      {
        policy_type_id: policy.type_id,
        organization_id: policy.organization_id,
      },
    );
  } else if (policy.policy_assignment === "ORGANIZATION_USER") {
    await policiesService.removePolicy(serviceProviderId.value, {
      policy_type_id: policy.type_id,
      organization_user_id: policy.assigned_id,
      organization_id: policy.organization_id,
    });
  }
  getPolicies();
  isPoliciesRemoveDialogOpen.value = false;
};

onMounted(async () => {
  isSPAdmin.value = (await authService.isUserSPAdmin()) === true;
  isSPEditor.value = (await authService.isUserSPEditor()) === true;
});
</script>

<template>
  <m-m-teleport to="common-page-layout-header-title"> Policies </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-subtitle">
    All policies assigned to customers
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-controls">
    <div class="mm-flex mm-flex-gap-6">
      <m-m-dropdown :items="mainHeaderDropdownItems" />
    </div>
  </m-m-teleport>

  <m-m-table
    cy="policies-table"
    :headers="headers"
    :is-loading="isLoading"
    :rows="policies?.results"
    :total-rows="policies?.total"
    show-search
    @update-params="handleUpdateParams"
  >
    <template #name="{ row }">
      <span class="font-weight-500">
        {{ row.name }}
      </span>
    </template>
    <template #owner_id="{ row }">
      <span>
        {{ organizationName[row.organization_id as string] }}
      </span>
    </template>
    <template #assigned_to="{ row }">
      {{
        row.policy_assignment === "O"
          ? "Organization"
          : userName[row.assigned_id as string]
      }}
      <span> </span>
    </template>
    <template #assigned_on="{ row }">
      <m-m-formatted-date :raw-date="row.assigned_on" />
    </template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown
          list-side="left"
          :items="[
            {
              label: 'Remove Policy',
              color: 'error',
              type: 'button',
              onClick: () => handleRemovePoliciesDialog(row),
            },
          ]"
          :cy="`actions-dropdown-${row.id}`"
        >
          <template #activator>
            <m-m-button
              prepend-icon="dots-vertical"
              variant="text"
              :cy="`actions-${row.id}`"
            />
          </template>
        </m-m-dropdown>
      </div>
    </template>
  </m-m-table>
  <DialogRemovePolicy
    :is-open="isPoliciesRemoveDialogOpen"
    :data="dialogRemovePoliciesData"
    :org-name="
      organizationName &&
      dialogRemovePoliciesData &&
      organizationName[dialogRemovePoliciesData.organization_id]
    "
    :user-name="
      userName &&
      dialogRemovePoliciesData &&
      userName[dialogRemovePoliciesData.assigned_id]
    "
    @close-dialog="isPoliciesRemoveDialogOpen = false"
    @submit-dialog="
      dialogRemovePoliciesData && handleRemovePolicy(dialogRemovePoliciesData)
    "
  />
</template>

<style scoped></style>
