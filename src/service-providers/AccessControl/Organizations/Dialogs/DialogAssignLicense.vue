<script setup lang="ts">
import { PropType, Ref, computed, onMounted, ref, watch } from "vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import {
  AgreementTypePoliciesCountAllocatedRead,
  SPAgreementRead,
} from "~/service-providers/Licenses/licenses.types";
import { policiesService } from "~/service-providers/policies.service";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { agreementTypesService } from "~/configuration/agreement-types.service";

const props = defineProps({
  customer: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    required: true,
  },
  licenses: {
    type: Object as PropType<TableResponse<SPAgreementRead>>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["closeDialog", "updateAgreements"]);

const filteredItems: Ref<string[]> = ref([]);
const agreements: Ref<AgreementTypePoliciesCountAllocatedRead | null> =
  ref(null);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isButtonSubmitDisabled: Ref<boolean> = ref(true);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const activeAgreements: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
const currentParams: Ref<TableRequestParams | null> = ref(null);
const totalAgreements: Ref<number> = ref(0);
const isLoading: Ref<boolean> = ref(false);

const resetForm = () => {
  filteredItems.value = [];
};

const onDialogClose = () => {
  emit("closeDialog");
  resetForm();
};

const selectLicenseOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const formattedAgreements = computed(() => {
  const activeLicenses = activeAgreements.value?.results || [];
  const activeAgreementNames = new Set(
    activeLicenses.map((item) => item.agreement_name),
  );

  const updatedAgreements = (agreements.value || []).map(
    (license: { name: string }) => {
      if (activeAgreementNames.has(license?.name)) {
        return { ...license, disabled: true };
      }
      return license;
    },
  );

  return updatedAgreements;
});

const submit = async () => {
  try {
    isButtonSubmitDisabled.value = true;
    isButtonSubmitLoading.value = true;
    await Promise.all(
      filteredItems.value &&
        filteredItems.value.map(async (agreement) => {
          await policiesService.assignAgreement(
            props.serviceProviderId,
            agreement,
            props.customer.organization?.id,
            {
              active: true,
              effective_from_date: new Date().toISOString(),
            },
          );
        }),
    );
    emit("closeDialog");
    emit("updateAgreements");
    resetForm();
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = "Error assigning licenses";
  } finally {
    isButtonSubmitLoading.value = false;
    isButtonSubmitDisabled.value = false;
  }
};

const getActiveLicenses = async (customerOrganizationId: string) => {
  if (customerOrganizationId) {
    activeAgreements.value = await policiesService.getActiveLicenses(
      props.serviceProviderId,
      props.customer.organization?.id,
      {
        ...Object.assign(
          { limit: ITEMS_PER_PAGE[4], offset: "0" },
          currentParams.value,
        ),
        category: "ACCESS",
      },
    );
  }
};

const getAgreementTypes = async (params: TableRequestParams) => {
  isLoading.value = true;
  currentParams.value = params;
  const agreementRes = await agreementTypesService.getAgreementTypes(
    props.serviceProviderId,
    {
      ...params,
      category: "ACCESS",
    },
  );

  isLoading.value = false;

  if (props.serviceProviderId) {
    getActiveLicenses(props.serviceProviderId);
  }

  agreementRes?.results?.forEach((agreement) => {
    if (agreement && !agreement.default_policies?.length) {
      agreement.disabled = true;
      agreement.hasNoDefaultPolicies = true;
    }
  });

  agreements.value = agreementRes?.results || [];
  totalAgreements.value = agreementRes?.total || 0;
};

watch(
  () => filteredItems.value,
  () => {
    isButtonSubmitDisabled.value = !Boolean(filteredItems.value.length);
  },
);

onMounted(async () => {
  if (props.serviceProviderId) {
    await getAgreementTypes({
      limit: ITEMS_PER_PAGE[4],
      offset: "0",
    });
  }
});
</script>
<template>
  <div>
    <m-m-dialog
      :is-open="isOpen"
      :title="`Allocate license to ${customer.organization?.name}`"
      icon="document-check-add"
      cy="allocate-license-dialog"
      :has-divider="true"
      @close="onDialogClose"
    >
      <template #default>
        <m-m-alert
          v-if="isAlertVisible"
          status="error"
          cy="allocate-license-alert"
          class="mm-mb-12"
          @close="isAlertVisible = false"
        >
          {{ alertText }}
        </m-m-alert>
        <form v-mm-focus-first class="mm-page-dialog-form mm-mt-10">
          <div>
            <m-m-autocomplete
              id="autocomplete-multiple"
              v-model="filteredItems"
              placeholder="Search license"
              label="Search & allocate licenses"
              cy="allocate-license-autocomplete"
              icon-prepended="search-lg"
              clear-button="x-circle"
              :items="formattedAgreements"
              :total-items="totalAgreements"
              item-title="name"
              item-value="id"
              multiple
              :loading="isLoading"
              @update-params="getAgreementTypes"
            >
              <template #option="{ item }">
                <div :class="selectLicenseOptionClassList(item.disabled)">
                  {{ item.name }}
                  <div
                    v-if="item.disabled"
                    class="mm-flex mm-flex-justify-between mm-flex-grow"
                    :data-cy="`license-allocation-disabled-item-${item.value}`"
                  >
                    <m-m-badge
                      class="mm-ml-3"
                      :status="BadgeTypes.Inactive"
                      :text="`${item.hasNoDefaultPolicies ? 'Disabled' : 'Already added'}`"
                      cy="badge-added"
                    />
                    <m-m-icon
                      v-if="!item.hasNoDefaultPolicies"
                      icon="check-thin-primary"
                      width="12px"
                    />
                  </div>
                  <m-m-tooltip v-if="item.hasNoDefaultPolicies">
                    Can't allocate this license because there are no Default
                    Policies attached. Attach a Default Policy first and then
                    you can assign it.
                  </m-m-tooltip>
                </div>
              </template>
            </m-m-autocomplete>
          </div>
        </form>
      </template>
      <template #footer>
        <m-m-button
          variant="outlined"
          min-width="100px"
          cy="button-cancel"
          @click="onDialogClose"
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
          Allocate license
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
<style scoped lang="scss">
.select-agreements {
  :deep(.disabled-agreement) {
    flex: 1;
    opacity: 0.6;
  }
}
</style>
