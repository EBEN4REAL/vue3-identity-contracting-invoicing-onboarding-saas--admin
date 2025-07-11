<script setup lang="ts">
import {
  computed,
  ComputedRef,
  onMounted,
  onUnmounted,
  ref,
  Ref,
  watch,
} from "vue";
import {
  useRoute,
  useRouter,
  NavigationGuardNext,
  onBeforeRouteLeave,
} from "vue-router";
import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import SettingsTab from "./Tabs/Settings/Settings.vue";
import AssignedLicenses from "./Tabs/AssignedItems/AssignedLicenses.vue";
import AssignedSubscriptions from "./Tabs/AssignedItems/AssignedSubscriptions.vue";
import {
  SettingsTabComponent,
  TypeCategoryData,
  TypePricingDetails,
} from "~/policies/License/types";
import { AgreementTypeUpdate, PolicyTypeRead } from "~/policies/policies.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import cloneDeep from "lodash/cloneDeep";
import DialogDeleteLicense from "./Dialogs/DialogDeleteLicense.vue";
import { AgreementTypeToLegalDocumentTypeUpdate } from "~/service-providers/LegalDocuments/legal-documents.types";
import { useFlag } from "@unleash/proxy-client-vue";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { convertToSubUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";
import { sortBy, isEqual } from "lodash";
import { ACCESS_LICENSE, PLAN } from "~/policies/License/constants";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import DialogAddPoliciesToLicense from "./Dialogs/DialogAddPoliciesToLicense.vue";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const settingsTabProps = computed(() => ({
  data: license.value,
  isEditMode: isInEditMode.value,
  isAccessCategory: isCurrentCategoryAccessLicense.value,
  isLoading: isLoading.value,
  defaultPoliciesEdit: defaultPolicyTypes.value,
  optionalPoliciesEdit: optionalPolicyTypes.value,
  serviceProviderId: serviceProviderId.value,
  routeLabel: currentCategoryData.value.parent.label,
  licensePricing: pricingDetails.value,
  isSubmitLoading: isButtonSubmitFormLoading.value,
  isBasicInfoOpen: isBasicInfoOpen.value,
  isPoliciesOpen: isPoliciesOpen.value,
  isCurrentCategoryPlan: isCurrentCategoryPlan.value,
}));

const route = useRoute();
const router = useRouter();
const licensePricingEnabled = useFlag("billing_and_invoicing");
const editMode = route.query.editMode;
const duplicateMode = route.query.duplicateMode;
const nextRef: Ref<NavigationGuardNext | null> = ref(null);
const isBasicInfoOpen: Ref<boolean> = ref(true);
const isPoliciesOpen: Ref<boolean> = ref(true);
const isAgreementTypesLoading: Ref<boolean> = ref(true);

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
const isInEditMode = ref(false);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const isButtonEditLicenseDisabled: ComputedRef<boolean> = computed(
  () => !isLicenseEditable.value || uiStore.isSPViewerOnly,
);

const scrimmedClass: ComputedRef<string> = computed(() =>
  license.value?.wizard?.hidden ? "mm-opacity-40" : "",
);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => isSaveButtonDisabled.value || isConfigPublishing.value,
);

const isCurrentCategoryAccessLicense: ComputedRef<boolean> = computed(() =>
  route.path.includes("/licenses/"),
);

const isCurrentCategoryPlan: ComputedRef<boolean> = computed(() =>
  route.path.includes("/plans/"),
);

const currentCategoryData: ComputedRef<TypeCategoryData> = computed(() =>
  isCurrentCategoryAccessLicense.value ? ACCESS_LICENSE : PLAN,
);

