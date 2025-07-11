<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useRoute } from "vue-router";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";
import Multiselect from "vue-multiselect";
import { POLICY_TYPE_CATEGORY } from "~/service-providers/PolicyTypeDetail/constants";
import { useTranslation } from "i18next-vue";

const { t } = useTranslation();

type TypePolicyVariant = "default" | "optional";

const props = defineProps({
  modelValue: {
    type: Array as PropType<string[]>,
    default: () => [],
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  isButtonSubmitDisabled: {
    type: Boolean,
    default: true,
  },
  isButtonSubmitLoading: {
    type: Boolean,
    default: false,
  },
  policyVariant: {
    type: String as PropType<TypePolicyVariant>,
    default: "default",
  },
  licenseName: {
    type: String,
    default: "",
  },
  alreadyAddedPolicies: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["close", "submit", "update:modelValue"]);

const route = useRoute();

const policies: Ref<TableResponse<SPPolicyTypeRead> | null> = ref(null);
const isPoliciesLoading: Ref<boolean> = ref(false);
const policiesSearch: Ref<string> = ref("");
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);
const isButtonAddPolicyDisabled: Ref<boolean> = ref(false);
const isButtonAddPolicyLoading: Ref<boolean> = ref(false);

const title: ComputedRef<string> = computed(
  () =>
    `Add ${props.policyVariant} policies to ${props.licenseName || "new license"}`,
);

const buttonSubmitText: ComputedRef<string> = computed(
  () => `Add ${props.policyVariant} policy`,
);

const total: ComputedRef<number> = computed(() => policies.value?.total || 0);

const policyTypesAsItemsForSelect: ComputedRef<PolicyTypeRead[]> = computed(
  (): PolicyTypeRead[] => {
    return (
      policies.value?.results.map((policy: PolicyTypeRead) => {
        const isPolicyAlreadyAdded = props.alreadyAddedPolicies.some(
          (alreadyAddedPolicy) => alreadyAddedPolicy.id === policy.id,
        );

        const formattedPolicy: PolicyTypeRead & {
          $isDisabled: boolean;
        } = {
          ...policy,
          name: policy.external_facing_name,
          $isDisabled: isPolicyAlreadyAdded || Boolean(policy.wizard?.isolated),
        };

        return formattedPolicy;
      }) || []
    );
  },
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(policiesSearch.value) &&
    !isPoliciesLoading.value &&
    !policyTypesAsItemsForSelect.value.find(
      (policy) => policy.name === policiesSearch.value,
    ),
);

const createPolicyButtonText: ComputedRef<string> = computed(
  () => `Create policy "${policiesSearch.value}"`,
);

const getPolicies = async (pagination: TableRequestParams) => {
  try {
    isPoliciesLoading.value = true;
    policies.value = await policyTypesService.getPolicyTypes(
      route.params?.service_provider_id.toString(),
      pagination,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching policies",
      status: "error",
    });
  } finally {
    isPoliciesLoading.value = false;
  }
};

const onCreatePolicy = async () => {
  try {
    isButtonAddPolicyDisabled.value = true;
    isButtonAddPolicyLoading.value = true;

    const createdPolicy: SPPolicyTypeRead =
      await policyTypesService.postPolicyType(props.serviceProviderId, {
        name: policiesSearch.value,
        category_id: POLICY_TYPE_CATEGORY,
        outcome: "ALLOW",
        external_facing_name: policiesSearch.value,
        external_facing_description: policiesSearch.value,
      });

    multiselectRef.value?.closeMultiselect();

    emit("update:modelValue", [...props.modelValue, createdPolicy]);

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error creating policy",
      status: "error",
    });
  } finally {
    isButtonAddPolicyDisabled.value = false;
    isButtonAddPolicyLoading.value = false;
  }
};

const onSearchChange = (value: string) => {
  policiesSearch.value = value;
};

const onClose = () => {
  emit("close");
};

const onSubmit = () => {
  emit("submit");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="title"
    icon="shield-plus"
    @close="onClose"
  >
    <m-m-multiselect
      ref="multiselectRef"
      :model-value="modelValue"
      :options="policyTypesAsItemsForSelect"
      label="Search & add policies:"
      item-value="id"
      item-title="name"
      :loading="isPoliciesLoading"
      :total="total"
      multiple
      searchable
      @search-change="onSearchChange"
      @update-params="getPolicies"
      @update:model-value="emit('update:modelValue', $event)"
    >
      <template v-if="isAfterListContentVisible" #afterListContent>
        <m-m-button
          :loading="isButtonAddPolicyLoading"
          :is-disabled="isButtonAddPolicyDisabled"
          @click="onCreatePolicy"
        >
          {{ createPolicyButtonText }}
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
    <template #footer>
      <div class="mm-flex mm-flex-align-end mm-flex-gap-6">
        <m-m-button variant="outlined" @click="onClose"> Cancel </m-m-button>
        <m-m-button
          :is-disabled="isButtonSubmitDisabled"
          :loading="isButtonSubmitLoading"
          prepend-icon="plus-white"
          @click="onSubmit"
        >
          {{ buttonSubmitText }}
        </m-m-button>
      </div>
    </template>
  </m-m-dialog>
</template>
