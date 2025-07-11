<script setup lang="ts">
import {
  computed,
  onMounted,
  ref,
  Ref,
  reactive,
  watch,
  ComputedRef,
  onUnmounted,
} from "vue";
import { PolicyTypeCreate, PolicyTypeRead } from "~/policies/policies.types";
import { UxBehavior } from "../ConfigurationTabs/Policies/policies.types";
import {
  NavigationGuardNext,
  onBeforeRouteLeave,
  useRoute,
  useRouter,
} from "vue-router";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import SettingsTab from "./tabs/Settings.vue";
import TabRelatedItems from "~/service-providers/PolicyTypeDetail/tabs/RelatedItems.vue";
import TabAccounts from "~/service-providers/PolicyTypeDetail/tabs/Accounts.vue";
import TabUsers from "~/service-providers/PolicyTypeDetail/tabs/Users.vue";
import {
  PolicyTypeDetailForm,
  PolicyTypeDetailMode,
} from "~/service-providers/PolicyTypeDetail/policyTypeDetail.types";
import { POLICY_TYPE_CATEGORY } from "~/service-providers/PolicyTypeDetail/constants";

import { TypeTab } from "~/mm_ui_kit/src/types/types";
import { FilterRead } from "~/service-providers/Filters/filters.types";
import useActiveTab from "~/mm_ui_kit/src/composables/activeTabIndexBasedOnURL";
import { useCategoryConfig } from "~/mm_ui_kit/src/composables/uxCategoryConfig";
import { merge, cloneDeep, isEqual } from "lodash";
import { TypeBreadcrumbItem } from "~/mm_ui_kit/src/types/breadcrumb.types";
import { usePolicyUxCategoriesStore } from "~/stores/policyUxCategories";
import { useUnsavedChanges } from "~/mm_ui_kit/src/composables/useUnsavedChanges";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { policyTypesService } from "~/configuration/policy-types.service";
import { policiesService } from "~/service-providers/policies.service";
import { filtersService } from "~/configuration/filters.service";
import { getErrorMessage } from "../_shared/helpers/configErrorMessageHelper";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { SPPolicyTypeRead } from "~/configuration/configuration.types";
import { filterEmptyPropertiesFromObject } from "~/mm_ui_kit/src/helpers/utils";
import WizardBanner from "~/service-providers/WizardBanner.vue";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const settingsTabProps = computed(() => ({
  form: form,
  mode: mode.value,
  serviceProviderId: serviceProviderId.value,
  uxCategoryConfig: uxCategory.value,
  policyTypes: uniquePolicyTypes.value,
  parentPolicyType: policyType.value,
  isLoading: isLoading.value,
  isDiscarded: isDiscarded.value,
  filters: uniqueFilters.value,
}));

const policyUxCategoriesStore = usePolicyUxCategoriesStore();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const uiStore = useUiStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isConfigNotPublished: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus !==
      ConfigPublishStatusEnum.PUBLISHED.enum,
  ),
);

const breadcrumbs: ComputedRef<TypeBreadcrumbItem[]> = computed(() => [
  {
    to: breadcrumbPath.value,
    label: breadcrumbLabel.value,
  },
  {
    to: isCreating.value
      ? `/sp/${serviceProviderId.value}/policy-types/new/${route.params.ux_category_id}`
      : `/sp/${serviceProviderId.value}/policy-types/${policyType.value?.id}`,
    label: isCreating.value
      ? `Add ${activeCategoryName.value || "Policy"}`
      : (policyType.value?.external_facing_name as string),
  },
]);

const route = useRoute();
const router = useRouter();

