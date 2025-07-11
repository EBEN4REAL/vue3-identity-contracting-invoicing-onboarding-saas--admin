<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref, watch } from "vue";
import {
  useRouter,
  useRoute,
  NavigationGuardNext,
  onBeforeRouteLeave,
} from "vue-router";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import {
  SettingsTabComponent,
  TypeCategoryData,
} from "~/policies/License/types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  AgreementTypeRead,
  AgreementTypeCreate,
  PolicyTypeRead,
} from "~/policies/policies.types";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { PaginationSchema_PolicyTypeRead_ } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import SettingsTab from "./Tabs/Settings/Settings.vue";
import { AgreementTypeToLegalDocumentTypeUpdate } from "~/service-providers/LegalDocuments/legal-documents.types";
import { AgreementTypeUpdate } from "~/billing_and_invoicing/billing_and_invoicing.schemas.types";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { policyTypesService } from "~/configuration/policy-types.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { ACCESS_LICENSE, PLAN } from "~/policies/License/constants";
import { isEqual, sortBy } from "lodash";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import DialogAddPoliciesToLicense from "~/policies/License/Dialogs/DialogAddPoliciesToLicense.vue";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import { DEFAULT_PRICING } from "~/policies/License/Tabs/Pricing/constants";
const route = useRoute();
const router = useRouter();

const isCurrentCategoryAccessLicense: ComputedRef<boolean> = computed(() =>
  route.path.includes("/licenses/"),
);

const isCurrentCategoryPlan: ComputedRef<boolean> = computed(() =>
  route.path.includes("/plans/"),
);

const currentCategoryData: ComputedRef<TypeCategoryData> = computed(() =>
  isCurrentCategoryAccessLicense.value ? ACCESS_LICENSE : PLAN,
);
const TABS: TypeTab[] = [
  { label: "Settings", name: "Settings", isRequired: false },
];
const currentTabName: Ref<string> = ref(TABS[0].name);
const settingsTabRef = ref<SettingsTabComponent | null>(null);
const serviceProviderId: Ref<string> = ref(
  route.params?.service_provider_id.toString(),
);
const isButtonSubmitFormDisabled: Ref<boolean> = ref(false);
const isButtonSubmitFormLoading: Ref<boolean> = ref(false);
const autocompleteAddDefaultPoliciesValue: Ref<PolicyTypeRead[]> = ref([]);
const autocompleteAddOptionalPoliciesValue: Ref<PolicyTypeRead[]> = ref([]);
const isAddDefaultPoliciesDialogOpen: Ref<boolean> = ref(false);
const isAddOptionalPoliciesDialogOpen: Ref<boolean> = ref(false);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isPoliciesSectionOpen: Ref<boolean> = ref(true);
const policies: Ref<PaginationSchema_PolicyTypeRead_ | null> = ref(null);
const policiesLoading: Ref<boolean> = ref(false);
const totalItems: Ref<number | null | undefined> = ref(null);
const defaultPolicies: Ref<PolicyTypeRead[]> = ref(
  agreementTypesService.state.license?.default_policies || [],
);
const optionalPolicies: Ref<PolicyTypeRead[]> = ref(
  agreementTypesService.state.license?.optional_policies || [],
);

const licensePlaceholder = `Create ${currentCategoryData.value.label}`;
const documentItems: Ref<string[]> = ref([]);
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const {
  hasUnsavedChanges,
  updateTargetPages,
  warnUnsavedChanges,
  isDialogUnsavedChangesOpen,
  doNotShowNextTime,
  confirmLeave,
  onCancelDialogUnsavedChanges,
  updateDoNotShowNextTime,
  setTextsForUnsavedChangesDialog,
} = useUnsavedChanges();

const license_pricing = ref<AgreementTypeUpdate[]>([]);
const isSaveButtonDisabled: ComputedRef<boolean> = computed(
  () => isButtonSubmitFormDisabled.value || isConfigPublishing.value,
);
const marketingElementList: Ref<string[]> = ref([]);
const legalDocumentsRef: Ref<{ hasChanges: boolean }> = ref({
  hasChanges: false,
});

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const title: ComputedRef<string> = computed(
  () => license.value?.external_facing_name || licensePlaceholder,
);
const subtitle: ComputedRef<string> = computed(() =>
  currentCategoryData.value?.label == "Plan"
    ? "Plans represent different offerings of your products to your customers. it bundles access, pricing, and legal agreements - simplifying subscription and access control in a unified way."
    : license.value?.external_facing_description || "",
);

