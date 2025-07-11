<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { convertToSentenceCase } from "~/mm_ui_kit/src/helpers/utils";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { useTranslation } from "i18next-vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();

const props = defineProps({
  backToLabel: {
    type: String,
    required: false,
    default: () => convertToSentenceCase(useRoute().name?.toString() || ""),
  },
  backToPath: {
    type: String,
    required: false,
    default: () => convertToSentenceCase(useRoute().path?.toString() || ""),
  },
});

const router = useRouter();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const { t } = useTranslation();

const isReviewBannerVisible: Ref<boolean> = ref(false);
const isSuccessBannerVisible: Ref<boolean> = ref(false);
let successTimer: number | null = null;

const SUCCESS_BANNER_STORAGE_KEY = "hasShownConfigSuccessBanner";
const LAST_STATUS_STORAGE_KEY = "lastConfigStatus";

const getStoredBannerState = (): boolean =>
  JSON.parse(localStorage.getItem(SUCCESS_BANNER_STORAGE_KEY) || "false");

const setStoredBannerState = (isBannerVisible: boolean) =>
  localStorage.setItem(
    SUCCESS_BANNER_STORAGE_KEY,
    JSON.stringify(isBannerVisible),
  );

const getLastStoredStatus = (): string | null =>
  localStorage.getItem(LAST_STATUS_STORAGE_KEY);

const setLastStoredStatus = (status: string) =>
  localStorage.setItem(LAST_STATUS_STORAGE_KEY, status);

const isConfigDraft = computed(
  () =>
    unpublishedChangesStore.unpublishedConfig?.config?.status ===
    ConfigPublishStatusEnum.DRAFT.enum,
);

const isConfigPublishing: ComputedRef<boolean> = computed(
  () =>
    unpublishedChangesStore.unpublishedConfig?.config?.status ===
    ConfigPublishStatusEnum.PUBLISHING.enum,
);

const isConfigFailed: ComputedRef<boolean> = computed(
  () =>
    unpublishedChangesStore.unpublishedConfig?.config?.status ===
    ConfigPublishStatusEnum.FAILED.enum,
);

const reviewBannerContent = computed(() => {
  if (isConfigDraft.value) {
    return t("review_and_publish_banner.text.draft");
  } else if (isConfigPublishing.value) {
    return t("review_and_publish_banner.text.publishing");
  } else if (isConfigFailed.value) {
    return t("review_and_publish_banner.text.failed");
  }
  return "";
});

const reviewBannerActionText = computed(() => {
  if (isConfigDraft.value || isConfigFailed.value)
    return t("review_and_publish_banner.button.review_publish");
  return t("review_and_publish_banner.button.overview");
});

const reviewBannerStatus = computed(() => {
  if (isConfigPublishing.value || isConfigFailed.value) return "warning";
  return "info";
});

const successBannerContent =
  "Publication successful. Configuration changes have been published successfully.";
const successBannerStatus = "success";

const goToConfigOverview = () => {
  router.push({
    name: "ConfigPublishOverview",
    state: {
      backTo: props.backToPath,
      backToLabel: props.backToLabel,
    },
  });
};

watch(
  () => unpublishedChangesStore.unpublishedConfig?.config?.status,
  (newStatus) => {
    if (!newStatus) {
      return;
    }

    const lastStatus = getLastStoredStatus();

    if (newStatus === ConfigPublishStatusEnum.PUBLISHED.enum) {
      if (lastStatus !== ConfigPublishStatusEnum.PUBLISHED.enum) {
        if (!getStoredBannerState()) {
          isSuccessBannerVisible.value = true;

          successTimer = window.setTimeout(() => {
            isSuccessBannerVisible.value = false;
            successTimer = null;
          }, 5000);

          setStoredBannerState(true);
        }
      }
      isReviewBannerVisible.value = false;
    } else {
      if (lastStatus === ConfigPublishStatusEnum.PUBLISHED.enum) {
        setStoredBannerState(false);
      }

      if (successTimer) {
        clearTimeout(successTimer);
        successTimer = null;
      }
      isSuccessBannerVisible.value = false;

      isReviewBannerVisible.value =
        newStatus === ConfigPublishStatusEnum.DRAFT.enum ||
        newStatus === ConfigPublishStatusEnum.PUBLISHING.enum ||
        newStatus === ConfigPublishStatusEnum.FAILED.enum;
    }

    setLastStoredStatus(newStatus);
  },
  { immediate: true },
);

const getUnpublishedConfig = async () => {
  await unpublishedChangesStore.getUnpublishedConfig();
};

onMounted(async () => {
  await getUnpublishedConfig();
});

defineExpose({
  getUnpublishedConfig,
});
</script>

<template>
  <div v-if="isReviewBannerVisible" class="mm-mx-auto">
    <m-m-alert
      :status="reviewBannerStatus"
      data-cy="alert"
      has-call-to-action
      :is-closable="false"
      class="mm-mb-8"
    >
      {{ reviewBannerContent }}
      <template #actions>
        <m-m-button
          variant="elevated"
          size="medium"
          class="button-publish-changes"
          :is-disabled="uiStore.isSPViewerOnly"
          @click="goToConfigOverview"
        >
          {{ reviewBannerActionText }}
        </m-m-button>
      </template>
    </m-m-alert>
  </div>
  <div v-if="isSuccessBannerVisible" class="mm-mx-auto">
    <m-m-alert
      :status="successBannerStatus"
      data-cy="success-alert"
      :is-closable="false"
      class="mm-mb-8"
    >
      {{ successBannerContent }}
    </m-m-alert>
  </div>
</template>

<style scoped lang="scss">
.button-publish-changes {
  border-radius: 8px;
}
</style>
