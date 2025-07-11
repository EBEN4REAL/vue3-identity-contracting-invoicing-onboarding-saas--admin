<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import {
  EmptyStateType,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { OAuthClientBaseRead } from "~/onboarding/onboarding.types";
import { useRoute } from "vue-router";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { OauthClientRead } from "~/configuration/configuration.types";

const route = useRoute();

const props = defineProps({
  data: {
    type: Object as PropType<TableResponse<OAuthClientBaseRead>>,
    default: () => ({
      offset: 0,
      limit: 0,
      results: [],
      size: 0,
      total: 0,
    }),
  },
});

const isLoading: Ref<boolean> = ref(true);
const emptyState: EmptyStateType = {
  title: "Attribute set not added to any applications",
};
const headers = [
  {
    key: "name",
    label: "Name",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    key: "actions",
    label: "",
  },
];

const oAuthClients: Ref<OauthClientRead[]> = ref([]);

const tableDropdownItems = (
  oAuthClientBaseRead: OAuthClientBaseRead,
): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "link",
    to: `/sp/${route.params.service_provider_id}/applications/${oAuthClientBaseRead.id}`,
  },
];

const expandableCardTitle: ComputedRef<string> = computed(
  () => `Applications (${props.data?.total ?? 0})`,
);

const getServiceProviderOauthClients = async () => {
  try {
    isLoading.value = true;

    oAuthClients.value = await Promise.all(
      props.data
        ? props.data.results.map((serviceProviderOauthClient) =>
            oAuthClientsService.getServiceProviderOauthClient(
              serviceProviderOauthClient.id,
              serviceProviderOauthClient.service_provider_id,
            ),
          )
        : [],
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching service provider oauth clients",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="mm-page-subtitle--h2 mm-mb-7">
    All applications that use this attribute set.
  </div>
  <m-m-expandable-card
    :title="expandableCardTitle"
    is-opened
    class="mm-mb-12"
    cy="expandable-card-usages"
  >
    <m-m-table
      cy="table-applications"
      :headers="headers"
      :rows="oAuthClients"
      :is-loading="isLoading"
      :empty-state="emptyState"
      @update-params="getServiceProviderOauthClients"
    >
      <template #name="{ row }">
        <m-m-link
          :to="`/sp/${route.params.service_provider_id}/applications/${row.id}`"
          font-weigth="500"
          :cy="`name-${row?.id}`"
        >
          {{ row.name }}
        </m-m-link>
      </template>
      <template #description="{ row }">
        <m-m-text-ellipsis max-width="200px">
          {{ row.description || "-" }}
        </m-m-text-ellipsis>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="tableDropdownItems(row)"
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
  </m-m-expandable-card>
</template>
<style lang="css" scoped>
:deep(.mm-table) {
  padding: 0 24px 24px;
}
.mm-expandable-card--active {
  background-color: #f2f4f7;
}
:deep(.mm-expandable-card .mm-table .mm-table-body) {
  box-shadow: none;
  border: none;
  background: none;
}
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
:deep(.mm-table-body thead tr) {
  background-color: #fafbfc;
}
:deep(.mm-table-body) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body tr) {
  background-color: #fff;
}
</style>