const hasChangesPricing: ComputedRef<boolean> = computed(
  () => !isEqual(license_pricing.value[0], DEFAULT_PRICING),
);

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "licenses",
    label: currentCategoryData.value.parent.label,
    to: `/sp/${isCurrentCategoryPlan.value ? "" : "config/"}${currentCategoryData.value.parent.hash.toLocaleLowerCase()}`,
  },
  {
    id: "create-license",
    label: license.value?.external_facing_name || licensePlaceholder,
  },
]);

const license = computed(() => {
  const form = settingsTabRef.value?.basicInformationEditRef?.form;

  if (!form) {
    return {
      external_facing_name: "",
      name: "",
      description: "",
      external_facing_description: "",
      default_policy_types: [],
      optional_policy_types: [],
    };
  }

  return {
    external_facing_name: form.external_facing_name || "",
    name: form.name || "",
    description: form.description || "",
    external_facing_description: form.external_facing_description || "",
    default_policy_types: selectedDefaultPolicyTypesPreparedForAPIAsIds.value,
    optional_policy_types: selectedOptionalPolicyTypesPreparedForAPIAsIds.value,
  };
});

const selectedDefaultPolicyTypesPreparedForAPIAsIds: ComputedRef<string[]> =
  computed(
    () =>
      defaultPolicies.value
        .map((policy: PolicyTypeRead) => policy.id)
        .filter((val) => val) || [],
  );

const selectedOptionalPolicyTypesPreparedForAPIAsIds: ComputedRef<string[]> =
  computed(
    () =>
      optionalPolicies.value
        .map((policy: PolicyTypeRead) => policy.id)
        .filter((val) => val) || [],
  );

const formPreparedForAPI: ComputedRef<AgreementTypeCreate | null> = computed(
  (): AgreementTypeCreate | null => {
    let formattedPricing = [DEFAULT_PRICING];
    if (license_pricing.value?.length > 0)
      formattedPricing = license_pricing.value?.map((price) =>
        filterEmptyPropertiesFromObject({
          ...price,
        }),
      );
    const formattedLicensePricing: AgreementTypeUpdate =
      isCurrentCategoryPlan.value
        ? {
            prices: formattedPricing,
          }
        : null;
    if (settingsTabRef.value?.basicInformationEditRef?.form) {
      return {
        ...settingsTabRef.value?.basicInformationEditRef?.form,
        default_policy_types:
          selectedDefaultPolicyTypesPreparedForAPIAsIds.value,
        optional_policy_types:
          selectedOptionalPolicyTypesPreparedForAPIAsIds.value,
        marketing_features: marketingElementList.value,
        category: currentCategoryData.value.category,
        ...formattedLicensePricing,
      };
    }
    return null;
  },
);

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  }
  router.push(
    `/sp/${currentCategoryData.value.parent.hash.toLocaleLowerCase()}`,
  );
};

const checkIsFormValid = () => {
  let isValid = true;
  settingsTabRef.value?.basicInformationEditRef?.v$.$validate();
  if (settingsTabRef.value?.basicInformationEditRef?.v$.$invalid) {
    isBasicInfoOpen.value = true;
    isValid = false;
  }
  if (!defaultPolicies.value.length) {
    eventBus.$emit("onShowToast", {
      text: `A default policy is required for the ${currentCategoryData.value.label.toLowerCase()} to provide access to customers`,
      status: "error",
    });
    isPoliciesSectionOpen.value = true;
    isValid = false;
  }
  return isValid;
};

const onRemoveDefaultPolicy = (id: string) => {
  defaultPolicies.value = defaultPolicies.value.filter(
    (policy: PolicyTypeRead) => policy.id !== id,
  );
};

const onRemoveOptionalPolicy = (id: string) => {
  optionalPolicies.value = optionalPolicies.value.filter(
    (policy: PolicyTypeRead) => policy.id !== id,
  );
};

const onOpenDialogAddDefaultPolicies = (): void => {
  isAddDefaultPoliciesDialogOpen.value = true;
};

const onOpenDialogAddOptionalPolicies = (): void => {
  isAddOptionalPoliciesDialogOpen.value = true;
};

const onCloseDialogAddDefaultPolicies = (): void => {
  autocompleteAddDefaultPoliciesValue.value.length = 0;
  isAddDefaultPoliciesDialogOpen.value = false;
};

const onCloseDialogAddOptionalPolicies = (): void => {
  autocompleteAddOptionalPoliciesValue.value.length = 0;
  isAddOptionalPoliciesDialogOpen.value = false;
};

