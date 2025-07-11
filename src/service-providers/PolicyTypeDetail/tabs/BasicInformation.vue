<script setup lang="ts">
import {
  computed,
  ComputedRef,
  onMounted,
  onUnmounted,
  PropType,
  ref,
  Ref,
  watch,
} from "vue";
import {
  PolicyTypeDetailForm,
  PolicyTypeDetailMode,
} from "~/service-providers/PolicyTypeDetail/policyTypeDetail.types";
import type { TypeDataIteratorItem } from "~/mm_ui_kit/src/types/dataIterator.types";
import { UxBehavior } from "../../ConfigurationTabs/Policies/policies.types";
import { useVuelidate } from "@vuelidate/core";
import { helpers, maxLength, required } from "@vuelidate/validators";

import {
  POLICY_TYPE_AUDIT_LEVEL_MAP,
  POLICY_TYPE_OUTCOME_MAP,
} from "~/service-providers/PolicyTypeDetail/constants";

import { useCategoryConfig } from "~/mm_ui_kit/src/composables/uxCategoryConfig";
import { usePolicyUxCategoriesStore } from "~/stores/policyUxCategories";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { RoleRead } from "~/service-providers/Roles/roles.type";
import { useRoute } from "vue-router";
import { useRolesStore } from "~/service-providers/Roles/roles.service";
import { policyTypesService } from "~/configuration/policy-types.service";
import Multiselect from "vue-multiselect";

const emit = defineEmits(["update:form", "prefillRole", "on:blur"]);

const props = defineProps({
  form: {
    type: Object as PropType<PolicyTypeDetailForm>,
    required: true,
  },
  mode: {
    type: String as PropType<PolicyTypeDetailMode>,
    required: true,
  },
  serviceProvider: {
    type: String,
    default: "",
  },
  uxCategoryConfig: {
    type: Array as PropType<UxBehavior>,
    required: true,
  },
});

const policyUxCategoriesStore = usePolicyUxCategoriesStore();
const route = useRoute();
const rolesStore = useRolesStore();

const roleSearch: Ref<string> = ref("");
const isRolesForOIDCClaimLoading: Ref<boolean> = ref(false);
const rolesForOIDCClaim: Ref<TableResponse<RoleRead> | null> = ref(null);
const isRoleForOIDCClaimLoading: Ref<boolean> = ref(true);
const isButtonCreateRoleDisabled: Ref<boolean> = ref(false);
const isButtonCreateRoleLoading: Ref<boolean> = ref(false);
const isButtonRoleForOIDCClaimDisabled: Ref<boolean> = ref(false);
const isButtonRoleForOIDCClaimLoading: Ref<boolean> = ref(false);
const initialRoleIdSelected: Ref<string | null> = ref(null);
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);

const isCreating = computed(() => props.mode === "create");

const isCreatingOrEditing = computed(
  () => props.mode === "create" || props.mode === "edit",
);

const { isFieldVisible, isFieldEditable, getLabel, getPlaceholder } =
  useCategoryConfig(props.uxCategoryConfig);

const isActiveCategoryRole: ComputedRef<boolean> = computed(
  () => policyUxCategoriesStore.activeCategoryName === "Role",
);

const formRules = computed(() => ({
  external_facing_name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  name: {
    maxLength: helpers.withMessage("Reference is too long", maxLength(64)),
  },
  outcome: {
    required: helpers.withMessage("Decision is required", required),
  },
  external_facing_description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(256)),
  },
}));

const v$ = useVuelidate(formRules, props.form);

