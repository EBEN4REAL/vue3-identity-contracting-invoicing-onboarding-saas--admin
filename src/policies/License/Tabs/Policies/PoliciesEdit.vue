<script setup lang="ts">
import { computed, PropType, Ref, ref } from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import { TableHeader } from "~/mm_ui_kit/src/types/table.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import DeletePolicyModal from "./Dialogs/DeletePolicyModal.vue";

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

const emit = defineEmits([
  "removeDefaultPolicy",
  "removeOptionalPolicy",
  "openDialogAddDefaultPolicies",
  "openDialogAddOptionalPolicies",
]);

const isDeletePolicyDialogOpen: Ref<boolean> = ref(false);
const selectedPolicyId: Ref<string | null> = ref(null);
const isOptionalPolicySelected: Ref<boolean> = ref(false);
const defaultPoliciesDropdownItems = (id: string): TypeDropdownItem[] => [
  {
    label: "Go to policy",
    type: "link",
    to: `/sp/${props.serviceProviderId}/policy-types/${id}`,
  },
  {
    label: "Delete policy",
    color: "error",
    type: "button",
    onClick: () => {
      isOptionalPolicySelected.value = false;
      onOpenDialogDeletePolicy(id);
    },
  },
];

const optionalPoliciesDropdownItems = (id: string): TypeDropdownItem[] => [
  {
    label: "Go to policy",
    type: "link",
    to: `/sp/${props.serviceProviderId}/policy-types/${id}`,
  },
  {
    label: "Delete policy",
    type: "button",
    color: "error",
    onClick: () => {
      isOptionalPolicySelected.value = true;
      onOpenDialogDeletePolicy(id);
    },
  },
];

const agreementType = computed(() => {
  return props.routeLabel.toLowerCase() === "plans" ? "plan" : "license";
});
const emptyStateDefaultPolicies: string = "No default policies";
const emptyStateOptionalPolicies: string = "No optional policies";
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

const onRemoveDefaultPolicy = (): void => {
  emit("removeDefaultPolicy", selectedPolicyId.value);
  isDeletePolicyDialogOpen.value = false;
};
const onRemoveOptionalPolicy = (): void => {
  emit("removeOptionalPolicy", selectedPolicyId.value);
  isDeletePolicyDialogOpen.value = false;
};
const onOpenDialogAddDefaultPolicy = (): void => {
  emit("openDialogAddDefaultPolicies");
};
const onOpenDialogAddOptionalPolicy = (): void => {
  emit("openDialogAddOptionalPolicies");
};
const onOpenDialogDeletePolicy = (id: string): void => {
  selectedPolicyId.value = id;
  isDeletePolicyDialogOpen.value = true;
};

const closeDialog = (): void => {
  isDeletePolicyDialogOpen.value = false;
  selectedPolicyId.value = null;
};
</script>

<template>
  <div>
    <div class="mm-flex mm-flex-align-center mm-flex-justify-between">
      <div class="mm-page-title--h2 font-weight-600 mm-mb-2">
        Default policies
      </div>
      <m-m-button
        variant="outlined"
        prepend-icon="plus"
        size="small"
        cy="button-open-dialog-add-default-policies"
        @click="onOpenDialogAddDefaultPolicy"
      >
        Add default policy
      </m-m-button>
    </div>
    <div class="mm-page-subtitle--h2 mm-mb-8">
      The default policy will be available for everyone assigned to this
      {{ agreementType }}.
    </div>
    <m-m-table
      :is-loading="isLoading"
      :headers="defaultPoliciesHeaders"
      :rows="defaultPolicies"
      :empty-state="emptyStateDefaultPolicies"
      cy="table-default-policies"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          prepend-icon="plus-white"
          size="small"
          cy="empty-state-button-open-dialog-add-default-policies"
          @click="onOpenDialogAddDefaultPolicy"
        >
          Add default policy
        </m-m-button>
      </template>
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
      <m-m-button
        variant="outlined"
        prepend-icon="plus"
        size="small"
        cy="button-open-dialog-add-optional-policies"
        @click="onOpenDialogAddOptionalPolicy"
      >
        Add optional policy
      </m-m-button>
    </div>
    <div class="mm-page-subtitle--h2 mm-mb-8">
      Customers can assign these policies optionally to their users as part of
      this {{ agreementType }}.
    </div>
    <m-m-table
      :headers="optionalPoliciesHeaders"
      :rows="optionalPolicies"
      :is-loading="isLoading"
      :empty-state="emptyStateOptionalPolicies"
      cy="table-optional-policies"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          prepend-icon="plus-white"
          size="small"
          cy="empty-state-button-open-dialog-add-optional-policies"
          @click="onOpenDialogAddOptionalPolicy"
        >
          Add optional policy
        </m-m-button>
      </template>
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
    <delete-policy-modal
      :is-open="isDeletePolicyDialogOpen"
      :policy-id="selectedPolicyId || ''"
      :is-optional="isOptionalPolicySelected"
      @close-dialog="closeDialog"
      @remove-default-policy="onRemoveDefaultPolicy"
      @remove-optional-policy="onRemoveOptionalPolicy"
    />
  </div>
</template>

<style scoped lang="scss"></style>