const onAddDefaultPolicies = (): void => {
  defaultPolicies.value.push(...autocompleteAddDefaultPoliciesValue.value);
  onCloseDialogAddDefaultPolicies();
};

const onAddOptionalPolicies = (): void => {
  optionalPolicies.value.push(...autocompleteAddOptionalPoliciesValue.value);
  onCloseDialogAddOptionalPolicies();
};

const getPolicies = async (pagination: TableRequestParams) => {
  policiesLoading.value = true;
  policies.value = await policyTypesService.getPolicyTypes(
    route.params.service_provider_id.toString(),
    pagination,
  );

  policiesLoading.value = false;

  totalItems.value = policies.value!.total;
};

const handleUpdateLegalDocuments = (docs: string[]) => {
  documentItems.value = docs;
};

const onAddDocToLicense = async (licenseId: string) => {
  if (documentItems.value.length > 0) {
    const payload: AgreementTypeToLegalDocumentTypeUpdate = {
      legal_document_type_ids: documentItems.value,
    };
    await agreementTypesService.postAgreementTypeLegalDocumentTypes(
      serviceProviderId.value,
      licenseId,
      payload,
    );
  }
};

const handleUpdatePricing = (pricingDetails: AgreementTypeUpdate[]) => {
  license_pricing.value = [...pricingDetails];
};

const submitForm = async () => {
  if (!formPreparedForAPI.value || !checkIsFormValid()) return;
  try {
    hasUnsavedChanges.value = false;
    isButtonSubmitFormDisabled.value = true;
    isButtonSubmitFormLoading.value = true;
    const license: AgreementTypeRead =
      await agreementTypesService.postAgreementType(
        serviceProviderId.value,
        filterEmptyPropertiesFromObject(formPreparedForAPI.value),
      );
    onAddDocToLicense(license.id).then(() => {
      setTimeout(() => {
        router.push({
          name: currentCategoryData.value.routeName,
          params: {
            service_provider_id: serviceProviderId.value,
            license_id: license.id,
          },
        });
      }, 300);
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err, true),
      status: "error",
    });
  } finally {
    isButtonSubmitFormDisabled.value = false;
    isButtonSubmitFormLoading.value = false;
  }
};

const handleDuplicateMode = () => {
  if (settingsTabRef.value?.basicInformationEditRef?.form) {
    settingsTabRef.value.basicInformationEditRef.form.external_facing_name =
      agreementTypesService.state.license?.external_facing_name || "";

    settingsTabRef.value.basicInformationEditRef.form.name =
      agreementTypesService.state.license?.name || "";

    settingsTabRef.value.basicInformationEditRef.form.description =
      agreementTypesService.state.license?.description || null;

    settingsTabRef.value.basicInformationEditRef.form.external_facing_description =
      agreementTypesService.state.license?.external_facing_description || null;
  }
  const license = agreementTypesService.state.license;
  license_pricing.value = [
    {
      billing_period_length:
        license.billing_period_length ||
        license?.prices[0]?.billing_period_length,
      billing_period_unit:
        license.billing_period_unit || license?.prices[0]?.billing_period_unit,
      billing_type: license.billing_type || license?.prices[0]?.billing_type,
      ...license.price,
    },
  ];
};

onMounted(async () => {
  await getPolicies({
    limit: "10",
    offset: "0",
  });
  await unpublishedChangesStore.getUnpublishedConfig();
  if (route.query.duplicateMode) {
    handleDuplicateMode();
  } else {
    defaultPolicies.value = [];
    optionalPolicies.value = [];
  }
});

onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value) {
    if (doNotShowNextTime.valueOf()) next();
    else {
      setTextsForUnsavedChangesDialog("leave");
      nextRef.value = next;
      updateTargetPages(from.path.toString(), to.path.toString());
      warnUnsavedChanges();
    }
  } else {
    next();
  }
});

const updateMarketingFeatures = (featureList: string[]) => {
  marketingElementList.value = featureList;
};

const compareArraysById = (obj1, obj2) => {
  const ids1 = obj1.map(({ id }) => id);
  const ids2 = obj2.map(({ id }) => id);
  return isEqual(sortBy(ids1), sortBy(ids2));
};

const isBasicInformationHasChanges: ComputedRef<boolean> = computed(() =>
  Object.values(settingsTabRef.value?.basicInformationEditRef?.form ?? {}).some(
    Boolean,
  ),
);

const isDefaultPolicyTypesHasChanges: ComputedRef<boolean> = computed(() => {
  return defaultPolicies.value && license.value
    ? !compareArraysById(
        defaultPolicies.value,
        license.value.default_policy_types,
      )
    : false;
});