const TABS: ComputedRef<TypeTab[]> = computed(() => {
  const tabs = [{ label: "Settings", name: "Settings", isRequired: false }];

  if (!isCurrentCategoryPlan.value) {
    tabs.push({ label: "Accounts", name: "Accounts", isRequired: false });
  } else {
    tabs.push({
      label: "Subscriptions",
      name: "Subscriptions",
      isRequired: false,
    });
  }

  return tabs;
});
const currentTabName: Ref<string> = ref(TABS.value[0].name);
const settingsTabRef = ref<SettingsTabComponent | null>(null);
const serviceProviderId: Ref<string> = ref(
  route.params?.service_provider_id.toString(),
);
const marketingListItems: Ref<string[]> = ref([]);
const forceUpdate = ref(0);
const license: Ref<AgreementTypePoliciesRead | null> = ref(null);
const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const autocompleteAddDefaultPoliciesValue: Ref<string[]> = ref([]);
const autocompleteAddOptionalPoliciesValue: Ref<string[]> = ref([]);
const isAddDefaultPoliciesDialogOpen: Ref<boolean> = ref(false);
const isAddOptionalPoliciesDialogOpen: Ref<boolean> = ref(false);
const isSaveButtonDisabled: Ref<boolean> = ref(false);
const isButtonSubmitFormLoading: Ref<boolean> = ref(false);
const defaultPolicyTypes: Ref<PolicyTypeRead[]> = ref([]);
const optionalPolicyTypes: Ref<PolicyTypeRead[]> = ref([]);
const isLoading: Ref<boolean> = ref(true);
const documentItems: Ref<string[]> = ref([]);
const documentRemovedItems: Ref<string[]> = ref([]);
const pricingDetails: Ref<TypePricingDetails | null> = ref(null);
const initialPricingDetails: Ref<TypePricingDetails | null> = ref(null);
ref(null);
const legalDocumentsRef: Ref<{ hasChanges: boolean }> = ref({
  hasChanges: false,
});
const selectedDefaultPolicyTypes: Ref<PolicyTypeRead[]> = ref([]);
const isButtonAddDefaultPoliciesDisabled: Ref<boolean> = ref(true);
const isButtonAddDefaultPoliciesLoading: Ref<boolean> = ref(false);
const selectedOptionalPolicyTypes: Ref<PolicyTypeRead[]> = ref([]);
const isButtonAddOptionalPoliciesDisabled: Ref<boolean> = ref(true);
const isButtonAddOptionalPoliciesLoading: Ref<boolean> = ref(false);

const isPlanDeletable: ComputedRef<boolean> = computed(
  () => license.value?.deletable ?? true,
);

const dropdownItems: ComputedRef<TypeDropdownItem[]> = computed(() => [
  {
    label: "Duplicate",
    type: "button",
    hint: isConfigPublishing.value
      ? "You cannot duplicate this item as config is currently being published"
      : deleteLicenseHintText.value,
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    onClick: onDuplicateLicense,
  },
  {
    key: "delete-license",
    label: "Delete",
    hint: isConfigPublishing.value
      ? "You cannot delete this item as config is currently being published"
      : deleteLicenseHintText.value,
    isDisabled:
      isDeleteLicenseDisabled.value ||
      isConfigPublishing.value ||
      !isPlanDeletable.value ||
      uiStore.isSPViewerOnly,
    type: "button",
    color: "error",
    onClick: toggleConfirmDeleteDialog,
  },
]);

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    id: "licenses",
    label: currentCategoryData.value.parent.label,
    to: `/sp/${isCurrentCategoryPlan.value ? "" : "config/"}${currentCategoryData.value.parent.hash.toLocaleLowerCase()}`,
  },
  {
    id: "license",
    label: license.value?.external_facing_name,
  },
]);

const agreementTypeCustomersCount: ComputedRef<number> = computed(
  () => license.value?.agreements_count || 0,
);

// Disable delete license if it's already allocated to a customer
const isDeleteLicenseDisabled: ComputedRef<boolean> = computed(
  () => agreementTypeCustomersCount.value > 0,
);

const deleteLicenseHintText = computed(() =>
  isDeleteLicenseDisabled.value
    ? `You cannot delete this ${currentCategoryData.value.label.toLowerCase()} as there are active instances of it.`
    : null,
);

const selectedDefaultPolicyTypesPreparedForAPIAsIds: ComputedRef<string[]> =
  computed(() =>
    defaultPolicyTypes.value.map((policy: PolicyTypeRead) => policy.id),
  );

const selectedOptionalPolicyTypesPreparedForAPIAsIds: ComputedRef<string[]> =
  computed(() =>
    optionalPolicyTypes.value.map((policy: PolicyTypeRead) => policy.id),
  );