const details: ComputedRef<TypeDataIteratorItem[]> = computed(
  (): TypeDataIteratorItem[] => {
    const data = [
      {
        key: "externalName",
        label: "Name",
        text: props.form.external_facing_name,
        labelTooltip: "This will be visible to your customers",
      },
      {
        key: "name",
        label: "Reference",
        text: props.form.name,
        isEmpty: !props.form.name,
        labelTooltip: "Reference for internal use only",
        emptyText: "N/A",
      },
      {
        key: "externalDescription",
        label: "Description",
        text: props.form.external_facing_description,
        labelTooltip: "This will be visible to your customers",
      },
      {
        key: "description",
        label: "Remarks",
        text: props.form.description,
        isEmpty: !props.form.description,
        emptyText: "N/A",
        labelTooltip: "Remarks and notes for internal use only",
      },
      {
        key: "decision",
        label: "Decision",
        text: POLICY_TYPE_OUTCOME_MAP[props.form.outcome],
        isEmpty: !POLICY_TYPE_OUTCOME_MAP[props.form.outcome],
        emptyText: "N/A",
      },
      {
        key: "return value",
        label: "Custom error message",
        text: props.form.return_value,
        isEmpty: !props.form.return_value,
        emptyText: "N/A",
      },
      {
        key: "empty",
        label: "",
        text: "",
      },
    ];

    if (isActiveCategoryRole.value) {
      return data.filter((item) => item.key !== "decision");
    }

    if (isOutcomeAudit.value) {
      data.push({
        key: "auditLevel",
        label: "Audit level",
        text: POLICY_TYPE_AUDIT_LEVEL_MAP[props.form.audit_level],
        isEmpty: !POLICY_TYPE_AUDIT_LEVEL_MAP[props.form.audit_level],
        emptyText: "N/A",
      });
    }

    return data;
  },
);

const roleForOIDCClaimDetails: ComputedRef<TypeDataIteratorItem[]> = computed(
  (): TypeDataIteratorItem[] => [
    {
      key: "role-for-oidc-claim",
      label: "Role for OIDC Claim",
      text: `${policyTypesService.state.roleSelected?.name}`,
      isEmpty: !Boolean(policyTypesService.state.roleSelected),
      emptyText: "No role",
    },
  ],
);

const isOutcomeAudit: ComputedRef<boolean> = computed(
  (): boolean => props.form?.outcome === "AUDIT" || props.form?.outcome === "I",
);

const isOutcomeDeny: ComputedRef<boolean> = computed(
  (): boolean => props.form?.outcome === "DENY",
);

const isDecisionVisible: ComputedRef<boolean> = computed(
  () => !isActiveCategoryRole.value,
);

const rolesForOIDCClaimForAutocompleteItems: ComputedRef<RoleRead[]> = computed(
  () => rolesForOIDCClaim.value?.results || [],
);

const rolesForOIDCClaimTotal: ComputedRef<number> = computed(
  () => rolesForOIDCClaim.value?.total || 0,
);

const isRoleForOIDCClaimChanged: ComputedRef<boolean> = computed(
  () =>
    policyTypesService.state.roleSelected?.id !== initialRoleIdSelected.value,
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(roleSearch.value) &&
    !rolesForOIDCClaimForAutocompleteItems.value.find(
      (role) => role.name === roleSearch.value,
    ),
);

const createRoleButtonText: ComputedRef<string> = computed(
  () => `Create role "${roleSearch.value}"`,
);

const fetchRolesForOIDCClaim = async (params: TableRequestParams) => {
  try {
    isRolesForOIDCClaimLoading.value = true;
    rolesForOIDCClaim.value = await rolesStore.fetchRoles(
      route.params.service_provider_id as string,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching roles",
      status: "error",
    });
  } finally {
    isRolesForOIDCClaimLoading.value = false;
  }
};

const onCreateRoleForOIDCClaim = async () => {
  try {
    isButtonRoleForOIDCClaimDisabled.value = true;
    isButtonRoleForOIDCClaimLoading.value = true;

    policyTypesService.state.roleSelected = await rolesStore.createRole(
      route.params.service_provider_id as string,
      {
        name: roleSearch.value,
      },
    );

    multiselectRef.value?.closeMultiselect();
  } catch (error) {
    const generateError = (error: unknown) => {
      switch (error?.response?.status) {
        case 409:
          return "Role with this name already exists";
        case 422:
          return "Please enter a name that only contains lowercase letters (a-z), numbers (0-9), underscores (_), or colons (:).";
        default:
          return "Error creating role";
      }
    };

    eventBus.$emit("onShowToast", {
      text: generateError(error),
      status: "error",
    });
  } finally {
    isButtonRoleForOIDCClaimDisabled.value = false;
    isButtonRoleForOIDCClaimLoading.value = false;
  }
};

