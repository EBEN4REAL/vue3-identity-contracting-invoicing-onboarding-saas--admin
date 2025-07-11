<script setup lang="ts">
import { computed, ComputedRef, ref, watch, Ref } from "vue";
import {
  OAuthClientPolicyAssignmentCreate,
  OAuthClientPolicyAssignmentRead,
  PolicyTypeRead,
} from "~/policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { TypeFormattedAutocompletePolicies } from "~/service-providers/Policies/policies.types";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  applicationId: {
    type: String,
    default: "",
  },
  applicationName: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["close", "update"]);

const policiesValue: Ref<string[]> = ref([]);
const policies: Ref<PolicyTypeRead[]> = ref([]);
const totalItems: Ref<number> = ref(0);
const isLoading: Ref<boolean> = ref(false);
const isSubmitButtonDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const mappedPolicies: Ref<TableResponse<OAuthClientPolicyAssignmentRead> | null> =
  ref(null);

const subtitle: ComputedRef<string> = computed(
  () => `Select the policies to be assigned to ${props.applicationName}`,
);

const formattedPolicies: ComputedRef<TypeFormattedAutocompletePolicies[]> =
  computed(() => {
    const assignedPolicyNames = new Set(
      mappedPolicies.value?.results.map(
        (policy: OAuthClientPolicyAssignmentRead) => policy.policy_type.name,
      ),
    );

    return (policies.value || []).map((policy) => ({
      value: policy.id,
      name: policy.name,
      disabled: assignedPolicyNames.has(policy.name),
    }));
  });

const getPolicyTypes = async (params?: TableRequestParams) => {
  isLoading.value = true;
  const policiesRes = await policiesService.getPolicies(
    props.serviceProviderId,
    params,
  );
  isLoading.value = false;
  policies.value = policiesRes?.results || [];
  totalItems.value = policiesRes?.total || 0;
};

const fetchPolicyTypes = async () => {
  await getPolicyTypes({
    limit: ITEMS_PER_PAGE[0],
    offset: "0",
  });
};

const fetchMappedPolicies = async () => {
  await getMappedPolices({
    limit: ITEMS_PER_PAGE[0],
    offset: "0",
  });
};

watch(
  [() => props.isOpen, () => props.applicationId],
  async ([isOpen, applicationId]) => {
    if (isOpen) {
      policiesValue.value = [];
      policies.value = [];
      if (applicationId) {
        await fetchPolicyTypes();
        await fetchMappedPolicies();
      }
    }
  },
  { immediate: true },
);

const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const getMappedPolices = async (params: TableRequestParams) => {
  mappedPolicies.value = await policiesService.getPoliciesForApplication(
    props.serviceProviderId,
    props.applicationId as string,
    params,
  );
};

const onSubmit = async () => {
  isSubmitButtonDisabled.value = true;
  isSubmitButtonLoading.value = true;
  try {
    const payload: OAuthClientPolicyAssignmentCreate = {
      ids: policiesValue.value,
    };
    await policiesService.addPoliciesToOAuth(
      props.serviceProviderId,
      props.applicationId,
      payload,
    );
    emit("update");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error assigning policies",
      status: "error",
    });
  } finally {
    isSubmitButtonDisabled.value = false;
    isSubmitButtonLoading.value = false;
  }
};

watch(
  () => policiesValue.value,
  () => {
    isSubmitButtonDisabled.value = !Boolean(policiesValue.value.length);
  },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Assign policies"
    :subtitle="subtitle"
    icon="shield-check-light"
    cy="dialog-assign-policies"
    @close="emit('close')"
  >
    <template #default>
      <m-m-autocomplete
        id="autocomplete-multiple"
        v-model="policiesValue"
        placeholder="Search policy"
        label="Search & assign policies"
        cy="select-policies"
        icon-prepended="search-lg"
        clear-button="x-circle"
        :items="formattedPolicies"
        :total-items="totalItems"
        item-title="name"
        item-value="value"
        multiple
        :loading="isLoading"
        @update-params="getPolicyTypes"
      >
        <template #option="{ item }">
          <div class="mm-flex mm-flex-justify-between mm-w-10">
            <div :class="selectPolicyOptionClassList(item.disabled)">
              {{ item.name }}
              <div
                v-if="item.disabled"
                class="mm-flex mm-flex-justify-between mm-flex-grow"
              >
                <m-m-badge
                  class="mm-ml-3"
                  :status="BadgeTypes.Inactive"
                  text="Already added"
                  cy="badge-added"
                />
                <m-m-icon icon="check-thin-primary" width="12px" />
              </div>
            </div>
          </div>
        </template>
      </m-m-autocomplete>
    </template>
    <template #footer>
      <m-m-button
        variant="outlined"
        min-width="100px"
        cy="button-cancel"
        @click="emit('close')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        cy="button-submit"
        @click="onSubmit"
      >
        Yes, assign
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
