<script setup lang="ts">
import { computed, ComputedRef, onMounted, PropType, Ref, ref } from "vue";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import tableHeaders from "./TableHeaders";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { EventRead } from "~/events/events.types";
import PayloadDialog from "../../Dialogs/EventPayloadDialog.vue";

const props = defineProps({
  events: {
    type: Object as PropType<TableResponse<EventRead>>,
    default: null,
  },
  isLoading: {
    type: Boolean,
    required: true,
    default: false,
  },
});

const emit = defineEmits(["update"]);
const description =
  "Events represent important actions made by your users on Veriam. The events are (/will be) used to generate statistics and reports and do not contain any (sensitive) user information.";
const selectedRow: Ref<EventRead | null> = ref(null);
const showPayloadDialog: Ref<boolean> = ref(false);

const initialQueryParams: Ref<TableRequestParams> = ref({
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});

const handleUpdateParams = (params: TableRequestParams) => {
  emit("update", {
    ...initialQueryParams.value,
    ...params,
  });
};

const formattedEvents: ComputedRef<EventRead[]> = computed(() => {
  if (!props.events?.results) {
    return [];
  }

  return props.events?.results.map((event) => ({
    ...event,
    formattedPayload: event.payload ? Object.keys(event.payload)[0] : "-",
    organization_name: event.organization_name ?? "-",
  }));
});

const openDialog = (row: EventRead) => {
  selectedRow.value = row;
  showPayloadDialog.value = true;
};

const closeDialog = () => {
  selectedRow.value = null;
  showPayloadDialog.value = false;
};

onMounted(() => {
  emit("update", initialQueryParams.value);
});
</script>

<template>
  <section class="tabs-content">
    <m-m-table
      cy="service-provider-event-Log-table"
      :is-loading="isLoading"
      :rows="formattedEvents"
      :headers="tableHeaders"
      :total-rows="events?.total"
      show-search
      :description="description"
      @update-params="handleUpdateParams"
    >
      <template #timestamp="{ row }">
        <m-m-formatted-date
          :raw-date="row.timestamp"
          format="D MMM YYYY, HH:mm"
        />
      </template>
      <template #type="{ row }"> {{ row.type }} </template>
      <template #payload="{ row }">
        <template v-if="row?.payload">
          <m-m-icon
            class="cursor-pointer"
            :data-cy="`event-log-table-eye-btn-${row.id}`"
            icon="eye"
            width="16px"
            @click="openDialog(row)"
          />
        </template>
        <span v-else>-</span>
      </template>
    </m-m-table>
    <payload-dialog
      :is-open="showPayloadDialog"
      :event="selectedRow"
      @close="closeDialog"
    />
  </section>
</template>
