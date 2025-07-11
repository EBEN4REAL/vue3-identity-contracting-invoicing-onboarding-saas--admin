<script setup lang="ts">
import {
  computed,
  ComputedRef,
  onMounted,
  onUnmounted,
  reactive,
  Ref,
  ref,
  watch,
} from "vue";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import {
  ServiceProviderConfigRead,
  ConfigRead,
  ConfigChangeRead,
} from "~/configuration/configuration.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { authService } from "~/auth/auth.service";
import { tableHeaders } from "./TableHeaders";
import { ConfigPublishStatusEnum } from "./enums";
import { configurationService } from "~/configuration/configuration.service";
import { useRouter } from "vue-router";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { useTranslation } from "i18next-vue";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";
import {
  setIntervalAsync,
  SetIntervalAsyncTimer,
} from "set-interval-async/dynamic";

const { t } = useTranslation();

const router = useRouter();
const serviceProviderId: Ref<string> = ref("");
const isTableLoading: Ref<boolean> = ref(true);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isButtonPublishStatusRefreshLoading: Ref<boolean> = ref(false);
const isSubmitButtonDisabled: Ref<boolean> = ref(false);
const unpublishedConfig: Ref<ServiceProviderConfigRead | null> = ref(null);
const configId: Ref<string> = ref("");
const configDetails: Ref<ConfigRead | null> = ref(null);
const configPublishStatus: Ref<string> = ref("");
const timeoutId: Ref<number> = ref(0);
const loadingWizardIds: Ref<Set<string | undefined>> = ref(new Set());
const publishingWizard: Ref<string | null> = ref(null);

const intervalTimers = ref(new Map<string, SetIntervalAsyncTimer<[]>>());
const stopPollingFlags = ref(new Map<string, boolean>());
const unpublishedConfigChanges: Ref<TableResponse<ConfigChangeRead> | null> =
  ref(null);

const tableData = reactive<Record<string, TableResponse<ConfigChangeRead>>>({});
const isFetchingConfigChanges = reactive<Record<string, boolean>>({});

const isWizardPublishLoading = (wizardId: string): boolean =>
  loadingWizardIds.value.has(wizardId);

const isPublishButtonDisabled: ComputedRef<
  (id: string, publishStatus: string) => boolean
> = computed(
  () => (id: string, publishStatus: string) =>
    isPublishDisabled.value(id) ||
    isWizardPublishLoading(id) ||
    publishStatus === ConfigPublishStatusEnum.PUBLISHING.enum,
);

const isPublishDisabled: ComputedRef<(id: string) => boolean> = computed(
  () => (id: string) =>
    publishingWizard.value !== null && publishingWizard.value !== id,
);

const unpublishedChangesCount: ComputedRef<number> = computed(
  () => unpublishedConfigChanges.value?.total || 0,
);

const isWizardConfigsAvailable: ComputedRef<boolean> = computed(() =>
  Boolean(unpublishedConfig.value?.wizard_configs?.length ?? 0),
);

const unpublishedChangesCountText: ComputedRef<string> = computed(
  () =>
    `${unpublishedChangesCount.value} unpublished change${unpublishedChangesCount.value > 1 ? "s" : ""}`,
);

const getConfigDetails = async (newConfigId: string) => {
  try {
    const response = await configurationService.getConfigDetails(
      serviceProviderId.value,
      newConfigId,
    );
    if (newConfigId === configId.value) {
      configDetails.value = response;
      configPublishStatus.value = configDetails.value.status;
    }
    return response;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching config details",
      status: "error",
    });
  } finally {
    isButtonPublishStatusRefreshLoading.value = false;
  }
};

const refreshConfigPublishStatus = async () => {
  isButtonPublishStatusRefreshLoading.value = true;
  await getConfigDetails(configId.value);
};

const isPublished: ComputedRef<boolean> = computed(
  () => configDetails.value?.status === ConfigPublishStatusEnum.PUBLISHED.enum,
);

const isPublishing: ComputedRef<boolean> = computed(
  () => configDetails.value?.status === ConfigPublishStatusEnum.PUBLISHING.enum,
);

