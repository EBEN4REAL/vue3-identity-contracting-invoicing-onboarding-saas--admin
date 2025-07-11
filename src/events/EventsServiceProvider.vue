<script setup lang="ts">
import { ref, Ref } from "vue";
import { authService } from "~/auth/auth.service";
import { eventsService, GetEventsRequest } from "./events.service";
import { PaginationSchema_EventRead_ } from "./events.types";
import {
  itemsPerPageDefault,
  itemsPerPageOptions,
  Pagination,
} from "~/common/pagination";

const serviceProviderId: Ref<string | null> = ref(null);
const loading: Ref<boolean> = ref(true);
const itemsPerPage: Ref<number> = ref(itemsPerPageDefault);
const events: Ref<PaginationSchema_EventRead_[] | null> = ref(null);

const getEvents = async (pagination: Pagination) => {
  if (!serviceProviderId.value) {
    const profile = await authService.getProfile();
    if (profile?.sp_org) {
      serviceProviderId.value = profile.sp_org;
    } else {
      return;
    }
  }
  loading.value = true;
  const getEventsRequest: GetEventsRequest = {
    offset: ((pagination.page - 1) * pagination.itemsPerPage).toString(),
    limit: pagination.itemsPerPage.toString(),
    service_provider_id: serviceProviderId.value,
  };
  events.value = await eventsService.getEvents(getEventsRequest);
  loading.value = false;
};

const headers = [
  {
    title: "Type",
    key: "type",
    sortable: false,
  },
  {
    title: "Date",
    key: "timestamp",
    sortable: false,
  },
  {
    title: "Organization",
    key: "organization_id",
    sortable: false,
  },
  {
    title: "Payload",
    key: "payload",
    sortable: false,
  },
];
</script>

<template>
  <v-container>
    <v-responsive class="align-center text-center fill-height">
      <h2>Service provider events</h2>
      <v-data-table-server
        id="service-provider-events"
        v-model:items-per-page="itemsPerPage"
        :headers="headers"
        :loading="loading"
        :items-length="events?.total || 0"
        :items="events?.results || []"
        :items-per-page-options="itemsPerPageOptions"
        @update:options="getEvents"
      />
    </v-responsive>
  </v-container>
</template>

<style scoped></style>
