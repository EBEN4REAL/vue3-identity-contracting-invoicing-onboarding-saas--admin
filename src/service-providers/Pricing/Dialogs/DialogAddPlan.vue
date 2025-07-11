<script setup lang="ts">
import { onMounted, watch } from "vue";
import { Ref, ref } from "vue";
import { authService } from "~/auth/auth.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { AgreementTypePoliciesCountAllocatedRead } from "~/service-providers/Licenses/licenses.types";
import { agreementTypesService } from "~/configuration/agreement-types.service";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  licensesAdded: { type: Array<string>, default: [] },
});

const isLoading: Ref<boolean> = ref(false);

const emit = defineEmits(["closeDialog", "updateList", "removeItem"]);
const serviceProviderId: Ref<string | null> = ref(null);
const licenseItems: Ref<string[]> = ref([]);
const licenses: Ref<TableResponse<AgreementTypePoliciesCountAllocatedRead> | null> =
  ref(null);
const isAdding: Ref<boolean> = ref(false);

const selectPolicyOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const resetForm = () => {
  licenseItems.value = [];
};

const onDialogClose = () => {
  emit("closeDialog");
  resetForm();
};

const getAgreementTypes = async (params?: TableRequestParams) => {
  if (!serviceProviderId.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || null;
  }
  try {
    isLoading.value = true;
    const defaultParams = {
      category: "SUBSCRIPTION",
      limit: ITEMS_PER_PAGE[0],
      offset: "0",
    };
    const queryParams = params
      ? { category: "SUBSCRIPTION", ...params }
      : defaultParams;

    licenses.value = await agreementTypesService.getAgreementTypes(
      serviceProviderId.value as string,
      queryParams,
    );
    updateAllDisable();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const onAddLicense = async () => {
  try {
    isAdding.value = true;

    const licensesToBeAdded = await Promise.all(
      licenseItems.value.map((id) =>
        agreementTypesService.getAgreementType(
          serviceProviderId.value as string,
          id,
        ),
      ),
    );

    isAdding.value = false;
    onDialogClose();
    emit("updateList", licensesToBeAdded);
  } catch (error) {
    isAdding.value = false;
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

const removeFromParent = (item: AgreementTypePoliciesCountAllocatedRead) => {
  licenses.value?.results
    .filter((license) => item.id === license.id)
    .forEach((license) => (license.disabled = false));
  emit("removeItem", item.id);
};

const updateAllDisable = () => {
  licenses.value?.results.forEach((license) => (license.disabled = false));
  licenses.value?.results
    .filter(
      (license) =>
        props.licensesAdded.some((item) => item === license.id) ||
        (Array.isArray(license.default_policies) &&
          !license.default_policies.length),
    )
    .forEach((license) => (license.disabled = true));
};

const handleUpdateResults = async (pagination: TableRequestParams) => {
  await getAgreementTypes({ ...pagination });
};

watch(
  () => props.licensesAdded.length,
  () => {
    updateAllDisable();
  },
);

onMounted(async () => {
  await getAgreementTypes();
  updateAllDisable();
});
</script>
<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Add Plan"
    icon="document-check"
    icon-size="24px"
    cy="add-plan-dialog"
    @close="onDialogClose"
  >
    <template #default>
      <form v-mm-focus-first class="mm-page-dialog-form">
        <div>
          <m-m-autocomplete
            v-model="licenseItems"
            cy="add-plan-select"
            :items="licenses?.results"
            :total-items="licenses?.total"
            item-title="name"
            item-value="id"
            multiple
            label="Search & add plan"
            icon-prepended="search-lg"
            placeholder="Click to select plan"
            :loading="isLoading"
            @update-params="handleUpdateResults"
          >
            <template #option="{ item }">
              <div class="mm-flex mm-flex-justify-between mm-w-10">
                <div>
                  <div
                    :class="selectPolicyOptionClassList(item.disabled)"
                    class="mm-page-option mm-flex mm-flex-align-center mm-flex-gap-3"
                  >
                    {{ item.name }}
                    <m-m-badge
                      v-if="item.disabled"
                      :text="
                        !item.default_policies.length
                          ? 'No default policies'
                          : 'Added'
                      "
                      cy="badge-added"
                    />
                  </div>
                  <div class="mm-page-option-secondary">
                    {{ item.external_facing_description }}
                  </div>
                </div>
                <m-m-button
                  v-if="item.disabled && item.default_policies.length"
                  variant="text"
                  prepend-icon="trash-black"
                  cy="button-remove-plan"
                  @click.stop="removeFromParent(item)"
                >
                </m-m-button>
              </div>
            </template>
          </m-m-autocomplete>
        </div></form
    ></template>
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel-add-plan"
        @click="onDialogClose"
      >
        Cancel
      </m-m-button>
      <m-m-button
        variant="elevated"
        :is-disabled="licenseItems.length === 0"
        :loading="isAdding"
        data-cy="button-confirm-add-plan"
        prepend-icon="plus-white"
        @click="onAddLicense"
      >
        Add Plan
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
<style scoped lang="scss"></style>