const editMode = route.query.editMode;
const policyType: Ref<SPPolicyTypeRead | null> = ref(null);
const serviceProviderId: Ref<string> = ref("");
const isServiceProvider: Ref<boolean | null> = ref(false);
const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const childPolicyTypes: Ref<SPPolicyTypeRead[]> = ref([]);
const newChildPolicyTypes: Ref<SPPolicyTypeRead[]> = ref([]);
const childPolicyTypeIds: Ref<string[]> = ref([]);
const filters: Ref<FilterRead[]> = ref([]);
const isLoading: Ref<boolean> = ref(true);
const newFilters: Ref<FilterRead[]> = ref([]);
const filterIds: Ref<string[]> = ref([]);
const preparedChildPolicyTypeIds: Ref<string[]> = ref([]);
const preparedPolicyTypes: Ref<SPPolicyTypeRead[]> = ref([]);
const preparedFilterIds: Ref<string[]> = ref([]);
const preparedFilters: Ref<FilterRead[]> = ref([]);
const isDiscarded: Ref<boolean> = ref(false);
const isRemovingPolicy: Ref<boolean> = ref(false);
const isRemovingFilter: Ref<boolean> = ref(false);
const filtersForRemoval: Ref<FilterRead[]> = ref([]);
const childPolicyTypesForRemoval: Ref<SPPolicyTypeRead[]> = ref([]);
const isSaving: Ref<boolean> = ref(false);
const policyUpdateHasError: Ref<boolean> = ref(false);
const isFormLoaded: Ref<boolean> = ref(false);
const isBasicInfoOpen: Ref<boolean> = ref(true);

const setActiveCategory = (categoryId: string) => {
  policyUxCategoriesStore.setActiveCategory(categoryId);
};

const activeCategoryName = computed(
  () => policyUxCategoriesStore.activeCategoryName,
);

const policyCategoryId = computed(() => policyUxCategoriesStore.activeCategory);

const uxCategory: Ref<UxBehavior> = ref([]);
const categoryLoading = ref(true);

const { getDefaultValue } = useCategoryConfig(uxCategory);
const settingsTabRef = ref(null);
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

const TABS: ComputedRef<TypeTab[]> = computed(() => {
  return [
    {
      label: "Settings",
      name: "Settings",
      isRequired: false,
    },
    {
      label: "Related items",
      name: "Related items",
      isRequired: false,
      isHidden: !policyType.value || isCreating.value,
    },
    {
      label: "Accounts",
      name: "Accounts",
      isRequired: false,
      isHidden: !policyType.value || isCreating.value,
    },
    {
      label: "Users",
      name: "Users",
      isRequired: false,
      isHidden: !policyType.value || isCreating.value,
    },
  ];
});

const activeTab = useActiveTab(TABS.value[0].name);

const policyPlaceholder = `Add ${activeCategoryName.value || "Policy"}`;

const toggleConfirmDelete = () => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
};

const mode: Ref<PolicyTypeDetailMode> = ref(
  route.name === "NewPolicyType" ? "create" : editMode ? "edit" : "view",
);
const isEditing: ComputedRef<boolean> = computed(() => mode.value === "edit");
const isCreating: ComputedRef<boolean> = computed(
  () => mode.value === "create",
);

const scrimmedClass: ComputedRef<string> = computed(() =>
  policyType.value?.wizard?.hidden ? "mm-opacity-40" : "",
);

const isCreatingOrEditing = computed(() => isCreating.value || isEditing.value);

const setMode = (modeValue: PolicyTypeDetailMode, discarded?: boolean) => {
  mode.value = modeValue;
  if (discarded) {
    isDiscarded.value = true;
    preparedFilters.value = [];
    preparedPolicyTypes.value = [];
  } else {
    isDiscarded.value = false;
  }
};

const form: PolicyTypeDetailForm = reactive({
  external_facing_name: "",
  name: "",
  external_facing_description: "",
  description: "",
  outcome: "",
  audit_level: "",
  troubleshoot: false,
  troubleshoot_end: "",
  return_value: "",
});

const initialForm: PolicyTypeDetailForm = reactive({
  external_facing_name: "",
  name: "",
  external_facing_description: "",
  description: "",
  outcome: "",
  audit_level: "",
  troubleshoot: false,
  troubleshoot_end: "",
  return_value: "",
});

