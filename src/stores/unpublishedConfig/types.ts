import { components } from "~/configuration/configuration.schemas";
import {
  ConfigChangeRead,
  ConfigRead,
} from "~/configuration/configuration.types";
import { TableResponse } from "~/mm_ui_kit/src/types/table.types";

export interface UnpublishedChangesState {
  hasUnpublishedChanges: boolean;
  unpublishedConfig: ServiceProviderConfigRead | null;
  serviceProviderId: string;
  configId: string;
  unpublishedConfigChanges: TableResponse<ConfigChangeRead> | null;
  isConfigChangesLoading: boolean;
  configDetails: ConfigRead | null;
  intervalId: number | null;
  hasShownSuccessBanner: boolean;
}

export type ServiceProviderConfigRead =
  components["schemas"]["ServiceProviderConfigRead"];

export type ConfigRead = components["schemas"]["ConfigRead"];
