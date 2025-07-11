<script setup lang="ts">
import { Ref, ref } from "vue";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import useActiveTab from "~/mm_ui_kit/src/composables/activeTabIndexBasedOnURL";
import AuditLog from "./Tabs/AuditLog/Index.vue";
import EventLog from "./Tabs/EventLog/Index.vue";
import AccessLog from "./Tabs/AccessLog/Index.vue";
import { authService } from "~/auth/auth.service";
import { EventRead } from "~/events/events.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { eventsService } from "~/events/events.service";
import { AccessEvaluationBaseRead, AuditEventRead } from "~/iam/iam.types";
import { auditEventsService } from "./Tabs/AuditLog/audit-events.service";
import { UserProfileMM } from "~/auth/auth.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  accessEvaluationsService,
  TypeAccessEvaluationsParams,
} from "~/access-logs/access-logs.service";

const isLoading: Ref<boolean> = ref(true);
const events: Ref<TableResponse<EventRead>> = ref(null);
const auditEvents: Ref<TableResponse<AuditEventRead>> = ref(null);
const accessLogs: Ref<TableResponse<AccessEvaluationBaseRead>> = ref(null);
const userProfile: Ref<UserProfileMM | null> = ref(null);

const TABS: TypeTab[] = [
  { label: "Event log", name: "Event log", isRequired: false },
  { label: "Audit log", name: "Audit log", isRequired: false },
  {
    label: "Access log",
    name: "Access log",
    isRequired: false,
  },
];

const activeTab = useActiveTab(TABS[0].name);

const getUser = async () => {
  userProfile.value = await authService.getProfile();
};

const getEventLog = async (params: TableRequestParams) => {
  try {
    await getUser();
    if (!userProfile.value?.sp_org) {
      return;
    }
    isLoading.value = true;
    const service_provider_id = userProfile.value?.sp_org;
    events.value = await eventsService.getEvents(service_provider_id, params);
  } catch (error) {
    console.error("Error fetching event log", error);
  } finally {
    isLoading.value = false;
  }
};

const getAuditLog = async (params: TableRequestParams) => {
  try {
    await getUser();
    if (!userProfile.value?.sp_org) {
      return;
    }
    isLoading.value = true;
    const service_provider_id = userProfile.value?.sp_org;
    auditEvents.value = await auditEventsService.getAuditEvents(
      service_provider_id,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching audit events",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const getAccessEvaluations = async (params: TypeAccessEvaluationsParams) => {
  try {
    isLoading.value = true;
    accessLogs.value = await accessEvaluationsService.getAccessEvaluations({
      service_provider_id: userProfile.value?.sp_org,
      ...params,
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching access logs",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const updateTabEvents = async (params: TableRequestParams) => {
  activeTab.value = TABS[0].name;
  await getEventLog({ ...params });
};

const updateTabAudits = async (params: TableRequestParams) => {
  activeTab.value = TABS[1].name;
  await getAuditLog({ ...params });
};

const updateTabAccessLogs = async (params: TableRequestParams) => {
  activeTab.value = TABS[2].name;
  await getAccessEvaluations({ ...params });
};
</script>

<template>
  <m-m-overview-page resource-id="logs" :show-config-banner="false">
    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs v-model="activeTab" :items="TABS" />
    </m-m-teleport>
    <m-m-tab-items :current-tab="activeTab">
      <m-m-tab-item :name="TABS[0].name">
        <event-log
          :events="events"
          :is-loading="isLoading"
          @update="updateTabEvents"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[1].name">
        <audit-log
          :audit-events="auditEvents"
          :is-loading="isLoading"
          @update="updateTabAudits"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[2].name">
        <access-log
          :access-logs="accessLogs"
          :is-loading="isLoading"
          @update="updateTabAccessLogs"
        />
      </m-m-tab-item> </m-m-tab-items
  ></m-m-overview-page>
</template>