const fetchRoleForOIDCClaim = async () => {
  try {
    isRoleForOIDCClaimLoading.value = true;
    const roles = await policyTypesService.fetchRoles(
      route.params.service_provider_id as string,
      route.params.policy_type_id as string,
    );

    if (roles.length) {
      policyTypesService.state.roleSelected = await rolesStore.fetchRole(
        route.params.service_provider_id as string,
        roles[0].role_id,
      );
    }
  } finally {
    isRoleForOIDCClaimLoading.value = false;
  }
};

watch(
  () => props.form?.outcome,
  (newOutcome) => {
    if (newOutcome === "ROLE" || newOutcome === "R") {
      emit("prefillRole", props.form.name);
    }
  },
  { immediate: true },
);

const getPolicyTypeDescription = (policyType: string) => {
  switch (policyType) {
    case "ALLOW":
      return "Allows access to your application(s) when the filter conditions apply";
    case "DENY":
      return "Denies access to your applications when the filter conditions apply";
    case "AUDIT":
      return "Creates an entry in the audit log when the filter conditions apply";
    case "INCONCLUSIVE":
      return "Does not prevent (or deny) access to your applications when the filter conditions apply";
    default:
      return "";
  }
};

const convertToRequiredRoleFormat = (input: string) =>
  input.toLowerCase().replace(/\s+/g, "_");

const onBlur = async () => {
  emit("on:blur");
  if (!isDecisionVisible.value) {
    roleSearch.value = convertToRequiredRoleFormat(
      props.form.external_facing_name,
    );
    await onCreateRoleForOIDCClaim();
  }
};

const onSearchChange = (value: string) => {
  roleSearch.value = value;
};

onMounted(async () => {
  eventBus.$on("fetchRoleForOIDCClaim", async () => {
    await fetchRoleForOIDCClaim();
  });
  if (!isCreating.value) {
    await fetchRoleForOIDCClaim();
    initialRoleIdSelected.value = policyTypesService.state.roleSelected
      ?.id as string;
  } else {
    policyTypesService.state.roleSelected = null;
  }
});

onUnmounted(() => {
  policyTypesService.state.roleSelected = null;
});

defineExpose({
  v$,
  isRoleForOIDCClaimChanged,
});
</script>