const title: ComputedRef<string> = computed(
  () =>
    form.external_facing_name || policyType.value?.name || policyPlaceholder,
);
const subtitle: ComputedRef<string> = computed(
  () => form.external_facing_description || policyType.value?.description || "",
);

const breadcrumbLabel: ComputedRef<string> = computed(() =>
  activeCategoryName.value === "Role" ? "Roles" : "Policies",
);

const breadcrumbPath: ComputedRef<string> = computed(() =>
  activeCategoryName.value === "Role" ? "/sp/roles" : "/sp/policies",
);

const uniqueFilters: ComputedRef<FilterRead[]> = computed(() => {
  const uniqueFiltersMap = new Map<string, FilterRead>();
  const filtersToDisplay = [...newFilters.value, ...preparedFilters.value];

  filtersToDisplay.forEach((filter) => {
    uniqueFiltersMap.set(filter.id, filter);
  });

  const finalUniqueFiltersMap = Array.from(uniqueFiltersMap.values());
  const filterIdsForRemoval = filtersForRemoval.value.map(
    (filter) => filter.id,
  );

  if (filtersForRemoval.value.length > 0) {
    return finalUniqueFiltersMap.filter(
      (item) => !filterIdsForRemoval.includes(item.id),
    );
  }
  return finalUniqueFiltersMap;
});

const uniquePolicyTypes: ComputedRef<SPPolicyTypeRead[]> = computed(() => {
  const uniquePolicyTypesMap = new Map<string, PolicyTypeRead>();
  const policyTypesToDisplay = [
    ...newChildPolicyTypes.value,
    ...preparedPolicyTypes.value,
  ];

  policyTypesToDisplay.forEach((policyType) => {
    uniquePolicyTypesMap.set(policyType.id, policyType);
  });
  childPolicyTypesForRemoval.value.forEach((policyType) => {
    uniquePolicyTypesMap.delete(policyType.id);
  });

  return Array.from(uniquePolicyTypesMap.values());
});

const isPolicyDeletable: ComputedRef<boolean> = computed(
  () => policyType.value?.deletable ?? true,
);

const mainHeaderDropdownItems = computed(() => {
  const items = [];

  if (!isCreating.value) {
    items.push({
      label: "Delete",
      type: "button",
      color: "error",
      isDisabled:
        isCreating.value ||
        uiStore.isSPViewerOnly ||
        isDeletePolicyDisabled.value ||
        isConfigPublishing.value ||
        !isPolicyDeletable.value,
      hint: deletePolicyHintText.value,
      onClick: toggleConfirmDelete,
    });
  }

  return items;
});

const isDeletePolicyDisabled = computed(
  () =>
    policyType.value?.has_child_or_parent_policy_types ||
    policyType.value?.used_in_agreement_type,
);

const deletePolicyHintText = computed(() => {
  if (isDeletePolicyDisabled.value) {
    return "You cannot delete this policy as there are active instances of it.";
  }
  if (isConfigPublishing.value) {
    return "You cannot delete this item as config is currently being published.";
  }
  return null;
});

const isPolicyEditable: ComputedRef<boolean> = computed(
  () =>
    ((policyType.value?.editable ?? true) && !isConfigPublishing.value) ||
    !uiStore.isSPViewerOnly,
);

const isButtonEditDisabled: ComputedRef<boolean> = computed(
  () => uiStore.isSPViewerOnly || !isPolicyEditable.value,
);

const onDiscard = () => {
  const navigateToConfigItem = () => {
    const path =
      activeCategoryName.value?.toLocaleLowerCase() === "role"
        ? "/sp/roles"
        : "/sp/policies";
    router.push({ path });
  };
  if (isEditing.value) {
    if (hasUnsavedChanges.value) {
      setTextsForUnsavedChangesDialog("discard");
      warnUnsavedChanges();
    } else mode.value = "view";
  }
  if (isCreating.value) {
    if (hasUnsavedChanges.value) {
      setTextsForUnsavedChangesDialog("leave");
      warnUnsavedChanges();
    }
    navigateToConfigItem();
  }
};

