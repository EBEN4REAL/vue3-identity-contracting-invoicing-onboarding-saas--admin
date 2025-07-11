<script setup lang="ts">
import { computed, PropType, ref, toRef } from "vue";
import {
  PolicyTypeDetailForm,
  PolicyTypeDetailMode,
} from "../policyTypeDetail.types";
import BasicInformation from "./BasicInformation.vue";
import { UxBehavior } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import ChildPolicies from "./ChildPolicies.vue";
import Filters from "./Filters.vue";
import Permissions from "./Permissions.vue";
import { FilterRead } from "~/service-providers/Filters/filters.types";
import { useCategoryConfig } from "~/mm_ui_kit/src/composables/uxCategoryConfig";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";

const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  form: {
    type: Object as PropType<PolicyTypeDetailForm>,
    required: true,
    default: () => ({}),
  },
  mode: {
    type: String as PropType<PolicyTypeDetailMode>,
    required: true,
    default: "",
  },
  uxCategoryConfig: {
    type: Array as PropType<UxBehavior>,
    required: true,
    default: () => [],
  },
  policyTypes: {
    type: Array as PropType<SPPolicyTypeRead[]>,
    required: true,
    default: () => [],
  },
  parentPolicyType: {
    type: Object as PropType<SPPolicyTypeRead | null>,
    required: true,
    default: () => ({}),
  },
  isLoading: {
    type: Boolean,
    required: true,
    default: false,
  },
  isDiscarded: {
    type: Boolean,
    default: false,
  },
  filters: {
    type: Array as PropType<FilterRead[]>,
    required: true,
    default: () => [],
  },
  activeCategoryName: {
    type: String,
    default: "",
  },
  isBasicInfoOpen: {
    type: Boolean,
    default: true,
  },
});

const { isFieldVisible } = useCategoryConfig(props.uxCategoryConfig);
const basicInformationRef = ref(null);
const isBasicInfoOpen = toRef(props, "isBasicInfoOpen");

const isCreateOrEditMode = computed(
  () => props.mode === "edit" || props.mode === "create",
);

const emit = defineEmits([
  "update:form",
  "on:blur",
  "updateChildPolicyTypesForRemoval",
  "updateIsRemovingPolicyStatus",
  "updatePreparedChildPolicies",
  "updatePreparedFilters",
  "updateIsRemovingFilterStatus",
  "updateFiltersForRemoval",
  "update:basicInfoOpen",
]);

defineExpose({
  basicInformationRef,
});
</script>
<template>
  <div>
    <m-m-expandable-card
      title="Basic information"
      :is-opened="isBasicInfoOpen"
      :required="isCreateOrEditMode"
      @update:is-opened="emit('update:basicInfoOpen', $event)"
    >
      <BasicInformation
        ref="basicInformationRef"
        class="form-container"
        :form="form"
        :service-provider="serviceProviderId"
        :mode="mode"
        :ux-category-config="uxCategoryConfig"
        @update:form="emit('update:form', $event)"
        @on:blur="emit('on:blur')"
      />
    </m-m-expandable-card>
    <m-m-expandable-card
      v-if="activeCategoryName != 'Role'"
      title="Child policies"
      is-opened
      :required="false"
      class="mm-mt-10 table-elem"
    >
      <ChildPolicies
        class="form-container"
        :policy-types="policyTypes"
        :parent-policy-type="parentPolicyType"
        :is-loading="isLoading"
        :service-provider-id="serviceProviderId"
        :mode="mode"
        :is-discarded="isDiscarded"
        @update-child-policy-types-for-removal="
          emit('updateChildPolicyTypesForRemoval', $event)
        "
        @update-is-removing-policy-status="
          emit('updateIsRemovingPolicyStatus', $event)
        "
        @update-prepared-child-policies="
          emit('updatePreparedChildPolicies', $event)
        "
      />
    </m-m-expandable-card>
    <m-m-expandable-card
      title="Permissions"
      is-opened
      :required="false"
      class="mm-mt-10 table-elem"
    >
      <Permissions :mode="mode" />
    </m-m-expandable-card>
    <m-m-expandable-card
      v-if="isFieldVisible('filters_tab')"
      title="Filters"
      is-opened
      :required="false"
      class="mm-mt-10 table-elem"
    >
      <Filters
        class="form-container"
        :is-loading="isLoading"
        :filters="filters"
        :parent-policy-type="parentPolicyType"
        :service-provider-id="serviceProviderId"
        :mode="mode"
        :is-discarded="isDiscarded"
        @update-prepared-filters="emit('updatePreparedFilters', $event)"
        @update-is-removing-filter-status="
          emit('updateIsRemovingFilterStatus', $event)
        "
        @update-filters-for-removal="emit('updateFiltersForRemoval', $event)"
      />
    </m-m-expandable-card>
  </div>
</template>
<style scoped lang="scss">
:deep(.mm-table) {
  padding: 0 0px 24px;
}
:deep(.mm-card) {
  overflow: visible;
}
:deep(.mm-expandable-card--active.table-elem) {
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
.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
</style>