<template>
  <div v-if="isCreatingOrEditing" class="policy-type-edit-form">
    <form v-mm-focus-first class="mm-pb-12" data-cy="policy-type-edit-form">
      <div class="mm-flex mm-flex-row mm-flex-gap-16 policy-type-edit-form-row">
        <div class="mm-w-5 policy-type-edit-form-field-wrapper">
          <m-m-input
            :model-value="form.external_facing_name"
            data-cy="policy_external_name_input"
            label-tool-tip-text="This will be visible to your customers"
            :label="getLabel('policy_external_facing_name') || 'Name'"
            :placeholder="
              getPlaceholder('policy_external_facing_name') ||
              'Customer facing name'
            "
            :readonly="!isFieldEditable('policy_external_facing_name')"
            required
            :errors="v$.external_facing_name?.$errors"
            @blur="onBlur"
            @update:model-value="
              emit('update:form', { ...form, external_facing_name: $event })
            "
          />
        </div>
        <div class="mm-w-5 policy-type-edit-form-field-wrapper">
          <m-m-input
            :model-value="form.name"
            label="Reference"
            placeholder="Reference"
            label-tool-tip-text="Reference for internal use only"
            :readonly="!isFieldEditable('policy_name')"
            :errors="v$.name?.$errors"
            cy="policy_name_input"
            @update:model-value="emit('update:form', { ...form, name: $event })"
          />
        </div>
      </div>
      <div class="mm-flex mm-flex-row mm-flex-gap-16 policy-type-edit-form-row">
        <div class="mm-w-5 mm-mt-16 policy-type-edit-form-field-wrapper">
          <m-m-input
            :model-value="form.external_facing_description"
            :label="
              getLabel('policy_external_facing_description') || 'Description'
            "
            :placeholder="
              getPlaceholder('policy_external_facing_description') ||
              'Add a customer facing description'
            "
            :readonly="!isFieldEditable('policy_external_facing_description')"
            :errors="v$.external_facing_description?.$errors"
            inputmode="textarea"
            cy="policy_external_description_input"
            label-tool-tip-text="This will be visible to your customers"
            @blur="emit('on:blur')"
            @update:model-value="
              ($event) => {
                v$.external_facing_description.$touch();
                emit('update:form', {
                  ...form,
                  external_facing_description: $event,
                });
              }
            "
          />
        </div>
        <div class="mm-w-5 mm-mt-16 policy-type-edit-form-field-wrapper">
          <m-m-input
            :model-value="form.description"
            :label="getLabel('policy_description') || 'Remarks'"
            :placeholder="
              getPlaceholder('policy_description') || 'Add a remark'
            "
            label-tool-tip-text="Remarks and notes for internal use only"
            :readonly="!isFieldEditable('policy_description')"
            inputmode="textarea"
            cy="policy_description_input"
            :errors="v$.description?.$errors"
            @update:model-value="
              emit('update:form', { ...form, description: $event })
            "
          />
        </div>
      </div>
      <div v-if="isDecisionVisible">
        <m-m-divider class="mm-my-12" />
        <div class="mm-page-title mm-page-title--h3 mm-page-title--required">
          Decision
        </div>
        <div class="mm-page-subtitle mm-page-subtitle--h1 mm-mb-8">
          If a request matches the conditions, then:
        </div>
        <div class="mm-flex mm-flex-row mm-flex-gap-8 mm-flex-wrap">
          <m-m-radio-card
            v-for="(label, key) in POLICY_TYPE_OUTCOME_MAP"
            :key="key"
            :class="{ 'error-container': v$.outcome?.$errors.length }"
            :model-value="form.outcome"
            :name="label"
            :value="key"
            :description="getPolicyTypeDescription(key)"
            :cy="`decision-radio-${key}`"
            @update:model-value="
              emit('update:form', { ...form, outcome: $event })
            "
          />
        </div>
        <div v-if="v$.outcome?.$errors.length" class="error-message">
          {{ v$.outcome.$errors[0].$message }}
        </div>
      </div>
      <div
        v-if="isOutcomeDeny"
        class="mm-w-5 mm-mt-16 policy-type-edit-form-field-wrapper"
      >
        <m-m-input
          :model-value="form.return_value"
          label="Custom error message"
          placeholder="Custom error message"
          label-tool-tip-text="This message is displayed to users trying to login when this policy applied"
          inputmode="textarea"
          @update:model-value="
            emit('update:form', { ...form, return_value: $event })
          "
        />
      </div>
      <template v-if="isOutcomeAudit">
        <m-m-divider class="mm-my-12" />
        <div data-cy="audit-level-options-section">
          <div class="mm-page-title mm-page-title--h3 mm-mb-8">Audit level</div>
          <div class="mm-flex mm-flex-row mm-flex-gap-8 mm-flex-wrap">
            <m-m-radio-card
              v-for="(label, key) in POLICY_TYPE_AUDIT_LEVEL_MAP"
              :key="key"
              :model-value="form.audit_level"
              :name="label"
              :value="key"
              :cy="`audit-level-${label}`"
              @update:model-value="
                emit('update:form', { ...form, audit_level: $event })
              "
            />
          </div>
        </div>
      </template>
      <div
        v-if="
          isFieldVisible('troubleshoot_check') ||
          isFieldVisible('troubleshoot_end')
        "
      >
        <m-m-divider class="mm-my-12" />
        <div class="mm-page-title mm-page-title--h3 mm-mb-8 mm-flex">
          <template v-if="isFieldVisible('troubleshoot_check')">
            <m-m-checkbox
              :model-value="form.troubleshoot"
              name="checkbox"
              @update:model-value="
                emit('update:form', { ...form, troubleshoot: $event })
              "
            />
            Troubleshoot until:
          </template>
        </div>
        <div class="mm-flex mm-flex-row mm-flex-gap-8 mm-flex-wrap">
          <m-m-datepicker
            v-if="isFieldVisible('troubleshoot_end')"
            confirm
            :placeholder="getPlaceholder('troubleshoot_end') || 'Select Date'"
            :model-value="form.troubleshoot_end"
            :errors="v$.troubleshoot_end?.$errors"
            cy="troubleshoot_end_date_picker"
            :disabled="!form.troubleshoot"
            @update:model-value="
              emit('update:form', { ...form, troubleshoot_end: $event })
            "
          />
        </div>
      </div>
      <m-m-divider class="mm-my-12" />
      <div class="mm-flex mm-flex-row mm-flex-gap-16 policy-type-edit-form-row">
        <m-m-multiselect
          v-if="rolesForOIDCClaimForAutocompleteItems"
          ref="multiselectRef"
          v-model="policyTypesService.state.roleSelected"
          :options="rolesForOIDCClaimForAutocompleteItems"
          :loading="isRolesForOIDCClaimLoading"
          :total="rolesForOIDCClaimTotal"
          label="Role name for OIDC Claim"
          placeholder="Search or add a role name"
          item-title="name"
          item-value="id"
          class="mm-w-5 policy-type-edit-form-field-wrapper"
          searchable
          @search-change="onSearchChange"
          @update-params="fetchRolesForOIDCClaim"
        >
          <template v-if="isAfterListContentVisible" #afterListContent>
            <m-m-button
              :loading="isButtonCreateRoleLoading"
              :is-disabled="isButtonCreateRoleDisabled"
              @click="onCreateRoleForOIDCClaim"
            >
              {{ createRoleButtonText }}
            </m-m-button>
          </template>
        </m-m-multiselect>
        <div class="mm-w-5 mm-mt-18 policy-type-edit-form-field-wrapper">
          <m-m-link
            :href="`/sp/${serviceProvider}/roles`"
            target="_blank"
            text-align="left"
            color="primary"
            font-size="16px"
          >
            <m-m-icon icon="settings" stroke="#072E51" class="mm-mr-2" />
            Manage OIDC roles
          </m-m-link>
        </div>
      </div>
    </form>
  </div>
  <template v-else>
    <m-m-data-iterator :data="details" :columns="2" />
    <div v-if="isRoleForOIDCClaimLoading" class="mm-pa-12">
      <m-m-skeleton-loader width="50%" />
    </div>
    <div v-else class="details-container">
      <m-m-divider class="mm-my-2" />
      <m-m-data-iterator :data="roleForOIDCClaimDetails" :columns="2" />
    </div>
  </template>
</template>
<style scoped lang="scss">
@media (max-width: $breakpoint-xs) {
  .policy-type-edit-form {
    &-row {
      width: 100%;
      display: block;
    }
    &-field-wrapper {
      width: 100%;
      margin-bottom: 20px;
    }
  }
}
.details-container {
  width: calc(100% - 48px);
  .mm-card.mm-data-iterator {
    padding-left: 0;
  }
}
.error-message {
  margin-top: 6px;
  font-size: 12px;
  color: #d92d20;
}

.error-container {
  border: 1px solid #d92d20;
  border-radius: 8px;
  width: fit-content;
}
</style>