const formPreparedForAPI: ComputedRef<AgreementTypeUpdate | null> = computed(
  (): AgreementTypeUpdate | null => {
    if (settingsTabRef.value?.basicInformationEditRef?.form) {
      let newPricingDetails = cloneDeep(pricingDetails.value);
      if (newPricingDetails?.prices?.length) {
        newPricingDetails.prices[0].amount = convertToSubUnit(
          newPricingDetails.prices[0]?.amount,
          newPricingDetails.prices[0]?.currency,
        ).amount;
      }
      if (isCurrentCategoryAccessLicense.value) newPricingDetails = null;
      return {
        ...settingsTabRef.value?.basicInformationEditRef?.form,
        default_policy_types:
          selectedDefaultPolicyTypesPreparedForAPIAsIds.value,
        optional_policy_types:
          selectedOptionalPolicyTypesPreparedForAPIAsIds.value,
        distribution_allowed_organization: false,
        marketing_features: marketingListItems.value,
        prices: newPricingDetails,
      };
    }
    return null;
  },
);

const licenseName: ComputedRef<string> = computed(
  () =>
    formPreparedForAPI.value?.external_facing_name ||
    license.value?.external_facing_name ||
    "",
);

const licenseDescription: ComputedRef<string | null> = computed(
  () =>
    formPreparedForAPI.value?.external_facing_description ||
    license.value?.external_facing_description ||
    "",
);

const onEnterEditMode = () => {
  isInEditMode.value = true;
};

const onExitEditMode = () => {
  isInEditMode.value = false;
  hasUnsavedChanges.value = false;
};

const toggleConfirmDeleteDialog = () => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
};

const onDuplicateLicense = () => {
  router.push({
    path: `/sp/${serviceProviderId.value}/${currentCategoryData.value.duplicateLabel}/new`,
    query: { duplicateMode: "true" },
  });
  agreementTypesService.state.license = license.value;
};

const onDiscard = () => {
  if (hasUnsavedChanges.value) {
    setTextsForUnsavedChangesDialog("discard");
    warnUnsavedChanges();
  } else isInEditMode.value = false;
};

const onSubmitDialogUnsavedChanges = () => {
  pricingDetails.value = cloneDeep(initialPricingDetails.value);
  isInEditMode.value = false;
  hasUnsavedChanges.value = false;
  confirmLeave(nextRef.value);
};

const checkIsFormValid = () => {
  let isValid = true;
  settingsTabRef.value?.basicInformationEditRef?.v$.$validate();
  if (settingsTabRef.value?.basicInformationEditRef?.v$.$invalid) {
    isBasicInfoOpen.value = true;
    isValid = false;
  }
  if (!defaultPolicyTypes.value.length) {
    eventBus.$emit("onShowToast", {
      text: `A default policy is required for the ${currentCategoryData.value.label.toLowerCase()} to provide access to customers`,
      status: "error",
    });
    isPoliciesOpen.value = true;
    isValid = false;
  }
  return isValid;
};

const onRemoveDefaultPolicy = (id: string) => {
  if (defaultPolicyTypes.value) {
    defaultPolicyTypes.value = defaultPolicyTypes.value.filter(
      (policy: PolicyTypeRead) => policy.id !== id,
    );
  }
};

const onRemoveOptionalPolicy = (id: string) => {
  if (optionalPolicyTypes.value) {
    optionalPolicyTypes.value = optionalPolicyTypes.value.filter(
      (policy: PolicyTypeRead) => policy.id !== id,
    );
  }
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

const onAddDefaultPolicies = async () => {
  try {
    isButtonAddDefaultPoliciesDisabled.value = true;
    isButtonAddDefaultPoliciesLoading.value = true;

    const requests = autocompleteAddDefaultPoliciesValue.value.map(
      (policyType: string) =>
        policyTypesService.getPolicyType(
          serviceProviderId.value,
          policyType.id,
        ),
    );

    selectedDefaultPolicyTypes.value = await Promise.all(requests);
    defaultPolicyTypes.value.push(...selectedDefaultPolicyTypes.value);
    defaultPolicyTypes.value.sort((a: PolicyTypeRead, b: PolicyTypeRead) =>
      a?.external_facing_name.localeCompare(b?.external_facing_name),
    );
    onCloseDialogAddDefaultPolicies();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error adding default policies",
      status: "error",
    });
  } finally {
    isButtonAddDefaultPoliciesDisabled.value = false;
    isButtonAddDefaultPoliciesLoading.value = false;
  }
};

