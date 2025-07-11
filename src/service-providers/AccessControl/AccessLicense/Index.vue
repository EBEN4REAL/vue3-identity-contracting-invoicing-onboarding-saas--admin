<script setup lang="ts">
import { Ref, ref } from "vue";
import { authService } from "../../../auth/auth.service";
import { policiesService } from "~/service-providers/policies.service";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import LicensesTab from "./Tabs/Licenses.vue";
import AllocatedLicensesTab from "./Tabs/AllocatedLicenses.vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import useActiveTab from "~/mm_ui_kit/src/composables/activeTabIndexBasedOnURL";
import { SPAgreementRead } from "~/service-providers/Licenses/licenses.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";

const isLoading: Ref<boolean> = ref(true);
const serviceProviderId: Ref<string> = ref("");
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);
const licenses: Ref<TableResponse<AgreementTypePoliciesRead> | null> =
  ref(null);
const allocatedLicenses: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
const currentParams: Ref<TableRequestParams> = ref({
  category: "ACCESS",
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});

const TABS: TypeTab[] = [
  { label: "Licenses", name: "Licenses", isRequired: false },
  {
    label: "Allocated licenses",
    name: "allocated_licenses",
    isRequired: false,
  },
];

const activeTab = useActiveTab(TABS[0].name);

const getAgreementTypes = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || "";
    }
    licenses.value = await agreementTypesService.getAgreementTypes(
      serviceProviderId.value as string,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const getAllocatedAgreements = async (params?: TableRequestParams) => {
  isLoading.value = true;
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }
  const requestParams = {
    category: "ACCESS",
    ...(params || { limit: ITEMS_PER_PAGE[0], offset: "0" }),
  };
  allocatedLicenses.value = await policiesService.getAgreements(
    serviceProviderId.value,
    requestParams,
  );
  isLoading.value = false;
};

const updateTabLicenses = async (params: TableRequestParams) => {
  currentParams.value = { ...currentParams.value, ...params };
  await getAgreementTypes(currentParams.value);
};

const updateTabAllocatedLicenses = async (params: TableRequestParams) => {
  await getAllocatedAgreements(params);
};

const onDeleteLicense = () =>
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="access_control.access_licenses"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs v-model="activeTab" :items="TABS" />
    </m-m-teleport>
    <m-m-tab-items :current-tab="activeTab">
      <m-m-tab-item :name="TABS[0].name">
        <licenses-tab
          :items="licenses"
          :service-provider-id="serviceProviderId"
          :is-loading="isLoading"
          @update="updateTabLicenses"
          @on:delete-license="onDeleteLicense"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[1].name">
        <allocated-licenses-tab
          :items="allocatedLicenses"
          :service-provider-id="serviceProviderId"
          :is-loading="isLoading"
          @update="updateTabAllocatedLicenses"
        />
      </m-m-tab-item>
    </m-m-tab-items>
  </m-m-overview-page>
</template>