const isDraft: ComputedRef<boolean> = computed(
  () => configDetails.value?.status === ConfigPublishStatusEnum.DRAFT.enum,
);

const isPublishFailed: ComputedRef<boolean> = computed(
  () => configDetails.value?.status === ConfigPublishStatusEnum.FAILED.enum,
);

const isConfigEditable: ComputedRef<boolean> = computed(
  () => isDraft.value || isPublishFailed.value,
);

const isPublishBtnDisabledOrPublishing: ComputedRef<boolean> = computed(() => {
  const status = configDetails.value?.status;

  return (
    status === ConfigPublishStatusEnum.PUBLISHING.enum ||
    status === ConfigPublishStatusEnum.PUBLISHED.enum ||
    (isButtonSubmitLoading.value ?? false) ||
    (isSubmitButtonDisabled.value ?? false)
  );
});
const backToLabel =
  router.options.history.state.backToLabel?.toString().toLowerCase() ||
  "applications";
const backTo =
  router.options.history.state.backTo?.toString() || "/sp/config/applications";
const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => {
  return [
    {
      id: "configuration",
      label: `Back to ${backToLabel}`,
      to: backTo,
    },
    {
      id: "config-publish-overview",
      label: "Config publish overview",
    },
  ];
});

const tableRows: ComputedRef<ConfigChangeRead> = computed(
  () => unpublishedConfigChanges.value?.results || [],
);
const totalRows: ComputedRef<number> = computed(
  () => unpublishedConfigChanges.value?.total || 0,
);

const buttonConfigPublishText: ComputedRef<string> = computed(() => {
  const totalItems = unpublishedConfigChanges.value?.total || 0;

  switch (configDetails.value?.status) {
    case ConfigPublishStatusEnum.PUBLISHING.enum:
      return `Publishing ${totalItems} item${totalItems > 1 ? "s" : ""}`;

    case ConfigPublishStatusEnum.PUBLISHED.enum:
      return `Published ${totalItems} item${totalItems > 1 ? "s" : ""}`;

    case ConfigPublishStatusEnum.FAILED.enum:
      return `Re-publish ${totalItems} item${totalItems > 1 ? "s" : ""}`;

    default:
      return `Publish ${totalItems} item${totalItems > 1 ? "s" : ""}`;
  }
});

const subtitleText: ComputedRef<string> = computed(() => {
  const totalItems = unpublishedConfigChanges.value?.total || 0;

  switch (configDetails.value?.status) {
    case ConfigPublishStatusEnum.PUBLISHING.enum:
      return t("review_and_publish_overview.subtitle.publishing", {
        count: totalItems,
      });

    case ConfigPublishStatusEnum.PUBLISHED.enum:
      return t("review_and_publish_overview.subtitle.published", {
        count: totalItems,
      });

    case ConfigPublishStatusEnum.FAILED.enum:
      return t("review_and_publish_overview.subtitle.failed", {
        count: totalItems,
      });

    default:
      return t("review_and_publish_overview.subtitle.ready_other", {
        count: totalItems,
      });
  }
});

const fetchSectionConfigChanges = async (
  sectionConfigId: string,
  params: TableRequestParams,
) => {
  try {
    isFetchingConfigChanges[sectionConfigId] = true;
    const response = await configurationService.getUnpublishedConfigChanges(
      serviceProviderId.value,
      sectionConfigId,
      params,
    );
    if (response?.results.length) {
      tableData[sectionConfigId] = response;
    } else if (unpublishedConfig.value?.wizard_configs) {
      unpublishedConfig.value.wizard_configs =
        unpublishedConfig.value.wizard_configs.filter(
          ({ id }) => id !== sectionConfigId,
        );
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching configuration section changes",
      status: "error",
    });
  } finally {
    isFetchingConfigChanges[sectionConfigId] = false;
  }
};

const updateTableData = async (sectionId: string, params: TableRequestParams) =>
  await fetchSectionConfigChanges(sectionId, params);

