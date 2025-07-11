<script setup lang="ts">
import { computed, PropType, ref, toRef } from "vue";
import { TypePricingDetails } from "../../types";
import BasicInformationEdit from "../BasicInformation/BasicInformationEdit.vue";
import BasicInformationRead from "../BasicInformation/BasicInformationRead.vue";
import PoliciesRead from "../Policies/PoliciesRead.vue";
import PoliciesEdit from "../Policies/PoliciesEdit.vue";
import LegalDocuments from "../LegalDocuments/LegalDocuments.vue";
import Pricing from "../Pricing/Pricing.vue";
import MarketingFeatureList from "../BasicInformation/MarketingFeatureList.vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import { useFlag } from "@unleash/proxy-client-vue";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";

const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  isEditMode: {
    type: Boolean,
    default: false,
  },
  isCreateMode: {
    type: Boolean,
    default: false,
  },
  data: {
    type: Object as PropType<AgreementTypePoliciesRead>,
    default: () => ({}),
  },
  defaultPolicies: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  optionalPolicies: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  defaultPoliciesEdit: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  optionalPoliciesEdit: {
    type: Array as PropType<PolicyTypeRead[]>,
    default: () => [],
  },
  routeLabel: {
    type: String,
    default: "",
  },
  isAccessCategory: {
    type: Boolean,
    default: false,
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
  licensePricing: {
    type: Object as PropType<TypePricingDetails | null>,
    default: () => {},
  },
  isSubmitLoading: {
    type: Boolean,
    default: false,
  },
  isBasicInfoOpen: {
    type: Boolean,
    default: true,
  },
  isPoliciesOpen: {
    type: Boolean,
    default: false,
  },
  isCurrentCategoryPlan: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits([
  "removeDefaultPolicy",
  "removeOptionalPolicy",
  "openDialogAddDefaultPolicies",
  "openDialogAddOptionalPolicies",
  "updateList",
  "updatePrices",
  "updateMarketingList",
  "removeDocument",
  "update:basicInfoOpen",
  "update:policiesOpen",
]);
const licensePricingEnabled = useFlag("license_pricing");
const marketingFeatureEnabled = useFlag("marketing_feature_list");
const legalDocsEnabled = useFlag("legal_documents");
const basicInformationEditRef = ref(null);
const legalDocumentsRef = ref(null);

const policiesForMode = computed(() => {
  if (props.isCreateMode) {
    return {
      defaultPolicies: props.defaultPolicies,
      optionalPolicies: props.optionalPolicies,
    };
  } else {
    return {
      defaultPolicies: props.defaultPoliciesEdit,
      optionalPolicies: props.optionalPoliciesEdit,
    };
  }
});

const isBasicInfoOpen = toRef(props, "isBasicInfoOpen");
const isPoliciesOpen = toRef(props, "isPoliciesOpen");

defineExpose({
  basicInformationEditRef,
  legalDocumentsRef,
});
</script>
<template>
  <m-m-expandable-card
    title="Basic information"
    :is-opened="isBasicInfoOpen"
    :required="isEditMode || isCreateMode"
    @update:is-opened="emit('update:basicInfoOpen', $event)"
  >
    <BasicInformationEdit
      v-if="isEditMode || isCreateMode"
      ref="basicInformationEditRef"
      class="form-container"
      :data="data"
      :is-current-category-plan="isCurrentCategoryPlan"
    />
    <BasicInformationRead v-else :data="data" />
  </m-m-expandable-card>
  <m-m-expandable-card
    v-if="marketingFeatureEnabled && !isAccessCategory"
    is-opened
    title="Plan features"
    class="mm-mt-10"
  >
    <MarketingFeatureList
      class="form-container"
      :is-edit-mode="isEditMode || isCreateMode"
      :service-provider-id="serviceProviderId"
      :marketing-features="data.marketing_features"
      @update-marketing-list="emit('updateMarketingList', $event)"
    />
  </m-m-expandable-card>
  <m-m-expandable-card
    title="Policies"
    :required="isEditMode || isCreateMode"
    :is-opened="isPoliciesOpen"
    class="mm-mt-10 table-elem"
    @update:is-opened="emit('update:policiesOpen', $event)"
  >
    <PoliciesEdit
      v-if="isEditMode || isCreateMode"
      class="form-container"
      :service-provider-id="serviceProviderId"
      :default-policies="policiesForMode.defaultPolicies"
      :optional-policies="policiesForMode.optionalPolicies"
      :route-label="routeLabel"
      :is-loading="isLoading"
      @remove-default-policy="emit('removeDefaultPolicy', $event)"
      @remove-optional-policy="emit('removeOptionalPolicy', $event)"
      @open-dialog-add-default-policies="
        emit('openDialogAddDefaultPolicies', $event)
      "
      @open-dialog-add-optional-policies="
        emit('openDialogAddOptionalPolicies', $event)
      "
    />
    <PoliciesRead
      v-else
      class="form-container"
      :service-provider-id="serviceProviderId"
      :default-policies="data.default_policies"
      :optional-policies="data.optional_policies"
      :route-label="routeLabel"
      :is-loading="isLoading"
    />
  </m-m-expandable-card>
  <m-m-expandable-card
    v-if="licensePricingEnabled && !isAccessCategory"
    title="Pricing"
    :required="false"
    is-opened
    class="mm-mt-10 table-elem"
  >
    <Pricing
      :is-creating="isCreateMode"
      :is-editing="isEditMode || isCreateMode"
      :license-pricing="licensePricing"
      :service-provider-id="serviceProviderId"
      :agreement-type-id="data.id"
      :license-has-active-instances="data.agreements_count > 0"
      @update-prices="emit('updatePrices', $event)"
    />
  </m-m-expandable-card>
  <m-m-expandable-card
    v-if="legalDocsEnabled"
    title="Legal documents"
    is-opened
    class="mm-mt-10 table-elem"
  >
    <LegalDocuments
      ref="legalDocumentsRef"
      :license-name="data.name"
      :is-edit-mode="isEditMode"
      :is-create-mode="isCreateMode"
      :route-label="routeLabel"
      :is-submit-loading="isSubmitLoading"
      :license-has-active-instances="data.agreements_count > 0"
      @update-list="emit('updateList', $event)"
      @remove-document="emit('removeDocument', $event)"
    />
  </m-m-expandable-card>
</template>
<style scoped lang="scss">
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
.mm-expandable-card--active.mm-mt-10.table-elem {
  background-color: #f2f4f7;
}
:deep(.mm-expandable-card .mm-table .mm-table-body) {
  box-shadow: none;
  border: none;
  background: none;
}
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
:deep(.mm-table-body thead tr) {
  background-color: #fafbfc;
}
:deep(.mm-table-body) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body tr) {
  background-color: #fff;
}
</style>
