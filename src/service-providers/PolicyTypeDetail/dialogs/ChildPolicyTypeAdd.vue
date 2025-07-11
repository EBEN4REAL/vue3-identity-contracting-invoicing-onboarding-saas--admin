<script lang="ts" setup>
import { ref, Ref, PropType, computed, ComputedRef } from "vue";
import { PolicyTypeCreate, PolicyTypeRead } from "~/policies/policies.types";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";
import { POLICY_TYPE_CATEGORY } from "~/service-providers/PolicyTypeDetail/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import Multiselect from "vue-multiselect";
import { useTranslation } from "i18next-vue";

const { t } = useTranslation();

const policyTypesSelected: Ref<SPPolicyTypeRead[]> = ref([]);
const policyTypes: Ref<PolicyTypeRead[]> = ref([]);
const policyTypesTotalItems: Ref<number> = ref(0);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const isSaving: Ref<boolean> = ref(false);
const childPolicies: Ref<PolicyTypeRead[]> = ref([]);
const isChildPolicyTypesLoading: Ref<boolean> = ref(false);
const childPolicyTypesSearch: Ref<string> = ref("");
const isButtonAddChildPolicyDisabled: Ref<boolean> = ref(false);
const isButtonAddChildPolicyLoading: Ref<boolean> = ref(false);
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);

const props = defineProps({
  isOpen: Boolean,
  parentPolicyType: {
    type: Object as PropType<PolicyTypeCreate>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  currentPolicyTypes: {
    type: Array<string>,
    required: true,
  },
  assignedPolicies: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
});

const emit = defineEmits(["close", "updatePreparedChildPolicies"]);

const childPolicyTypesForSelect = computed(() =>
  policyTypes.value.map((policyType) => {
    const isPolicyAlreadyAdded = [
      ...props.currentPolicyTypes,
      ...policyTypesSelected.value,
    ].includes(policyType.id);

    return {
      ...policyType,
      name: policyType.external_facing_name,
      $isDisabled: isPolicyAlreadyAdded || Boolean(policyType.wizard?.isolated),
    };
  }),
);

const title: ComputedRef<string> = computed(
  () => `Add child policies to ${props.parentPolicyType.name || "New policy"}`,
);

const resetForm = () => {
  setTimeout(() => {
    policyTypesSelected.value = [];
    isAlertVisible.value = false;
    alertText.value = "";
  }, 100);
};

const closeModal = () => {
  resetForm();
  emit("close");
};

const getPolicyTypes = async (params: TableRequestParams) => {
  isChildPolicyTypesLoading.value = true;

  const policyTypesRes = await policyTypesService.getPolicyTypes(
    props.serviceProviderId,
    { ...params, exclude_id: props.parentPolicyType.id },
  );

  isChildPolicyTypesLoading.value = false;

  policyTypesTotalItems.value = policyTypesRes?.total || 0;

  policyTypes.value = policyTypesRes?.results || [];
};

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(childPolicyTypesSearch.value) &&
    !isChildPolicyTypesLoading.value &&
    !childPolicyTypesForSelect.value.find(
      (childPolicyType) =>
        childPolicyType.name === childPolicyTypesSearch.value,
    ),
);

const createChildPolicyTypeButtonText: ComputedRef<string> = computed(
  () => `Create child policy "${childPolicyTypesSearch.value}"`,
);

const addChildPolicyTypeButtonText: ComputedRef<string> = computed(
  () =>
    `Add ${policyTypesSelected.value.length ? policyTypesSelected.value.length : ""} child polic${policyTypesSelected.value.length > 1 ? "ies" : "y"}`,
);

const onCloseDialogAddChildPolicies = (): void => {
  policyTypesSelected.value = [];
  closeModal();
};

const onAddChildPolicies = (): void => {
  childPolicies.value.push(...policyTypesSelected.value);
  onCloseDialogAddChildPolicies();
  emit("updatePreparedChildPolicies", childPolicies.value);
};

const onSearchChange = (value: string) => {
  childPolicyTypesSearch.value = value;
};

const onCreateChildPolicyType = async () => {
  try {
    isButtonAddChildPolicyDisabled.value = false;
    isButtonAddChildPolicyLoading.value = false;

    const createdPolicyType: SPPolicyTypeRead =
      await policyTypesService.postPolicyType(props.serviceProviderId, {
        name: childPolicyTypesSearch.value,
        category_id: POLICY_TYPE_CATEGORY,
        outcome: "ALLOW",
        external_facing_name: childPolicyTypesSearch.value,
        external_facing_description: childPolicyTypesSearch.value,
        service_provider_id: props.serviceProviderId,
      });

    policyTypesSelected.value.push(createdPolicyType);

    multiselectRef.value?.closeMultiselect();

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  } finally {
    isButtonAddChildPolicyDisabled.value = false;
    isButtonAddChildPolicyLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="title"
    icon="shield-plus"
    cy="add-child-policy-type-dialog"
    @close="closeModal"
  >
    <template #default>
      <m-m-alert
        v-if="isAlertVisible"
        status="error"
        cy="add-child-policy-type-alert"
        class="mm-mb-12"
        @close="isAlertVisible = false"
      >
        {{ alertText }}
      </m-m-alert>

      <form v-mm-focus-first class="mm-page-dialog-form">
        <m-m-multiselect
          ref="multiselectRef"
          v-model="policyTypesSelected"
          :options="childPolicyTypesForSelect"
          :loading="isChildPolicyTypesLoading"
          :total="policyTypesTotalItems"
          placeholder="Search child policy"
          label="Search & add child policies"
          item-title="name"
          item-value="id"
          multiple
          searchable
          @search-change="onSearchChange"
          @update-params="getPolicyTypes"
        >
          <template v-if="isAfterListContentVisible" #afterListContent>
            <m-m-button
              :loading="isButtonAddChildPolicyLoading"
              :is-disabled="isButtonAddChildPolicyDisabled"
              @click="onCreateChildPolicyType"
            >
              {{ createChildPolicyTypeButtonText }}
            </m-m-button>
          </template>
          <template #disabled-text="{ option }">
            <span v-if="option.wizard?.isolated">
              {{ t("multiselect.part_of") }}
              <m-m-link :to="`/sp${option.wizard.path}`" class="mm-fs-16">
                {{ option.wizard.name }}
              </m-m-link>
            </span>
            <span v-else-if="option.$isDisabled">
              {{ t("multiselect.already_added") }}
            </span>
          </template>
        </m-m-multiselect>
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" @click="closeModal"> Cancel </m-m-button>
      <m-m-button
        variant="elevated"
        cy="button-submit"
        :is-disabled="policyTypesSelected.length === 0"
        :loading="isSaving"
        prepend-icon="plus-white"
        @click="onAddChildPolicies"
      >
        {{ addChildPolicyTypeButtonText }}
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
