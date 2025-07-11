<script setup lang="ts">
import { PropType, Ref, computed, onMounted, ref, watch } from "vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { PaginationSchema_PolicyTypeRead_ } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import { PaginationSchema_PolicyRead_ } from "~/service-providers/Policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  organizationId: {
    type: String,
    required: true,
  },
  allPolicies: {
    type: Object as PropType<PaginationSchema_PolicyRead_ | null>,
    default: () => {},
  },
  policyTypeCategoryId: {
    type: String,
    required: true,
    default: "",
  },
});

const emit = defineEmits(["closeDialog", "updatePolicies", "getPolicies"]);

const policies: Ref<PaginationSchema_PolicyTypeRead_ | null> = ref(null);
const filteredIds: Ref<string[]> = ref([]);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isButtonSubmitDisabled: Ref<boolean> = ref(true);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const isLoading: Ref<boolean> = ref(false);

const policiesFiltered = computed(() => {
  return policies.value?.results.map((policy) => ({
    ...policy,
    name: policy.external_facing_name,
    disabled: props.allPolicies?.results?.some(
      ({ type_id }) => type_id === policy.id,
    ),
  }));
});

const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const resetForm = () => {
  filteredIds.value = [];
};

const onDialogClose = () => {
  emit("closeDialog");
  resetForm();
};

const submit = async () => {
  try {
    isButtonSubmitLoading.value = true;
    isButtonSubmitDisabled.value = true;
    await Promise.all(
      filteredIds.value.map(async (id) => {
        await policiesService.assignPolicyToOrganization(
          props.serviceProviderId,
          {
            policy_type_id: id,
            organization_id: props.organizationId,
          },
        );
      }),
    );
    onDialogClose();
    emit("updatePolicies");
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = error.response?.data;
  } finally {
    isButtonSubmitLoading.value = false;
    isButtonSubmitDisabled.value = false;
  }
};

const getPolicies = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    const result = await policyTypesService.getPolicyTypes(
      props.serviceProviderId,
      {
        category_id: props.policyTypeCategoryId,
        ...(params || { limit: ITEMS_PER_PAGE[0], offset: "0" }),
      },
    );
    policies.value = result;
    emit("getPolicies", policies.value?.results);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching policies",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

watch(
  () => props.serviceProviderId,
  async () => {
    await getPolicies();
  },
);

watch(
  () => filteredIds.value,
  () => {
    isButtonSubmitDisabled.value = !Boolean(filteredIds.value.length);
  },
);

onMounted(async () => {
  if (props.serviceProviderId) {
    await getPolicies();
  }
});
</script>
<template>
  <div>
    <m-m-dialog
      :is-open="isOpen"
      title="Assign policy"
      icon="shield-check-light"
      cy="dialog-assign-policy"
      :has-divider="true"
      @close="onDialogClose"
    >
      <template #default>
        <m-m-alert
          v-if="isAlertVisible"
          status="error"
          cy="create-suborg-form-alert"
          class="mm-mb-12"
          @close="isAlertVisible = false"
        >
          {{ alertText }}
        </m-m-alert>
        <form v-mm-focus-first class="mm-page-dialog-form mm-mt-10">
          <div>
            <m-m-autocomplete
              id="autocomplete-multiple"
              v-model="filteredIds"
              placeholder="Search policy"
              label="Search & assign policies"
              cy="assign-policy-select-autocomplete"
              icon-prepended="search-lg"
              clear-button="x-circle"
              :items="policiesFiltered"
              :total-items="policies?.total"
              item-title="name"
              item-value="id"
              multiple
              :loading="isLoading"
              @update-params="getPolicies"
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
          :is-disabled="isButtonSubmitDisabled"
          :loading="isButtonSubmitLoading"
          @click="submit"
        >
          Assign policy
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
<style scoped lang="scss"></style>