const getUnpublishedConfigChanges = async (params?: TableRequestParams) => {
  if (!configId.value) return;
  const requestParams = params ?? { limit: "10", offset: "0" };
  try {
    isTableLoading.value = true;
    unpublishedConfigChanges.value =
      await configurationService.getUnpublishedConfigChanges(
        serviceProviderId.value,
        configId.value,
        requestParams,
      );
    await getConfigDetails(configId.value);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching configuration changes",
      status: "error",
    });
  } finally {
    isTableLoading.value = false;
  }
};

const pollConfigDetails = (newConfigId: string) => {
  stopPollingFlags.value.set(newConfigId, false);
  const timer: SetIntervalAsyncTimer<[]> = setIntervalAsync(async () => {
    if (stopPollingFlags.value.get(newConfigId)) {
      return;
    }
    const response = await getConfigDetails(newConfigId);
    if (response?.status !== ConfigPublishStatusEnum.PUBLISHING.enum) {
      stopPollingFlags.value.set(newConfigId, true);
      loadingWizardIds.value.delete(newConfigId);
      publishingWizard.value = null;
      await getConfiguration();
      if (
        newConfigId !== configId.value &&
        response?.status === ConfigPublishStatusEnum.PUBLISHED.enum
      ) {
        showToast({
          text: "Wizard Configuration has been published successfully",
          status: "success",
        });
      } else {
        isSubmitButtonDisabled.value = false;
        isButtonSubmitLoading.value = false;
      }
      await clearConfigDetailsInterval(newConfigId);
    }
  }, 1000);
  intervalTimers.value.set(newConfigId, timer);
};

const clearConfigDetailsInterval = async (configId: string) => {
  const timer = intervalTimers.value.get(configId);
  if (timer) {
    await clearInterval(timer);
    intervalTimers.value.delete(configId);
    stopPollingFlags.value.delete(configId);
  }
};

const getBadgeStatus = (
  status: keyof typeof ConfigPublishStatusEnum,
): BadgeTypes => ConfigPublishStatusEnum[status].badge || BadgeTypes.Inactive;

const getBadgeText = (publishStatus: keyof typeof ConfigPublishStatusEnum) =>
  ConfigPublishStatusEnum[publishStatus].readable;

const publishConfigItems = async (id?: string) => {
  if (publishingWizard.value) return;
  const configIdToPublish = id || configId.value;
  const isWizardPublish = id && id !== configId.value;
  try {
    publishingWizard.value = id ?? "";
    if (isWizardPublish) {
      loadingWizardIds.value.add(id!);
      isSubmitButtonDisabled.value = true;
    } else {
      isSubmitButtonDisabled.value = true;
      isButtonSubmitLoading.value = true;
    }
    await configurationService.publishConfigChanges(
      serviceProviderId.value,
      configIdToPublish,
    );
    if (isWizardPublish) await getConfiguration();
    pollConfigDetails(configIdToPublish);
  } catch {
    eventBus.$emit("onShowToast", {
      text: "Failed to publish config",
      status: "error",
    });
  }
};

const getConfiguration = async () => {
  try {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org as string;
    if (!serviceProviderId.value) {
      return;
    }
    unpublishedConfig.value = await configurationService.getConfig(
      serviceProviderId.value,
    );
    configId.value = unpublishedConfig.value?.config?.id || "";
    await getUnpublishedConfigChanges();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching configuration",
      status: "error",
    });
  }
};

const goToConfigurationPage = () => {
  router.push(backTo);
};

const getWizardConfigTotalCount = (wizardId: string): number =>
  tableData[wizardId]?.total || 0;

const getWizardConfigTableRows = (wizardId: string): ConfigChangeRead[] =>
  tableData[wizardId]?.results || [];

watch(
  () => configPublishStatus.value,
  (newStatus) => {
    const isPublishingOrFailed = [
      ConfigPublishStatusEnum.PUBLISHED.enum,
      ConfigPublishStatusEnum.FAILED.enum,
    ].includes(newStatus);

    if (isPublishingOrFailed && configId.value) {
      clearConfigDetailsInterval(configId.value);
      configPublishStatus.value = "";
      localStorage.removeItem("is-mm-config-refresh");
    }
    if (
      ConfigPublishStatusEnum.FAILED.enum ||
      ConfigPublishStatusEnum.DRAFT.enum
    ) {
      isSubmitButtonDisabled.value = false;
      isButtonSubmitLoading.value = false;
    }
  },
);

