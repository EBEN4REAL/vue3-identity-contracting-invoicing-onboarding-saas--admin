<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { policiesService } from "~/service-providers/policies.service";
import DialogAssignPolicies from "../../Dialogs/DialogAssignPolicies.vue";
import DialogUnassignPolicy from "../../Dialogs/DialogUnassignPolicy.vue";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import {
  OAuthClientPolicyAssignmentRead,
  PolicyType,
} from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { useTranslation } from "i18next-vue";
import { useUiStore } from "~/stores/useUiStore";

const { t } = useTranslation();
const uiStore = useUiStore();
const props = defineProps({
  isInEditMode: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
});

const policies: Ref<TableResponse<OAuthClientPolicyAssignmentRead> | null> =
  ref(null);
const isDialogAssignPoliciesOpen: Ref<boolean> = ref(false);
const isDialogUnassignPolicyOpen: Ref<boolean> = ref(false);
const policyTypeToUnassignId: Ref<string> = ref("");
const isLoading: Ref<boolean> = ref(true);
const headers: ComputedRef<TableHeader[]> = computed(() => [
  {
    label: t(
      "configuration.applications.application_details.tab_policies.table_headers.name",
    ),
    key: "name",
  },
  {
    label: t(
      "configuration.applications.application_details.tab_policies.table_headers.description",
    ),
    key: "description",
  },
  {
    label: "",
    key: "actions",
  },
]);

const isButtonAssignPolicyDisabled: ComputedRef<boolean> = computed(
  () => props.isInEditMode || uiStore.isSPViewerOnly,
);

const description: string =
  "Policies assigned to this application. All assigned policies are applied for every user who logs in on your application.";
const dropdownItems = (row: PolicyType): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "link",
    to: `/sp/${props.serviceProviderId}/policy-types/${row.policy_type.id}`,
  },
  {
    label: "Remove policy",
    isDisabled: uiStore.isSPViewerOnly,
    type: "button",
    color: "error",
    onClick: () => {
      policyTypeToUnassignId.value = row.id;
      onDialogUnassignPolicyOpen();
    },
  },
];

const assignedPolicies: ComputedRef<PolicyType[]> = computed(
  () =>
    policies.value?.results.map((policyItem) => ({
      id: policyItem.policy_id,
      name: policyItem.policy_type.name,
      description: policyItem.policy_type.description,
      policy_type: policyItem.policy_type,
    })) || [],
);

const onDialogAssignPolicyOpen = () => {
  isDialogAssignPoliciesOpen.value = true;
};

const onDialogAssignPoliciesClose = () => {
  isDialogAssignPoliciesOpen.value = false;
};

const onDialogUnassignPolicyOpen = () => {
  isDialogUnassignPolicyOpen.value = true;
};

const onDialogUnassignPolicyClose = () => {
  isDialogUnassignPolicyOpen.value = false;
};

const getPoliciesForApplication = async (params: TableRequestParams) => {
  isLoading.value = true;
  policies.value = await policiesService.getPoliciesForApplication(
    props.serviceProviderId as string,
    oAuthClientsService.state.oAuthClient?.id as string,
    params,
  );
  isLoading.value = false;
};
</script>

<template>
  <m-m-table
    :headers="headers"
    :rows="assignedPolicies"
    :is-loading="isLoading"
    :total-rows="policies?.total"
    empty-state="No policies"
    show-search
    cy="table-policies"
    :description="description"
    @update-params="getPoliciesForApplication"
  >
    <template #name="{ row }">
      <m-m-link
        :to="`/sp/${serviceProviderId}/policy-types/${row.policy_type.id}`"
        font-weigth="500"
        :cy="`name-${row?.id}`"
      >
        {{ row.name }}
      </m-m-link>
    </template>
    <template #empty-state-button>
      <m-m-button
        prepend-icon="plus-white"
        size="small"
        class="mm-ml-auto"
        cy="empty-state-button-assign-policy"
        :disabled="isButtonAssignPolicyDisabled"
        @click="onDialogAssignPolicyOpen"
      >
        {{
          $t(
            "configuration.applications.application_details.tab_policies.assign_button",
          )
        }}
      </m-m-button>
    </template>
    <template v-if="!isInEditMode" #action>
      <m-m-button
        variant="outlined"
        prepend-icon="plus"
        size="small"
        class="mm-ml-auto"
        cy="button-assign-policy"
        :disabled="isButtonAssignPolicyDisabled"
        @click="onDialogAssignPolicyOpen"
      >
        {{
          $t(
            "configuration.applications.application_details.tab_policies.assign_button",
          )
        }}
      </m-m-button>
    </template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown
          list-side="left"
          :items="dropdownItems(row)"
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
  <dialog-assign-policies
    :is-open="isDialogAssignPoliciesOpen"
    :service-provider-id="serviceProviderId"
    :application-id="oAuthClientsService.state.oAuthClient?.id"
    :application-name="oAuthClientsService.state.oAuthClient?.name"
    @update="getPoliciesForApplication"
    @close="onDialogAssignPoliciesClose"
  />
  <dialog-unassign-policy
    :is-open="isDialogUnassignPolicyOpen"
    :service-provider-id="serviceProviderId"
    :application-id="oAuthClientsService.state.oAuthClient?.id"
    :application-name="oAuthClientsService.state.oAuthClient?.name"
    :policy-id="policyTypeToUnassignId"
    @update="getPoliciesForApplication"
    @close="onDialogUnassignPolicyClose"
  />
</template>
