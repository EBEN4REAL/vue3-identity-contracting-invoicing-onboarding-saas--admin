<script setup lang="ts">
import { computed, PropType } from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import { TableHeader } from "~/mm_ui_kit/src/types/table.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";

const props = defineProps({
  defaultPolicies: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  optionalPolicies: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  routeLabel: {
    type: String,
    default: "",
  },
});

const defaultPoliciesHeaders: TableHeader[] = [
  {
    key: "external_facing_name",
    label: "Policy name",
  },
  {
    key: "external_facing_description",
    label: "Description",
  },
  {
    key: "actions",
    label: "",
  },
];

const defaultPoliciesDropdownItems = (id: string): TypeDropdownItem[] => [
  {
    label: "Go to policy",
    type: "link",
    to: `/sp/${props.serviceProviderId}/policy-types/${id}`,
  },
];

const optionalPoliciesDropdownItems = (id: string): TypeDropdownItem[] => [
  {
    label: "Go to policy",
    type: "link",
    to: `/sp/${props.serviceProviderId}/policy-types/${id}`,
  },
];
const agreementType = computed(() => {
  return props.routeLabel.toLowerCase() === "plans" ? "plan" : "license";
});

const emptyStateDefaultPolicies: string = "No default policies";
const emptyStateOptionalPolicies: string = "No optional policies";
const optionalPoliciesHeaders: TableHeader[] = [
  {
    key: "external_facing_name",
    label: "Policy name",
  },
  {
    key: "external_facing_description",
    label: "Description",
  },
  {
    key: "actions",
    label: "",
  },
];
</script>

<template>
  <div>
    <div class="mm-flex mm-flex-align-center mm-flex-justify-between">
      <div class="mm-page-title--h2 font-weight-600 mm-mb-2">
        Default policies
      </div>
    </div>
    <div class="mm-page-subtitle--h2 mm-mb-8">
      The default policy will be available for everyone assigned to this
      {{ agreementType }}.
    </div>
    <m-m-table
      :empty-state="emptyStateDefaultPolicies"
      :is-loading="isLoading"
      :headers="defaultPoliciesHeaders"
      :rows="defaultPolicies"
      cy="table-default-policies"
    >
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="defaultPoliciesDropdownItems(row.id as string)"
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
    <div class="mm-page-separator mm-my-12" />
    <div class="mm-flex mm-flex-align-center mm-flex-justify-between">
      <div class="mm-page-title--h2 font-weight-600 mm-mb-2">
        Optional policies
      </div>
    </div>
    <div class="mm-page-subtitle--h2 mm-mb-8">
      Customers can assign these policies optionally to their users as part of
      this {{ agreementType }}.
    </div>
    <m-m-table
      :headers="optionalPoliciesHeaders"
      :rows="optionalPolicies"
      :empty-state="emptyStateOptionalPolicies"
      cy="table-optional-policies"
    >
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="optionalPoliciesDropdownItems(row.id as string)"
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
  </div>
</template>