const onSubmitDialogUnsavedChanges = () => {
  hasUnsavedChanges.value = false;
  isDialogUnsavedChangesOpen.value = false;
  if (isEditing.value) {
    updateForm(policyType.value as PolicyTypeDetailForm, true);
    setMode("view", true);
  }
  confirmLeave(nextRef.value);
};

const fetchPolicyType = async () => {
  if (isCreating.value) {
    isLoading.value = false;
    return;
  }

  const policyTypeId = route.params.policy_type_id as string;

  if (!policyTypeId || !serviceProviderId.value) {
    isLoading.value = false;
    return;
  }

  policyType.value = await policyTypesService.getPolicyType(
    serviceProviderId.value,
    policyTypeId,
  );

  uiStore.isScrimmed = policyType.value?.wizard?.hidden ?? false;

  if (
    policyType.value?.child_policy_types &&
    policyType.value?.child_policy_types.length > 0
  ) {
    childPolicyTypeIds.value = policyType.value?.child_policy_types;
    newChildPolicyTypes.value = await Promise.all(
      policyType.value?.child_policy_types.map((childPolicyId) =>
        policyTypesService.getPolicyType(
          serviceProviderId.value,
          childPolicyId,
        ),
      ),
    );

    if (childPolicyTypes.value.length === 0) {
      childPolicyTypes.value = newChildPolicyTypes.value;
    }
  } else {
    newChildPolicyTypes.value = [];
  }

  if (policyType.value?.filters && policyType.value?.filters.length > 0) {
    filterIds.value = policyType.value?.filters;
    newFilters.value = await Promise.all(
      policyType.value?.filters.map((filterId) =>
        filtersService.getFilterById(serviceProviderId.value, filterId),
      ),
    );

    if (filters.value.length === 0) {
      filters.value = newFilters.value;
    }
  } else {
    newFilters.value = [];
  }
  isLoading.value = false;
  updateForm(policyType.value as PolicyTypeDetailForm);
};

const fetchPolicyCategory = async () => {
  uxCategory.value = await policiesService.getPolicyTypeCategoryUx(
    policyCategoryId.value || POLICY_TYPE_CATEGORY,
  );
  categoryLoading.value = false;
};

const setInitialFormData = () => {
  Object.assign(initialForm, form);
};

const updateForm = (newForm?: PolicyTypeDetailForm) => {
  if (!newForm) {
    return;
  }

  form.external_facing_name =
    newForm.external_facing_name ||
    getDefaultValue("policy_external_facing_name") ||
    "";
  form.name = newForm.name || getDefaultValue("policy_name") || "";
  form.external_facing_description =
    newForm.external_facing_description ||
    getDefaultValue("policy_external_facing_description") ||
    "";
  form.description =
    newForm.description || getDefaultValue("policy_description") || "";
  form.outcome = newForm.outcome || getDefaultValue("decision_row") || "";
  form.audit_level =
    newForm.audit_level || getDefaultValue("audit_level_row") || "";
  form.troubleshoot =
    newForm.troubleshoot || getDefaultValue("audit_level_row") === "true";
  form.troubleshoot_end =
    newForm.troubleshoot_end || getDefaultValue("audit_level_row");
  form.return_value =
    newForm.return_value || getDefaultValue("return_value") || null;
};

const onDeleteButtonClick = async () => {
  await policyTypesService.deletePolicyType(
    serviceProviderId.value,
    policyType.value?.id as string,
  );
  toggleConfirmDelete();
  if (isConfigNotPublished.value)
    localStorage.setItem("hideConfigBanner", "false");
  router.push("/sp/config/policies");
};

const handlePolicyRemoval = (removePolicy: boolean) => {
  isRemovingPolicy.value = removePolicy;
};