const isOptionalPolicyTypesHasChanges: ComputedRef<boolean> = computed(() => {
  return optionalPolicies.value && license.value
    ? !compareArraysById(
        optionalPolicies.value,
        license.value.optional_policy_types,
      )
    : false;
});

const hasChanges: ComputedRef<boolean> = computed(
  () =>
    isBasicInformationHasChanges.value ||
    isDefaultPolicyTypesHasChanges.value ||
    isOptionalPolicyTypesHasChanges.value ||
    hasChangesPricing.value ||
    legalDocumentsRef.value.hasChanges,
);

const alreadyAddedPolicies: ComputedRef<PolicyTypeRead[]> = computed(() => [
  ...defaultPolicies.value,
  ...optionalPolicies.value,
]);

const isButtonAddDefaultPoliciesDisabled: ComputedRef<boolean> = computed(
  () => !Boolean(autocompleteAddDefaultPoliciesValue.value.length),
);

const isButtonAddOptionalPoliciesDisabled: ComputedRef<boolean> = computed(
  () => !Boolean(autocompleteAddOptionalPoliciesValue.value.length),
);

const updateBasicInfoOpen = (value: boolean) => {
  isBasicInfoOpen.value = value;
};

const updatePoliciesOpen = (value: boolean) => {
  isPoliciesSectionOpen.value = value;
};

watch(
  () => hasChanges.value,
  (value) => {
    hasUnsavedChanges.value = value;
  },
);
</script>

<template>
  <m-m-page-header
    base-key="configuration.access_licenses.access_license_new"
    icon="document-check-add"
    icon-stroke="transparent"
    :breadcrumbs="breadcrumbs"
    :params="{ title, subtitle }"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <m-m-button
          cy="button-save-license"
          :is-disabled="isSaveButtonDisabled"
          :loading="isButtonSubmitFormLoading"
          @click="submitForm"
        >
          Save
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
        <m-m-button variant="outlined" cy="button-discard" @click="onDiscard">
          Discard
        </m-m-button>
      </div></template
    ></m-m-page-header
  >
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="currentTabName" :items="TABS" :is-in-edit-mode="true" />
  </m-m-teleport>
  <m-m-tab-items :current-tab="currentTabName">
    <m-m-tab-item keep-alive :name="TABS[0].name">
      <SettingsTab
        ref="settingsTabRef"
        :data="license"
        :is-create-mode="true"
        :default-policies="defaultPolicies"
        :optional-policies="optionalPolicies"
        :route-label="currentCategoryData.parent.label"
        :license-pricing="license_pricing"
        :is-access-category="isCurrentCategoryAccessLicense"
        :is-basic-info-open="isBasicInfoOpen"
        :is-policies-open="isPoliciesSectionOpen"
        :is-category-plan="isCurrentCategoryPlan"
        @remove-default-policy="onRemoveDefaultPolicy"
        @remove-optional-policy="onRemoveOptionalPolicy"
        @open-dialog-add-default-policies="onOpenDialogAddDefaultPolicies"
        @open-dialog-add-optional-policies="onOpenDialogAddOptionalPolicies"
        @update-list="handleUpdateLegalDocuments"
        @update-prices="handleUpdatePricing"
        @update-marketing-list="updateMarketingFeatures"
        @update:basic-info-open="updateBasicInfoOpen"
        @update:policies-open="updatePoliciesOpen"
      />
    </m-m-tab-item>
  </m-m-tab-items>

  <dialog-add-policies-to-license
    v-model="autocompleteAddDefaultPoliciesValue"
    :is-open="isAddDefaultPoliciesDialogOpen"
    policy-variant="default"
    :license-name="license?.name"
    :is-button-submit-disabled="isButtonAddDefaultPoliciesDisabled"
    :already-added-policies="alreadyAddedPolicies"
    :service-provider-id="serviceProviderId"
    @submit="onAddDefaultPolicies"
    @close="onCloseDialogAddDefaultPolicies"
  />

  <dialog-add-policies-to-license
    v-model="autocompleteAddOptionalPoliciesValue"
    :is-open="isAddOptionalPoliciesDialogOpen"
    policy-variant="optional"
    :license-name="license?.name"
    :is-button-submit-disabled="isButtonAddOptionalPoliciesDisabled"
    :already-added-policies="alreadyAddedPolicies"
    :service-provider-id="serviceProviderId"
    @submit="onAddOptionalPolicies"
    @close="onCloseDialogAddOptionalPolicies"
  />

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="confirmLeave(nextRef)"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>
