<script setup lang="ts">
import { PropType } from "vue";
import { useRoute, useRouter } from "vue-router";
import {
  FilterRead,
  PolicyTypePerFilterRead,
} from "~/service-providers/Filters/filters.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";

const route = useRoute();
const router = useRouter();

defineProps({
  policyTypes: {
    type: Array as PropType<PolicyTypePerFilterRead[]>,
    default: () => [],
  },
  parentFilters: {
    type: Array as PropType<FilterRead[]>,
    default: () => [],
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
});

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

const tablePolicyDropdownItems = (id: string): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "button",
    onClick: () => {
      goToPolicyDetails(id);
    },
  },
];

const tableFiltersDropdownItems = (id: string): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "button",
    onClick: () => {
      goToFilterDetails(id);
    },
  },
];

const goToPolicyDetails = (id: string) => {
  router.push({
    name: "PolicyTypeDetail",
    params: {
      service_provider_id: route.params.service_provider_id.toString(),
      policy_type_id: id,
    },
  });
};

const goToFilterDetails = (id: string) => {
  router.push({
    name: "FilterDetails",
    params: {
      service_provider_id: route.params.service_provider_id.toString(),
      filter_id: id,
    },
  });
};
</script>

<template>
  <div class="mm-page-subtitle--h2 mm-mb-7">
    All items that use this filter.
  </div>
  <m-m-expandable-card title="Policies" is-opened class="mm-mb-12">
    <m-m-table
      cy="table-policies"
      :headers="headers"
      :rows="policyTypes"
      :is-loading="isLoading"
      empty-state="No policies"
    >
      <template #name="{ row }">
        <m-m-link
          :to="`/sp/${route.params.service_provider_id.toString()}/policy-types/${row.id}`"
          font-weigth="500"
          :cy="`name-${row?.id}`"
        >
          {{ row.name }}
        </m-m-link>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="tablePolicyDropdownItems(row.id)"
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
  <m-m-expandable-card
    v-if="parentFilters"
    title="Filters"
    is-opened
    class="mm-mb-12"
  >
    <m-m-table
      cy="table-filters"
      :headers="headers"
      :rows="parentFilters"
      empty-state="No filters"
    >
      <template #name="{ row }">
        <m-m-link
          :to="`/sp/${route.params.service_provider_id.toString()}/filters/${row.id}`"
          font-weigth="500"
          :cy="`name-${row?.id}`"
        >
          {{ row.name }}
        </m-m-link>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="tableFiltersDropdownItems(row.id)"
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