const onAddOptionalPolicies = async () => {
  try {
    isButtonAddOptionalPoliciesDisabled.value = true;
    isButtonAddOptionalPoliciesLoading.value = true;

    const requests = autocompleteAddOptionalPoliciesValue.value.map(
      (policyType: string) =>
        policyTypesService.getPolicyType(
          serviceProviderId.value,
          policyType.id,
        ),
    );

    selectedOptionalPolicyTypes.value = await Promise.all(requests);
    optionalPolicyTypes.value.push(...selectedOptionalPolicyTypes.value);
    optionalPolicyTypes.value.sort((a: PolicyTypeRead, b: PolicyTypeRead) =>
      a?.name.localeCompare(b?.name),
    );
    onCloseDialogAddOptionalPolicies();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error adding optional policies",
      status: "error",
    });
  } finally {
    isButtonAddOptionalPoliciesDisabled.value = false;
    isButtonAddOptionalPoliciesLoading.value = false;
  }
};

const getLicense = async () => {
  try {
    isAgreementTypesLoading.value = true;
    license.value = await agreementTypesService.getAgreementType(
      serviceProviderId.value,
      route.params?.license_id.toString(),
    );
    uiStore.isScrimmed = license.value?.wizard?.hidden ?? false;
    if (license.value) {
      pricingDetails.value = [...license.value.prices];
    }
  } finally {
    isAgreementTypesLoading.value = false;
  }
};

const setInitialPolicyTypes = () => {
  defaultPolicyTypes.value = license.value?.default_policies
    ? cloneDeep(license.value?.default_policies)
    : [];
  optionalPolicyTypes.value = license.value?.optional_policies
    ? cloneDeep(license.value?.optional_policies)
    : [];
};

const setInitialPricingDetails = () => {
  if (!license.value) return;
  initialPricingDetails.value = [...license.value.prices];
};

