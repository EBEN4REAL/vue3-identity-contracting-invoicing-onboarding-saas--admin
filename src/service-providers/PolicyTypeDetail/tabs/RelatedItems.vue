<script lang="ts" setup>
import { onMounted, PropType, Ref, ref } from "vue";
import { PolicyTypeUsageRead } from "~/policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";

const agreementsHeaders = [
  { key: "external_facing_name", label: "Name" },
  { key: "external_facing_description", label: "Description" },
  { key: "actions", label: "" },
];
const policiesHeaders = [
  { key: "name", label: "Name" },
  { key: "description", label: "Description" },
  { key: "actions", label: "" },
];

const props = defineProps({
  serviceProviderId: {
    type: String,
    required: true,
  },
  parentPolicyType: {
    type: Object as PropType<SPPolicyTypeRead>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
    default: false,
  },
  activeCategoryName: {
    type: String,
    required: true,
    default: "",
  },
});

const usage: Ref<PolicyTypeUsageRead | null> = ref(null);

const fetchUsage = async () => {
  if (!props.parentPolicyType?.id || !props.serviceProviderId) {
    return;
  }

  usage.value = await policiesService.getPolicyTypeUsage(
    props.serviceProviderId as string,
    props.parentPolicyType.id,
  );
};

onMounted(async () => {
  await fetchUsage();
});
</script>

<template>
  <div class="mm-flex mm-flex-column mm-flex-gap-12">
    <div class="mm-page-subtitle--h2">
      All items that use this {{ activeCategoryName.toLocaleLowerCase() }}.
    </div>

    <m-m-expandable-card
      v-if="usage?.policies"
      :title="`Parent policies (${usage.policies.length})`"
      is-opened
      cy="policies-card"
    >
      <m-m-table
        :headers="policiesHeaders"
        :is-loading="isLoading"
        empty-state="No policies"
        :rows="usage.policies"
        is-inset
        class="mm-w-10"
        cy="child-policy-types"
      >
        <template #name="{ row }">
          <m-m-link
            :to="`/sp/${serviceProviderId}/policy-types/${row.id}`"
            font-weigth="500"
            :cy="`name-${row?.id}`"
          >
            {{ row.name }}
          </m-m-link>
        </template>
        <template #actions="{ row }">
          <m-m-dropdown
            :cy="`dropdown-${row.id}`"
            :items="[
              {
                label: 'View details',
                type: 'link',
                to: `/sp/${serviceProviderId}/policy-types/${row.id}`,
              },
            ]"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="text"
                :cy="`actions-button-${row.id}`"
              />
            </template>
          </m-m-dropdown>
        </template>
      </m-m-table>
    </m-m-expandable-card>

    <m-m-expandable-card
      v-if="usage?.agreements"
      :title="`Licenses (${usage.agreements.length})`"
      is-opened
      cy="agreements-card"
    >
      <m-m-table
        :headers="agreementsHeaders"
        :rows="usage.agreements"
        empty-state="No licenses"
        is-inset
        :is-loading="isLoading"
        class="mm-w-10"
        cy="child-agreements"
      >
        <template #external_facing_name="{ row }">
          <m-m-link
            :to="`/sp/${serviceProviderId}/licenses/${row.id}`"
            font-weigth="500"
            :cy="`name-${row?.id}`"
          >
            {{ row.external_facing_name }}
          </m-m-link>
        </template>
        <template #actions="{ row }">
          <m-m-dropdown
            :cy="`dropdown-${row.id}`"
            :items="[
              {
                label: 'View details',
                type: 'link',
                to: `/sp/${serviceProviderId}/licenses/${row.id}`,
              },
            ]"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="text"
                :cy="`actions-button-${row.id}`"
              />
            </template>
          </m-m-dropdown>
        </template>
      </m-m-table>
    </m-m-expandable-card>
  </div>
</template>
<style lang="css" scoped>
:deep(.mm-table) {
  padding: 0 24px 24px;
}
:deep(.mm-expandable-card--active) {
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
