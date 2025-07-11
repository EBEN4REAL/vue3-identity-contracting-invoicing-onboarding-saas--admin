import { defineStore } from "pinia";
import { authService } from "~/auth/auth.service";
import { configurationService } from "~/configuration/configuration.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { UnpublishedChangesState } from "./types";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { UserProfileMM } from "~/auth/auth.types";

export const useUnpublishedConfigChangesStore = defineStore(
  "unpublishedConfigChanges",
  {
    state: (): UnpublishedChangesState => ({
      hasUnpublishedChanges: false,
      unpublishedConfig: null,
      serviceProviderId: "",
      configId: "",
      unpublishedConfigChanges: null,
      isConfigChangesLoading: false,
      configDetails: null,
      intervalId: null,
      hasShownSuccessBanner: false,
    }),
    getters: {
      configPublishStatus(): string {
        return this.unpublishedConfig?.config?.status ?? "";
      },
    },
    actions: {
      async getUnpublishedConfigChanges() {
        if (!this.configId) return;
        try {
          this.isConfigChangesLoading = true;
          this.unpublishedConfigChanges =
            await configurationService.getUnpublishedConfigChanges(
              this.serviceProviderId,
              this.configId,
            );
        } catch (error) {
          eventBus.$emit("onShowToast", {
            text: "Error fetching unpublished configuration changes",
            status: "error",
          });
        } finally {
          this.isConfigChangesLoading = false;
        }
      },
      async getConfigDetails(): Promise<void> {
        if (!this.configId) return;
        try {
          this.configDetails = await configurationService.getConfigDetails(
            this.serviceProviderId,
            this.configId,
          );
        } catch (error) {
          eventBus.$emit("onShowToast", {
            text: "Error fetching config details",
            status: "error",
          });
        }
      },
      async getUnpublishedConfig(): Promise<void> {
        try {
          const userProfile: UserProfileMM | null =
            await authService.getProfile();
          const serviceProviderId: string | undefined = userProfile?.sp_org;
          if (!serviceProviderId) {
            return;
          }
          this.serviceProviderId = serviceProviderId;
          this.unpublishedConfig =
            await configurationService.getConfig(serviceProviderId);

          this.hasUnpublishedChanges = Boolean(
            this.unpublishedConfig?.config?.status ===
              ConfigPublishStatusEnum.DRAFT.enum ||
              this.unpublishedConfig?.config?.status ===
                ConfigPublishStatusEnum.PUBLISHING.enum ||
              this.unpublishedConfig?.config?.status ===
                ConfigPublishStatusEnum.FAILED.enum ||
              this.unpublishedConfig?.config?.status ===
                ConfigPublishStatusEnum.PUBLISHED.enum,
          );
          if (this.unpublishedConfig?.config?.id) {
            this.configId = this.unpublishedConfig.config.id;
          }
        } catch (error) {
          if (error.response?.status === 404) return;
          eventBus.$emit("onShowToast", {
            text: "Error fetching unpublished config changes",
            status: "error",
          });
        }
      },
    },
  },
);