const generateLinkByObjectTypeAndId = (
  configChangeItem: ConfigChangeRead,
): string | null => {
  let objectType: string | null = configChangeItem.object_type;

  const objectTypePaths = {
    oauth_client: "applications",
    filter: "filters",
    policy_type: "policy-types",
    resource_type: "resources",
    attribute_set: "attribute-sets",
    agreement_type_license: "licenses",
    agreement_type_plan: "plans",
    legal_document_type: "legal-documents",
  };

  if (configChangeItem.object_type === "agreement_type") {
    if (configChangeItem.category === "SUBSCRIPTION")
      objectType = "agreement_type_plan";
    if (configChangeItem.category === "ACCESS")
      objectType = "agreement_type_license";
  }

  objectType =
    objectType in objectTypePaths ? objectTypePaths[objectType] : null;

  return objectType
    ? `/sp/${serviceProviderId.value}/${objectType}/${configChangeItem.object_id}`
    : null;
};

onUnmounted(() => {
  if (configId.value) {
    clearConfigDetailsInterval(configId.value);
  }
  clearTimeout(timeoutId.value);
});

onMounted(async () => {
  await getConfiguration();
});
</script>

<template>
  <m-m-teleport to="common-page-layout-header-title">
    Review & publish
    <span v-if="configDetails" class="mm-ml-4 mm-config-publish-status">
      <m-m-badge
        :status="getBadgeStatus(configDetails?.status)"
        :text="getBadgeText(configDetails?.status)"
      />
    </span>
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-breadcrumbs">
    <m-m-breadcrumbs :breadcrumbs="breadcrumbs" />
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-controls">
    <div class="licenses-header-controls">
      <m-m-button
        prepend-icon="publish"
        :loading="isButtonSubmitLoading"
        :is-disabled="isPublishBtnDisabledOrPublishing"
        class="mm-publish-config-btn"
        @click="publishConfigItems(configId)"
      >
        {{ buttonConfigPublishText }}
      </m-m-button>
    </div>
  </m-m-teleport>
  <div v-if="isConfigEditable">
    <m-m-teleport to="common-page-layout-header-subtitle">
      {{ subtitleText }}
    </m-m-teleport>
    <m-m-alert
      status="warning"
      data-cy="alert"
      has-call-to-action
      :is-closable="false"
    >
      <span>
        You have
        <span class="mm-fw-600">
          {{ unpublishedChangesCountText }}
        </span>
        that are ready to be published
      </span>
    </m-m-alert>
    <div class="mm-mt-8">
      <m-m-table
        cy="subscriptions-plans-table"
        :is-loading="isTableLoading"
        :rows="tableRows"
        :headers="tableHeaders"
        :total-rows="totalRows"
        @update-params="getUnpublishedConfigChanges"
      >
        <template #object_name="{ row }">
          <m-m-link
            v-if="generateLinkByObjectTypeAndId(row)"
            :to="generateLinkByObjectTypeAndId(row)"
          >
            {{ row.object_name }}
          </m-m-link>
          <template v-else>{{ row.object_name }}</template>
        </template>

        <template #created_date="{ row }">
          <m-m-formatted-date
            :raw-date="row.created_date"
            format="D MMM YYYY, HH:mm"
          />
        </template>

        <template #changed_attributes="{ row }">
          <pre v-if="row?.changed_attributes">{{ row.changed_attributes }}</pre>
          <span v-else>-</span>
        </template>

        <template #status="{ row }">
          <m-m-badge
            :status="
              getBadgeStatus(row.status as keyof typeof ConfigPublishStatusEnum)
            "
            :text="
              getBadgeText(row.status as keyof typeof ConfigPublishStatusEnum)
            "
          ></m-m-badge>
        </template>
      </m-m-table>
    </div>
    <template v-if="isWizardConfigsAvailable">
      <div
        v-for="wizardConfig in unpublishedConfig?.wizard_configs"
        :key="wizardConfig.id"
      >
        <div
          class="mm-flex mm-flex-justify-between mm-flex-align-center mm-my-10"
        >
          <span class="mm-fw-600 mm-flex mm-flex-align-center mm-flex-gap-5">
            {{ wizardConfig?.wizard?.name }}
            <m-m-badge
              :status="getBadgeStatus(wizardConfig?.status)"
              :text="getBadgeText(wizardConfig?.status)"
            />
          </span>
          <m-m-button
            prepend-icon="publish"
            class="mm-publish-config-btn"
            :is-disabled="
              isPublishButtonDisabled(wizardConfig?.id, wizardConfig?.status)
            "
            :loading="isWizardPublishLoading(wizardConfig?.id)"
            @click="publishConfigItems(wizardConfig?.id)"
          >
            Publish {{ wizardConfig?.wizard?.name }} items
          </m-m-button>
        </div>
        <m-m-table
          :is-loading="isFetchingConfigChanges[wizardConfig.id]"
          :rows="getWizardConfigTableRows(wizardConfig.id)"
          :headers="tableHeaders"
          :total-rows="getWizardConfigTotalCount(wizardConfig.id)"
          @update-params="(params) => updateTableData(wizardConfig.id, params)"
        >
          <template #created_date="{ row }">
            <m-m-formatted-date
              :raw-date="row.created_date"
              format="D MMM YYYY, HH:mm"
            />
          </template>

          <template #changed_attributes="{ row }">
            <pre v-if="row?.changed_attributes">
              {{ row.changed_attributes }}
            </pre>
            <span v-else>-</span>
          </template>
          <template #status="{ row }">
            <m-m-badge
              :status="getBadgeStatus(row.status)"
              :text="getBadgeText(row.status)"
            ></m-m-badge>
          </template>
        </m-m-table>
      </div>
    </template>
  </div>
  <div
    v-if="isPublished"
    class="mm-config-publish-container mm-mx-auto mm-pa-8 mm-flex mm-flex-align-center mm-flex-column mm-flex-gap-8"
  >
    <m-m-icon
      icon="check-circle"
      width="32"
      height="32"
      class="mm-mr-2 mm-flex-shrink-0"
    />

    <span>Your changes are successfully published.</span>
    <m-m-button
      variant="tertiary"
      class="mm-publish-config-btn"
      @click="goToConfigurationPage"
    >
      Back to {{ backToLabel }}
    </m-m-button>
  </div>
  <div
    v-if="isPublishing"
    class="mm-config-publish-container mm-mx-auto mm-pa-8 mm-flex mm-flex-align-center mm-flex-column mm-flex-gap-8"
  >
    <m-m-spinner color="primary" :size="30" />
    <span>Your changes are being published...</span>
    <m-m-button
      variant="outlined"
      prepend-icon="refresh"
      :loading="isButtonPublishStatusRefreshLoading"
      :is-disabled="isButtonPublishStatusRefreshLoading"
      class="mm-publish-config-btn"
      @click="refreshConfigPublishStatus"
    >
      Refresh publish status
    </m-m-button>
  </div>
  <div
    v-if="isTableLoading"
    class="mm-config-publish-container mm-mx-auto mm-pa-8 mm-flex mm-flex-align-center mm-flex-column mm-flex-gap-16"
  >
    <m-m-spinner color="primary" size="30px" />
  </div>
</template>

<style lang="scss" scoped>
.mm-publish-config-btn {
  border-radius: 8px;
  flex-shrink: 0;
}
.mm-config-publish-status {
  margin-top: -10px;
}
.mm-config-publish-container {
  width: 50%;
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-40%, -50%);
}
@media (max-width: $breakpoint-sm) {
  .mm-config-publish-container {
    width: 80%;
    transform: translate(-50%, -50%);
  }
}
@media (max-width: $breakpoint-xs) {
  .mm-config-publish-container {
    width: 80%;
    transform: translate(-50%, -50%);
  }
}
</style>
