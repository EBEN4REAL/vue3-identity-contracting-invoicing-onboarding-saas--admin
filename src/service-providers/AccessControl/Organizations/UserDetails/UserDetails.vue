<script setup lang="ts">
import { ref, onMounted, Ref, computed, ComputedRef } from "vue";
import {
  AttributeRead,
  ServiceProviderOrganizationRead,
  ServiceProviderOrganizationUserReadWithAttributes,
} from "~/iam/iam.types";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { PaginationSchema_PolicyRead_ } from "~/service-providers/Policies/policies.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { authService } from "~/auth/auth.service";
import { policiesService } from "~/service-providers/policies.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import Access from "./Tabs/Access.vue";
import type { TypeDataIteratorItem } from "~/mm_ui_kit/src/types/dataIterator.types";
import { useRoute } from "vue-router";
import { PolicyTypeBaseRead } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import escapeObjectValuesForHtml from "~/mm_ui_kit/src/helpers/escapeObjectValuesForHtml";
import { useTranslation } from "i18next-vue";

const route = useRoute();
const { t } = useTranslation();

const props = defineProps({
  id: {
    type: String,
    required: true,
  },
  organizationId: {
    type: String,
    required: true,
  },
});

const defaultEmptyText = "Not added";
const details: ComputedRef<TypeDataIteratorItem[]> = computed(() => {
  const items: TypeDataIteratorItem[] = [
    {
      label: "First name",
      text: orgUser.value?.user.first_name || "",
      isEmpty: !orgUser.value?.user.first_name,
      emptyText: defaultEmptyText,
    },
    {
      label: "Last name",
      text: orgUser.value?.user.last_name || "",
      isEmpty: !orgUser.value?.user.last_name,
      emptyText: defaultEmptyText,
    },
    {
      label: "Email address",
      text: orgUser.value?.user.email || "",
      isEmpty: !orgUser.value?.user.email,
      emptyText: defaultEmptyText,
    },
    {
      label: "Account",
      text: orgUser.value?.organization.name || "",
      isEmpty: !orgUser.value?.organization.name,
      emptyText: "No account",
      to: `/sp/accounts/${orgUser.value?.organization.id}`,
    },
  ];
  if (orgUser.value?.attributes) {
    items.push(
      ...orgUser.value.attributes.map(
        (attribute: AttributeRead) =>
          ({
            label: attribute.name || "",
            text: attribute.value || "",
            isEmpty: attribute.value === null || attribute.value === "",
            emptyText: defaultEmptyText,
          }) as TypeDataIteratorItem,
      ),
    );
  }

  return items;
});
const isLoading: Ref<boolean> = ref(true);
const serviceProviderId: Ref<string> = ref("");
const orgUser: Ref<ServiceProviderOrganizationUserReadWithAttributes | null> =
  ref(null);

const customer: Ref<ServiceProviderOrganizationRead | null> = ref(null);

const policies: Ref<PaginationSchema_PolicyRead_ | null> = ref(null);
const roles: Ref<PaginationSchema_PolicyRead_ | null> = ref(null);
const rolePolicyTypeCategoryId: Ref<string | null> = ref(null);
const policyTypeCategoryId: Ref<string | null> = ref(null);
const TABS: TypeTab[] = [
  { label: "Basic information", name: "Basic information", isRequired: false },
  { label: "Access", name: "Access", isRequired: false },
];

const mainHeaderTab = ref(TABS[0].name);

const initials = computed(() =>
  orgUser.value?.user.first_name?.at(0) && orgUser.value?.user.last_name?.at(0)
    ? `${orgUser.value?.user.first_name.at(0)}${orgUser.value?.user.last_name.at(0)}`
    : null,
);

const userFullName: ComputedRef<string> = computed(() => {
  const user = orgUser.value?.user;
  if (user) {
    const { first_name, last_name } = user;
    return first_name || last_name
      ? `${first_name} ${last_name}`
      : "Unnamed user";
  }
  return "";
});

const title: ComputedRef<string> = computed(() =>
  t(
    "user_details.title",
    escapeObjectValuesForHtml({
      userFullName: userFullName.value,
    }),
  ),
);

const subtitle: ComputedRef<string> = computed(() =>
  t(
    "user_details.subtitle",
    escapeObjectValuesForHtml({
      userEmail: orgUser.value?.user.email || "",
    }),
  ),
);