const onAddDocToLicense = async () => {
  try {
    if (documentItems.value.length > 0) {
      const payload: AgreementTypeToLegalDocumentTypeUpdate = {
        legal_document_type_ids: documentItems.value,
      };

      await agreementTypesService.postAgreementTypeLegalDocumentTypes(
        serviceProviderId.value,
        route.params?.license_id.toString(),
        payload,
      );
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
};

const onRemoveDocFromLicense = async () => {
  try {
    documentRemovedItems.value.forEach(async (documentToRemove) => {
      await agreementTypesService.deleteAgreementTypeLegalDocumentTypes(
        route.params?.service_provider_id.toString(),
        route.params?.license_id.toString(),
        documentToRemove,
      );
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  }
};

const submitForm = async () => {
  if (!formPreparedForAPI.value || !checkIsFormValid()) {
    return;
  }
  try {
    isSaveButtonDisabled.value = true;
    isButtonSubmitFormLoading.value = true;
    license.value = await agreementTypesService.patchAgreementType(
      serviceProviderId.value,
      route.params?.license_id.toString(),
      filterEmptyPropertiesFromObject(formPreparedForAPI.value),
    );
    forceUpdate.value++;
    await onAddDocToLicense();
    await onRemoveDocFromLicense();
    onExitEditMode();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(err),
      status: "error",
    });
  } finally {
    isSaveButtonDisabled.value = false;
    isButtonSubmitFormLoading.value = false;
  }
};

const handleUpdateLegalDocuments = (docs: string[]) => {
  documentItems.value = docs;
};

const handleRemoveLegalDocuments = (docs: string[]) => {
  documentRemovedItems.value = docs;
};
const handleUpdatePricing = (newPricingDetails: TypePricingDetails[]) => {
  pricingDetails.value = newPricingDetails;
};

onMounted(async () => {
  if (editMode) {
    onEnterEditMode();
  }
  if (duplicateMode) {
    onDuplicateLicense();
  }
  try {
    isLoading.value = true;
    await getLicense();

    if (license.value) {
      setInitialPolicyTypes();
      setInitialPricingDetails();
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
});

onBeforeRouteLeave((to, from, next) => {
  if (hasUnsavedChanges.value && isInEditMode.value) {
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

const compareObjects = (obj1, obj2) =>
  Object.keys(obj1).every(
    (key) => obj2.hasOwnProperty(key) && isEqual(obj1[key], obj2[key]),
  );

const compareArraysById = (obj1, obj2) => {
  const ids1 = obj1.map(({ id }) => id);
  const ids2 = obj2.map(({ id }) => id);
  return isEqual(sortBy(ids1), sortBy(ids2));
};

const isBasicInformationHasChanges: ComputedRef<boolean> = computed(() => {
  return settingsTabRef.value?.basicInformationEditRef && license.value
    ? !compareObjects(
        settingsTabRef.value?.basicInformationEditRef.form,
        license.value,
      )
    : false;
});

const isDefaultPolicyTypesHasChanges: ComputedRef<boolean> = computed(() => {
  return defaultPolicyTypes.value && license.value
    ? !compareArraysById(
        defaultPolicyTypes.value,
        license.value.default_policies,
      )
    : false;
});

const isOptionalPolicyTypesHasChanges: ComputedRef<boolean> = computed(() => {
  return optionalPolicyTypes.value && license.value
    ? !compareArraysById(
        optionalPolicyTypes.value,
        license.value.optional_policies,
      )
    : false;
});

const isPricingHasChanges: ComputedRef<boolean> = computed(() =>
  initialPricingDetails.value
    ? JSON.stringify(pricingDetails.value) !==
      JSON.stringify(initialPricingDetails.value)
    : false,
);

const isPricingInPlanEnabled: ComputedRef<boolean> = computed(() =>
  Boolean(licensePricingEnabled.value || isCurrentCategoryPlan.value),
);

const hasChanges: ComputedRef<boolean> = computed(
  () =>
    isBasicInformationHasChanges.value ||
    isDefaultPolicyTypesHasChanges.value ||
    isOptionalPolicyTypesHasChanges.value ||
    (isPricingInPlanEnabled.value ? isPricingHasChanges.value : false) ||
    legalDocumentsRef.value.hasChanges,
);

const alreadyAddedPolicies: ComputedRef<PolicyTypeRead[]> = computed(() =>
  license.value
    ? [...license.value.default_policies, ...license.value.optional_policies]
    : [],
);

const isLicenseEditable: ComputedRef<boolean> = computed(
  () => (license.value?.editable ?? true) && !isConfigPublishing.value,
);

const handleUpdateMarketingFeatures = (list: string[]) => {
  marketingListItems.value = list;
};

const onDialogDeleteLicenseClose = async () => {
  isConfirmDeleteDialogOpen.value = false;
};

watch(
  () => hasChanges.value,
  (value) => {
    hasUnsavedChanges.value = value;
  },
);

watch(
  () => isInEditMode.value,
  () => {
    if (!isInEditMode.value) setInitialPolicyTypes();
  },
);

watch(
  () => autocompleteAddDefaultPoliciesValue.value,
  () => {
    isButtonAddDefaultPoliciesDisabled.value =
      autocompleteAddDefaultPoliciesValue.value.length === 0;
  },
);

watch(
  () => autocompleteAddOptionalPoliciesValue.value,
  () => {
    isButtonAddOptionalPoliciesDisabled.value =
      autocompleteAddOptionalPoliciesValue.value.length === 0;
  },
);

const updateBasicInfoOpen = (value: boolean) => {
  isBasicInfoOpen.value = value;
};

const updatePoliciesOpen = (value: boolean) => {
  isPoliciesOpen.value = value;
};

onUnmounted(() => {
  uiStore.isScrimmed = false;
});
</script>

<template>
  <m-m-teleport to="mm-config-banner-section">
    <wizard-banner
      v-if="license?.wizard"
      :wizard="license?.wizard"
      :item-id="license.id"
      class="mm-mb-8"
    />
  </m-m-teleport>
  <m-m-page-header
    base-key="license_details"
    icon="document-check"
    :breadcrumbs="breadcrumbs"
    :is-in-edit-mode="isInEditMode"
    :params="{ licenseName, licenseDescription }"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <template #header-controls>
      <div class="mm-flex mm-flex-gap-6">
        <template v-if="isInEditMode">
          <m-m-button
            cy="button-save-license"
            :is-disabled="isButtonSubmitDisabled"
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
        </template>
        <m-m-button
          v-else
          variant="outlined"
          prepend-icon="pen"
          cy="button-edit-license"
          :is-disabled="isButtonEditLicenseDisabled"
          @click="onEnterEditMode"
        >
          Edit
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
        <m-m-dropdown
          cy="license-dropdown-items"
          :items="dropdownItems"
          list-variant="shadow"
          max-width="218px"
        /></div></template
  ></m-m-page-header>
  <m-m-teleport to="common-page-layout-header-tabs">
    <m-m-tabs v-model="currentTabName" :items="TABS" :is-in-edit-mode="true" />
  </m-m-teleport>
  <m-m-tab-items :current-tab="currentTabName" :class="scrimmedClass">
    <m-m-tab-item keep-alive :name="TABS[0].name">
      <SettingsTab
        v-if="license"
        ref="settingsTabRef"
        v-bind="settingsTabProps"
        @update-marketing-list="handleUpdateMarketingFeatures"
        @remove-default-policy="onRemoveDefaultPolicy"
        @remove-optional-policy="onRemoveOptionalPolicy"
        @open-dialog-add-default-policies="onOpenDialogAddDefaultPolicies"
        @open-dialog-add-optional-policies="onOpenDialogAddOptionalPolicies"
        @update-prices="handleUpdatePricing"
        @update-list="handleUpdateLegalDocuments"
        @remove-document="handleRemoveLegalDocuments"
        @update:basic-info-open="updateBasicInfoOpen"
        @update:policies-open="updatePoliciesOpen"
      />
    </m-m-tab-item>
    <m-m-tab-item keep-alive :name="TABS[1].name">
      <assigned-licenses
        v-if="!isCurrentCategoryPlan"
        :service-provider-id="serviceProviderId"
        :license-name="license?.name"
        :is-agreement-published="license?.published"
        :no-default-policies="!defaultPolicyTypes.length"
      />
      <assigned-subscriptions
        v-else
        :service-provider-id="serviceProviderId"
        :is-agreement-published="license?.published"
        :no-default-policies="!defaultPolicyTypes.length"
      />
    </m-m-tab-item>
  </m-m-tab-items>
  <DialogDeleteLicense
    :is-open="isConfirmDeleteDialogOpen"
    :service-provider-id="serviceProviderId"
    :license-id="license?.id"
    :is-edit-view="true"
    :route-label="currentCategoryData.parent.label"
    @close-dialog="onDialogDeleteLicenseClose"
  />

  <dialog-add-policies-to-license
    v-model="autocompleteAddDefaultPoliciesValue"
    :is-open="isAddDefaultPoliciesDialogOpen"
    policy-variant="default"
    :license-name="license?.external_facing_name"
    :is-button-submit-disabled="isButtonAddDefaultPoliciesDisabled"
    :is-button-submit-loading="isButtonAddDefaultPoliciesLoading"
    :already-added-policies="alreadyAddedPolicies"
    :service-provider-id="serviceProviderId"
    @submit="onAddDefaultPolicies"
    @close="onCloseDialogAddDefaultPolicies"
  />

  <dialog-add-policies-to-license
    v-model="autocompleteAddOptionalPoliciesValue"
    :is-open="isAddOptionalPoliciesDialogOpen"
    policy-variant="optional"
    :license-name="license?.external_facing_name"
    :is-button-submit-disabled="isButtonAddOptionalPoliciesDisabled"
    :is-button-submit-loading="isButtonAddOptionalPoliciesLoading"
    :already-added-policies="alreadyAddedPolicies"
    :service-provider-id="serviceProviderId"
    @submit="onAddOptionalPolicies"
    @close="onCloseDialogAddOptionalPolicies"
  />

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>

<style scoped lang="scss"></style>