const handleFilterRemoval = (removeFilter: boolean) => {
  isRemovingFilter.value = removeFilter;
};
const updatedPolicyTypes = () => {
  return isRemovingPolicy.value
    ? preparedChildPolicyTypeIds.value
    : [
        ...preparedChildPolicyTypeIds.value,
        ...newChildPolicyTypes.value.map(
          (policyType: SPPolicyTypeRead) => policyType.id,
        ),
      ];
};

const updatedFilters = () =>
  isRemovingFilter.value
    ? preparedFilterIds.value
    : [
        ...preparedFilterIds.value,
        ...newFilters.value.map((filter: FilterRead) => filter.id),
      ];

const putRoles = async () => {
  if (!policyTypesService.state.roleSelected) return;
  try {
    await policyTypesService.putRoles(
      serviceProviderId.value,
      policyType.value?.id as string,
      [policyTypesService.state.roleSelected.id],
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error while adding roles",
      status: "error",
    });
    policyUpdateHasError.value = true;
  } finally {
    policyTypesService.state.rolesSelected = [];
  }
};

const addPermissions = async () => {
  try {
    await policyTypesService.addPermissions(
      serviceProviderId.value,
      policyType.value?.id as string,
      policyTypesService.getPermissionsSelectedIds,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error while adding permissions",
      status: "error",
    });
    policyUpdateHasError.value = true;
  } finally {
    policyTypesService.state.permissionsSelected = [];
  }
};