const fetchData = async () => {
  isLoading.value = true;
  try {
    await getServiceProviderOrganizationUserDetails();
    await Promise.all([
      getPolicies(),
      getRoles(),
      getCustomerDetails(),
      authService.getProfile(),
    ]);
  } catch (error) {
    console.error(error);
  } finally {
    isLoading.value = false;
  }
};
const getServiceProviderOrganizationUserDetails = async () => {
  // check if current route contains string 'accounts'
  if (route.path.includes("accounts")) {
    orgUser.value =
      await serviceProvidersService.getServiceProviderOrganizationUserDetails(
        serviceProviderId.value,
        props.organizationId,
        props.id,
      );
  } else {
    orgUser.value = await serviceProvidersService.getServiceProviderUserDetails(
      serviceProviderId.value,
      props.id,
    );
  }
};
const getPolicyTypeCategories = async () => {
  const result = await policiesService.getPolicyTypeCategories();
  const rolePolicyTypeCategory = result.find(
    (policyType: PolicyTypeBaseRead) => policyType.name == "Role",
  );
  const policyTypeCategory = result.find(
    (policyType: PolicyTypeBaseRead) => policyType.name == "Policy",
  );
  rolePolicyTypeCategoryId.value = rolePolicyTypeCategory?.id;
  policyTypeCategoryId.value = policyTypeCategory?.id;
};

const getPolicies = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    const finalParams = {
      ...params,
      organization_user_id: orgUser.value?.organization_user?.id,
      limit: params?.limit || ITEMS_PER_PAGE[0],
      offset: params?.offset || "0",
      policy_category_id: policyTypeCategoryId.value,
    };

    policies.value =
      await policiesService.getServiceProviderPoliciesOrganizationUsers(
        serviceProviderId.value,
        finalParams,
      );
  } finally {
    isLoading.value = false;
  }
};
const getRoles = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    const finalParams = {
      ...params,
      organization_user_id: orgUser.value?.organization_user?.id,
      limit: params?.limit || ITEMS_PER_PAGE[0],
      offset: params?.offset || "0",
      policy_category_id: rolePolicyTypeCategoryId.value,
    };
    roles.value =
      await policiesService.getServiceProviderPoliciesOrganizationUsers(
        serviceProviderId.value,
        finalParams,
      );
  } finally {
    isLoading.value = false;
  }
};

const getCustomerDetails = async () => {
  customer.value =
    await serviceProvidersService.getServiceProviderOrganizationDetails(
      serviceProviderId.value,
      props.organizationId,
    );
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  await getPolicyTypeCategories();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
    await fetchData();
  }
});
</script>

<template>
  <template v-if="orgUser?.id">
    <m-m-teleport to="common-page-layout-header-icon">
      <m-m-icon v-if="initials" :icon="`initials-${initials}`" />
      <m-m-icon v-else icon="user-circle" />
    </m-m-teleport>
    <m-m-teleport to="common-page-layout-header-title">
      <div v-sanitize-html="title" />
    </m-m-teleport>
    <m-m-teleport to="common-page-layout-header-subtitle">
      <div v-sanitize-html="subtitle" />
    </m-m-teleport>
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs v-model="mainHeaderTab" :items="TABS" />
    </m-m-teleport>

    <m-m-tab-items :current-tab="mainHeaderTab">
      <m-m-tab-item :name="TABS[0].name">
        <m-m-data-iterator
          :data="details"
          cy-id-text="user-detail-item-text"
          cy-id-text-empty="user-detail-item-text-empty"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[1].name">
        <Access
          :role-policy-type-category-id="rolePolicyTypeCategoryId"
          :policy-type-category-id="policyTypeCategoryId"
          :is-loading="isLoading"
          :policies="policies || []"
          :roles="roles || []"
          :customer="customer"
          :user="orgUser"
          :organization-id="props.organizationId"
          @update-policies="getPolicies"
          @update-roles="getRoles"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </template>
</template>
<style scoped lang="scss">
:deep(.mm-table) {
  padding: 0 24px 24px 24px;
}
:deep(.mm-expandable-card--active) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body tr) {
  background-color: #fff;
}
:deep(.mm-table-body thead tr) {
  background-color: #fafbfc;
}
:deep(.mm-table-actions-cell) {
  overflow: hidden;
  white-space: nowrap;
}
</style>
