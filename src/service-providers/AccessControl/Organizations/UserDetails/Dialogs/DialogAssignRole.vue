<script setup lang="ts">
import { ComputedRef, PropType, Ref, computed, ref, watch } from "vue";
import { ServiceProviderOrganizationUserRead } from "~/iam/iam.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import {
  PolicyRead,
  TypeFormattedAutocompletePolicies,
} from "~/service-providers/Policies/policies.types";

const props = defineProps({
  data: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  organizationId: {
    type: String,
    required: true,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  user: {
    type: Object as PropType<ServiceProviderOrganizationUserRead>,
    default: () => ({}),
  },
  assignedPolicies: {
    type: Array as PropType<PolicyRead[]>,
    default: () => [],
  },
  categoryId: {
    type: String,
    required: true,
  },
});

const isButtonSubmitDisabled = ref(true);
const isButtonSubmitLoading = ref(false);
const isLoading = ref(false);

const emit = defineEmits(["closeDialog", "rolesUpdated", "getRoles"]);

const policies: Ref<PolicyTypeRead[]> = ref([]);
const totalPoliciesCount: Ref<number> = ref(0);
const filteredItems: Ref<string[] | null> = ref([]);
const assignedPoliciesResults: Ref<TableResponse<PolicyTypeRead> | null> =
  ref(null);

const formattedPolicies: ComputedRef<TypeFormattedAutocompletePolicies[]> =
  computed(() => {
    return (policies.value || []).map((policy) => ({
      value: policy.id,
      name: policy.name,
      disabled: policy.is_assigned,
    }));
  });

const resetForm = () => {
  filteredItems.value = [];
};

const onDialogClose = () => {
  emit("closeDialog");
  resetForm();
};

const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const fetchAssignedPolicies = async (policyIds: string[]) => {
  try {
    assignedPoliciesResults.value =
      await policiesService.getServiceProviderPoliciesOrganizationUsers(
        props.serviceProviderId,
        {
          policy_type_ids: policyIds,
          organization_user_id: props?.user?.organization_user?.id as string,
        },
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching assigned policies",
      status: "error",
    });
  }
};

const getRoles = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    const policiesResults = await policiesService.getPolicies(
      props.serviceProviderId,
      params
        ? params
        : {
            limit: ITEMS_PER_PAGE[0],
            offset: "0",
            category_id: props.categoryId,
          },
    );

    const policyIds = policiesResults?.results.map((policy) => policy.id);
    await fetchAssignedPolicies(policyIds);

    const assignedPolicyNames = new Set(
      assignedPoliciesResults?.value?.results.map((policy) => policy.name),
    );

    policies.value =
      policiesResults?.results.map((policy) => ({
        ...policy,
        is_assigned: assignedPolicyNames.has(policy.name),
      })) || [];

    totalPoliciesCount.value = policiesResults?.total || 0;
    emit("getRoles", policies.value);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching policies",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const submit = async () => {
  try {
    if (filteredItems.value) {
      isButtonSubmitDisabled.value = true;
      isButtonSubmitLoading.value = true;
      for (const item of filteredItems.value) {
        await policiesService.assignPolicy(props.serviceProviderId, {
          policy_type_id: item,
          organization_user_id: props?.user?.organization_user?.id as string,
          organization_id: props.organizationId,
        });
      }
      emit("rolesUpdated");
      onDialogClose();
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  } finally {
    isButtonSubmitDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

watch(
  () => filteredItems.value,
  () => {
    isButtonSubmitDisabled.value = !Boolean(filteredItems.value?.length);
  },
);
</script>
<template>
  <div>
    <m-m-dialog
      :is-open="isOpen"
      title="Assign role"
      icon="shield-check-light"
      cy="dialog-assign-role"
      :has-divider="true"
      @close="onDialogClose"
    >
      <template #default>
        <form v-mm-focus-first class="mm-page-dialog-form mm-mt-10">
          <div>
            <m-m-autocomplete
              id="autocomplete-multiple"
              v-model="filteredItems"
              placeholder="Search role"
              label="Search & assign roles"
              cy="assign-policy-select"
              icon-prepended="search-lg"
              clear-button="x-circle"
              :items="formattedPolicies"
              :total-items="totalPoliciesCount"
              item-title="name"
              item-value="value"
              multiple
              :loading="isLoading"
              @update-params="getRoles"
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
          </div>
        </form>
      </template>
      <template #footer>
        <m-m-button variant="outlined" cy="button-cancel" @click="onDialogClose"
          >Cancel</m-m-button
        >
        <m-m-button
          prepend-icon="plus-white"
          variant="elevated"
          cy="button-submit"
          :loading="isButtonSubmitLoading"
          :is-disabled="isButtonSubmitDisabled"
          @click="submit"
        >
          Assign role
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
<style scoped lang="scss"></style>