const addFilterToPolicyTypeReq = async (filter_id: string) => {
  const payload = {
    filter_id,
  };
  try {
    await policyTypesService.addFilterToPolicyType(
      serviceProviderId.value,
      policyType.value?.id as string,
      payload,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error adding filter to policy`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const removeFilterFromPolicyTypeReq = async (filterId: string) => {
  try {
    await policyTypesService.removeFilterFromPolicyType(
      serviceProviderId.value,
      policyType.value?.id as string,
      filterId,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error removing filter from policy`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const removeChildPolicyTypeFromPolicyTypeReq = async (
  childPolicyTypeId: string,
) => {
  try {
    await policyTypesService.removeChildPolicyTypeFromPolicyType(
      serviceProviderId.value,
      policyType.value?.id as string,
      childPolicyTypeId,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error removing child policy from policy`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const addChildPolicyTypeToPolicyTypeReq = async (
  child_policy_type_id: string,
) => {
  const payload = {
    child_policy_type_id,
  };

  try {
    await policyTypesService.addChildPolicyTypeToPolicyType(
      serviceProviderId.value,
      policyType.value?.id as string,
      payload,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `This setup creates an invalid loop, the child policy you are trying to add is already a parent of this policy`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const addFiltersToPolicyType = async (filterIds: string[]) => {
  try {
    const promises = filterIds.map((filterId) =>
      addFilterToPolicyTypeReq(filterId),
    );
    await Promise.all(promises);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error adding filter${filterIds.length > 0 ? "s" : ""} to policy type`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const removeFiltersFromPolicyType = async (filterIds: string[]) => {
  try {
    const promises = filterIds.map((filterId) =>
      removeFilterFromPolicyTypeReq(filterId),
    );
    await Promise.all(promises);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error removing filter${filterIds.length > 0 ? "s" : ""} from policy type`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const removeChildPolicyTypesFromPolicyType = async (
  childPolicyTypeIds: string[],
) => {
  try {
    const promises = childPolicyTypeIds.map((childPolicyTypeId) =>
      removeChildPolicyTypeFromPolicyTypeReq(childPolicyTypeId),
    );
    await Promise.all(promises);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error removing child polic${childPolicyTypeIds.length > 1 ? "ies" : "y"} from policy type`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const addChildPolicyTypesToPolicyType = async (
  childPolicyTypeIds: string[],
) => {
  try {
    const promises = childPolicyTypeIds.map((childPolicyTypeId) =>
      addChildPolicyTypeToPolicyTypeReq(childPolicyTypeId),
    );
    await Promise.all(promises);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: `Error removing child polic${childPolicyTypeIds.length > 1 ? "ies" : "y"} from policy type`,
      status: "error",
    });
    policyUpdateHasError.value = true;
  }
};

const onSave = async () => {
  settingsTabRef.value?.basicInformationRef.v$.$touch();
  settingsTabRef.value?.basicInformationRef.v$.$validate();
  if (settingsTabRef.value?.basicInformationRef.v$.$error) {
    isBasicInfoOpen.value = true;
    return;
  }

  isSaving.value = true;

  const uniqueFiltersToAdd = [...preparedFilterIds.value].filter(
    (filterId) => !newFilters.value.some((filter) => filter.id === filterId),
  );
  const filtersForRemovalIds = filtersForRemoval.value.map(
    (filter) => filter.id,
  );
  const uniqueFilterToRemove = filtersForRemovalIds.filter((filterId) =>
    newFilters.value.some((filter) => filter.id === filterId),
  );

  const newChildPolicyTypeIds = new Set(
    newChildPolicyTypes.value.map((childPolicy) => childPolicy.id),
  );

  const uniqueChildPolicyTypeToUpdate = preparedChildPolicyTypeIds.value.filter(
    (childPolicyTypeId) => !newChildPolicyTypeIds.has(childPolicyTypeId),
  );

  const childPolicyTypesForRemovalIds = childPolicyTypesForRemoval.value.map(
    (childPolicyType) => childPolicyType.id,
  );

  const uniqueChildPolicyTypeToRemove = childPolicyTypesForRemovalIds.filter(
    (childPolicyTypeId) => newChildPolicyTypeIds.has(childPolicyTypeId),
  );

  try {
    if (mode.value === "edit") {
      await putRoles();
      eventBus.$emit("fetchRoleForOIDCClaim", {});
      await policyTypesService.patchPolicyType(
        serviceProviderId.value,
        policyType.value?.id as string,
        filterEmptyPropertiesFromObject(form),
      );
      await addFiltersToPolicyType(uniqueFiltersToAdd);
      await removeFiltersFromPolicyType(uniqueFilterToRemove);
      await removeChildPolicyTypesFromPolicyType(uniqueChildPolicyTypeToRemove);
      await addChildPolicyTypesToPolicyType(uniqueChildPolicyTypeToUpdate);

      if (policyTypesService.getPermissionsSelectedIds.length) {
        await addPermissions();
        eventBus.$emit("fetchPermissions", {});
      }
      await fetchPolicyType();
      setMode("view");
      if (!policyUpdateHasError.value) {
        policyUpdateHasError.value = false;
      }
    } else {
      policyType.value = await policyTypesService.postPolicyType(
        serviceProviderId.value,
        {
          ...filterEmptyPropertiesFromObject(form),
          service_provider_id: serviceProviderId.value,
          category_id: policyCategoryId.value || POLICY_TYPE_CATEGORY,
          child_policy_types: Array.from(new Set(updatedPolicyTypes())),
          filters: Array.from(new Set(updatedFilters())),
        } as PolicyTypeCreate,
      );

      if (policyTypesService.state.roleSelected) await putRoles();
      if (policyTypesService.getPermissionsSelectedIds.length)
        await addPermissions();
      await fetchPolicyType();

      router.push({
        name: "PolicyTypeDetail",
        query: {
          activeCategoryName:
            policyUxCategoriesStore.activeCategoryName === "Role"
              ? "Role"
              : "Policy",
        },
        params: {
          service_provider_id: serviceProviderId.value,
          policy_type_id: policyType.value.id,
        },
      });
    }
    hasUnsavedChanges.value = false;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(error, true),
      status: "error",
    });
  } finally {
    isSaving.value = false;
  }
};

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

watch(
  () => mode.value,
  (val) => {
    if (val === "create") {
      policyType.value = merge(cloneDeep(policyType.value), form);
      activeTab.value = TABS.value[0].name;
    }
  },
  { immediate: true },
);

watch(
  () => form.outcome,
  (decision) => {
    form.audit_level = decision === "AUDIT" ? "I" : "";
  },
  { immediate: true },
);

watch(
  () => [isFormLoaded.value, form, uniqueFilters.value],
  ([isFormLoadedNew, newForm, newUniqueFilters]) => {
    if (!isFormLoadedNew) return;

    const stringifiedInitialForm = JSON.stringify(initialForm);
    const stringifiedForm = JSON.stringify(newForm).replace(
      '"audit_level":" "',
      '"audit_level":""',
    );
    const isBasicInformationFormHasChanges =
      stringifiedInitialForm !== stringifiedForm;

    const newFiltersIds = newFilters.value.map((filterItem) => filterItem.id);
    const newUniqueFiltersIds = newUniqueFilters.map(
      (filterItem) => filterItem.id,
    );

    const isFiltersHasChanges = !isEqual(newFiltersIds, newUniqueFiltersIds);

    const isRolesHasChanges = Boolean(
      policyTypesService.getRolesSelectedIds.length,
    );
    const isPermissionsHasChanges = Boolean(
      policyTypesService.getPermissionsSelectedIds.length,
    );

    hasUnsavedChanges.value =
      isBasicInformationFormHasChanges ||
      isFiltersHasChanges ||
      isRolesHasChanges ||
      isPermissionsHasChanges;
  },
  { deep: true },
);

const handlePreparedChildPolicies = (childPolicies: SPPolicyTypeRead[]) => {
  preparedPolicyTypes.value = childPolicies;
  preparedChildPolicyTypeIds.value = childPolicies.map(
    (policyType: SPPolicyTypeRead) => policyType.id,
  );
};

const handlePreparedFilters = (filters: FilterRead[]) => {
  preparedFilters.value = filters;
  preparedFilterIds.value = filters.map((filter: FilterRead) => filter.id);
};

const updateChildPolicyTypeRemoval = (
  removedChildPolicyTypes: SPPolicyTypeRead[],
) => {
  childPolicyTypesForRemoval.value = removedChildPolicyTypes;
};

const updateFiltersForRemoval = (removedFilters: FilterRead[]) => {
  filtersForRemoval.value = removedFilters;
};

const updateIsBasicInfoOpen = (value: boolean) => {
  isBasicInfoOpen.value = value;
};

onMounted(async () => {
  serviceProviderId.value = route.params.service_provider_id as string;

  const serviceProvider = await serviceProvidersService.getServiceProvider(
    serviceProviderId.value,
  );

  isServiceProvider.value = !!serviceProvider.id;

  await fetchPolicyCategory();
  await fetchPolicyType();

  updateForm();
  setInitialFormData();
  if (!isCreating.value) {
    setActiveCategory(policyType.value?.category_id as string);
  }
  isFormLoaded.value = true;
});

onUnmounted(() => {
  uiStore.isScrimmed = false;
});
</script>

<template>
  <template v-if="!categoryLoading">
    <m-m-teleport to="mm-config-banner-section">
      <wizard-banner
        v-if="policyType?.wizard"
        :wizard="policyType?.wizard"
        :item-id="policyType.id"
        class="mm-mb-8"
      />
    </m-m-teleport>
    <m-m-page-header
      base-key="configuration.policies.policy_details"
      icon="shield-check-outline"
      :breadcrumbs="breadcrumbs"
      :is-in-edit-mode="isCreatingOrEditing"
      :config-banner-cmp="ConfigPublishBanner"
      :params="{
        policyName: title,
        policyDescription: subtitle,
      }"
    >
      <template #header-controls>
        <div class="mm-flex mm-flex-gap-6">
          <template v-if="isCreatingOrEditing">
            <m-m-button
              cy="save-policy-type-button"
              :loading="isSaving"
              :is-disabled="isConfigPublishing"
              @click="onSave"
            >
              Save
              <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
                Config is currently being published.
              </m-m-tooltip>
            </m-m-button>
            <m-m-button
              variant="outlined"
              cy="button-discard"
              @click="onDiscard"
            >
              Discard
            </m-m-button>
          </template>
          <m-m-button
            v-else
            variant="outlined"
            prepend-icon="pencil"
            cy="edit-policy-type-button"
            :is-disabled="isButtonEditDisabled"
            @click="setMode('edit')"
          >
            Edit
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
          <m-m-dropdown
            :items="mainHeaderDropdownItems"
            cy="policy-type-dropdown"
            max-width="218px"
          /></div></template
    ></m-m-page-header>

    <m-m-teleport to="common-page-layout-header-tabs">
      <m-m-tabs
        v-model="activeTab"
        :items="TABS"
        :is-in-edit-mode="isEditing"
      />
    </m-m-teleport>
    <m-m-tab-items :current-tab="activeTab" :class="scrimmedClass">
      <m-m-tab-item keep-alive :name="TABS[0].name">
        <SettingsTab
          ref="settingsTabRef"
          v-bind="settingsTabProps"
          :active-category-name="activeCategoryName"
          :is-basic-info-open="isBasicInfoOpen"
          @update-child-policy-types-for-removal="updateChildPolicyTypeRemoval"
          @update-is-removing-policy-status="handlePolicyRemoval"
          @update-prepared-child-policies="handlePreparedChildPolicies"
          @update:form="updateForm($event)"
          @update-prepared-filters="handlePreparedFilters"
          @update-is-removing-filter-status="handleFilterRemoval"
          @update-filters-for-removal="updateFiltersForRemoval"
          @update:basic-info-open="updateIsBasicInfoOpen"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[1].name">
        <tab-related-items
          v-if="policyType || isCreating"
          :is-loading="isLoading"
          :active-category-name="activeCategoryName"
          :parent-policy-type="policyType"
          :service-provider-id="serviceProviderId"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[2].name">
        <tab-accounts
          v-if="(policyType || isCreating) && serviceProviderId"
          :policy-id="policyType?.id"
          :policy-name="policyType?.external_facing_name"
          :service-provider-id="serviceProviderId"
          :active-category-name="activeCategoryName"
          :is-policy-published="policyType?.published"
        />
      </m-m-tab-item>
      <m-m-tab-item :name="TABS[3].name">
        <tab-users
          v-if="(policyType || isCreating) && serviceProviderId"
          :policy-id="policyType?.id"
          :policy-name="policyType?.external_facing_name"
          :service-provider-id="serviceProviderId"
          :active-category-name="activeCategoryName"
          :is-policy-published="policyType?.published"
        />
      </m-m-tab-item>
    </m-m-tab-items>
    <m-m-dialog
      :is-open="isConfirmDeleteDialogOpen"
      :title="`Delete ${policyType?.name}?`"
      icon="trash"
      subtitle="Are you sure you want to delete this policy?"
      cy="confirm-delete-policy-type"
      @close="toggleConfirmDelete"
    >
      <template #footer>
        <m-m-button
          variant="outlined"
          data-cy="button-cancel-delete-policy-type"
          @click="toggleConfirmDelete"
        >
          Cancel
        </m-m-button>
        <m-m-button
          variant="danger"
          data-cy="button-confirm-delete-policy-type"
          @click="onDeleteButtonClick"
        >
          Yes, Delete
        </m-m-button>
      </template>
    </m-m-dialog>
  </template>

  <m-m-dialog-unsaved-changes
    :is-open="isDialogUnsavedChangesOpen"
    @cancel="onCancelDialogUnsavedChanges"
    @submit="onSubmitDialogUnsavedChanges"
    @update-do-not-show-next-time="updateDoNotShowNextTime"
  />
</template>
