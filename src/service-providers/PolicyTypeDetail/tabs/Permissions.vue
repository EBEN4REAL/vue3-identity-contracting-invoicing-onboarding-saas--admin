<script setup lang="ts">
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  PermissionRead,
  PermissionReadForSelect,
  TypePermissionToDelete,
} from "~/service-providers/Permissions/permissions.type";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import {
  computed,
  ComputedRef,
  onMounted,
  PropType,
  reactive,
  ref,
  Ref,
  watch,
} from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { usePermissionsStore } from "~/service-providers/Permissions/permissions.service";
import { useRoute } from "vue-router";
import { PolicyTypePermissionRead } from "~/service-providers/ConfigurationTabs/Policies/policies.types";
import DialogDeletePermission from "~/service-providers/PolicyTypeDetail/dialogs/DialogDeletePermission.vue";
import { PolicyTypeDetailMode } from "~/service-providers/PolicyTypeDetail/policyTypeDetail.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import Multiselect from "vue-multiselect";

const props = defineProps({
  mode: {
    type: String as PropType<PolicyTypeDetailMode>,
    default: null,
  },
});

const route = useRoute();

const permissionsStore = usePermissionsStore();

const permissionsResponse: Ref<PolicyTypePermissionRead[]> = ref([]);
const tableRowsInitial: Ref<PermissionRead[]> = ref([]);
const tableRows: Ref<PermissionRead[]> = ref([]);
const isTableLoading: Ref<boolean> = ref(true);
const isDialogDeletePermissionOpen: Ref<boolean> = ref(false);
const itemToDelete: TypePermissionToDelete = reactive({
  id: null,
  name: null,
});
const isButtonDeletePermissionsDisabled: Ref<boolean> = ref(false);
const isButtonDeletePermissionsLoading: Ref<boolean> = ref(false);
const isButtonAppendPermissionToTableLoading: Ref<boolean> = ref(false);
const isButtonAppendPermissionToTableDisabled: Ref<boolean> = ref(true);
const isPermissionsForAutocompleteLoading: Ref<boolean> = ref(false);
const isButtonAddPermissionDisabled: Ref<boolean> = ref(false);
const isButtonAddPermissionLoading: Ref<boolean> = ref(false);
const addPermissionButtonValue: Ref<string | null> = ref(null);
const permissionSelectedValue: Ref<PermissionRead | null> = ref(null);
const permissionSearchQueryValue: Ref<string | null> = ref(null);
const permissionsForAutocomplete: Ref<TableResponse<PermissionRead> | null> =
  ref(null);
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);
const emptyStatePermissions: string = "No permissions";
const tableHeaders: TableHeader[] = [
  {
    label: "Name",
    key: "name",
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "",
    key: "actions",
  },
];
const description =
  "Add permissions which will be returned as part of the identity when this policy applies.";
const assignedPermissionsIds: ComputedRef<string[]> = computed(() => [
  ...permissionsResponse.value.map(
    (permission: PolicyTypePermissionRead) => permission.entitlement_id,
  ),
  ...policyTypesService.getPermissionsSelectedIds,
]);

const isCreating: ComputedRef<boolean> = computed(
  () => props.mode === "create",
);

const isEditing: ComputedRef<boolean> = computed(() => props.mode === "edit");

const isCreatingOrEditing: ComputedRef<boolean> = computed(
  () => isCreating.value || isEditing.value,
);

const permissionsForAutocompleteItems: ComputedRef<PermissionReadForSelect[]> =
  computed(() =>
    permissionsForAutocomplete.value
      ? permissionsForAutocomplete.value?.results.map((permission) => ({
          ...permission,
          $isDisabled: tableRows.value.some(
            (assignedPermission) => assignedPermission.id === permission.id,
          ),
        }))
      : [],
  );

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(addPermissionButtonValue.value) &&
    !permissionsForAutocompleteItems.value.find(
      (permission) => permission.name === addPermissionButtonValue.value,
    ),
);

const permissionsTotalItems: ComputedRef<number> = computed(
  () => permissionsForAutocomplete.value?.total || 0,
);

const createPermissionButtonText: ComputedRef<string> = computed(
  () => `Add ${permissionSearchQueryValue.value}`,
);

const tableRowActionsDropdownItems = (
  permission: PermissionRead,
): TypeDropdownItem[] => [
  {
    label: "Delete",
    type: "button",
    color: "error",
    onClick: () => {
      onDialogDeletePermissionOpen(permission);
    },
  },
];

const onDialogDeletePermissionOpen = (permission: PermissionRead) => {
  itemToDelete.id = permission.id;
  itemToDelete.name = permission.name;
  isDialogDeletePermissionOpen.value = true;
};

const onDialogDeletePermissionClose = () => {
  isDialogDeletePermissionOpen.value = false;
};

const fetchPermissions = async () => {
  if (isCreating.value) {
    isTableLoading.value = false;
    return;
  }

  try {
    isTableLoading.value = true;

    permissionsResponse.value = await policyTypesService.fetchPermissions(
      route.params.service_provider_id as string,
      route.params.policy_type_id as string,
    );

    const permissionsByIdsResponse: PromiseSettledResult<PermissionRead>[] =
      await Promise.allSettled(
        assignedPermissionsIds.value.map((id) => fetchPermission(id)),
      );

    tableRowsInitial.value = permissionsByIdsResponse.map(
      (permissionPromiseResult: PromiseSettledResult<PermissionRead>) => {
        const defaultPermissionRead = {
          id: "-",
          name: "-",
          description: "-",
          service_provider_id: "-",
        };
        switch (permissionPromiseResult.status) {
          case "fulfilled":
            return permissionPromiseResult.value;
          case "rejected":
            return defaultPermissionRead;
          default:
            return defaultPermissionRead;
        }
      },
    );

    tableRows.value = tableRowsInitial.value;
  } finally {
    isTableLoading.value = false;
  }
};

const fetchPermission = async (id: string) =>
  permissionsStore.fetchPermission(
    route.params.service_provider_id as string,
    id,
  );

const onAppendPermissionToTable = async () => {
  if (!permissionSelectedValue.value) return;
  try {
    isButtonAppendPermissionToTableDisabled.value = true;
    isButtonAppendPermissionToTableLoading.value = true;

    const permission = await fetchPermission(permissionSelectedValue.value.id);
    policyTypesService.state.permissionsSelected.push(permission);
    tableRows.value = Array.from(
      new Set([
        ...tableRows.value,
        ...policyTypesService.state.permissionsSelected,
      ]),
    );
    permissionSelectedValue.value = null;
    permissionSearchQueryValue.value = null;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error appending permission to table",
      status: "error",
    });
  } finally {
    isButtonAppendPermissionToTableDisabled.value = false;
    isButtonAppendPermissionToTableLoading.value = false;
  }
};

const deletePermission = async () => {
  if (!itemToDelete.id) return;

  const localPermissionItemId =
    policyTypesService.getPermissionsSelectedIds.find(
      (permissionId) => permissionId === itemToDelete.id,
    );

  if (localPermissionItemId) {
    policyTypesService.state.permissionsSelected =
      policyTypesService.state.permissionsSelected.filter(
        (permission) => permission.id !== localPermissionItemId,
      );

    tableRows.value = tableRows.value.filter(
      (permission) => permission.id !== localPermissionItemId,
    );

    onDialogDeletePermissionClose();

    return;
  }

  try {
    isButtonDeletePermissionsDisabled.value = true;
    isButtonDeletePermissionsLoading.value = true;
    await policyTypesService.deletePermission(
      route.params.service_provider_id as string,
      route.params.policy_type_id as string,
      itemToDelete.id,
    );
    onDialogDeletePermissionClose();
    await fetchPermissions();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting permission",
      status: "error",
    });
  } finally {
    isButtonDeletePermissionsDisabled.value = false;
    isButtonDeletePermissionsLoading.value = false;
  }
};

const fetchPermissionsForAutocomplete = async (params: TableRequestParams) => {
  try {
    isPermissionsForAutocompleteLoading.value = true;
    permissionsForAutocomplete.value = await permissionsStore.fetchPermissions(
      route.params.service_provider_id as string,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching permission",
      status: "error",
    });
  } finally {
    isPermissionsForAutocompleteLoading.value = false;
    addPermissionButtonValue.value = permissionSearchQueryValue.value;
  }
};

const onAddPermission = async () => {
  if (!permissionSearchQueryValue.value) return;
  try {
    isButtonAddPermissionDisabled.value = true;
    isButtonAddPermissionLoading.value = true;
    permissionSelectedValue.value = await permissionsStore.createPermission(
      route.params.service_provider_id as string,
      {
        name: permissionSearchQueryValue.value,
      },
    );
    multiselectRef.value?.closeMultiselect();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error adding permission",
      status: "error",
    });
  } finally {
    isButtonAddPermissionDisabled.value = false;
    isButtonAddPermissionLoading.value = false;
  }
};

const onSearchChange = (value: string) => {
  permissionSearchQueryValue.value = value;
};

watch(
  () => props.mode,
  () => {
    if (props.mode === "view") {
      tableRows.value = tableRowsInitial.value;
      policyTypesService.state.permissionsSelected = [];
    }
  },
);

watch(
  () => permissionSelectedValue.value,
  () => {
    isButtonAppendPermissionToTableDisabled.value = !Boolean(
      permissionSelectedValue.value,
    );
  },
);

onMounted(() => {
  eventBus.$on("fetchPermissions", async () => {
    await fetchPermissions();
  });
});
</script>

<template>
  <div class="form-container">
    <m-m-table
      :is-loading="isTableLoading"
      :headers="tableHeaders"
      :rows="tableRows"
      hide-empty-state-title
      cy="table-permissions"
      :empty-state="emptyStatePermissions"
      :description="description"
      @update-params="fetchPermissions"
    >
      <template v-if="isCreatingOrEditing" #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :cy="`actions-dropdown-${row.id}`"
            :items="tableRowActionsDropdownItems(row)"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="text"
                :cy="`actions-${row.id}`"
              />
            </template>
          </m-m-dropdown>
        </div>
      </template>
    </m-m-table>

    <div
      v-if="isCreatingOrEditing"
      class="mm-flex mm-flex-row mm-flex-gap-16 mm-mt-16 form-container-row"
    >
      <div
        class="mm-flex mm-w-5 form-container-field-wrapper form-container-row"
      >
        <m-m-multiselect
          ref="multiselectRef"
          v-model="permissionSelectedValue"
          :options="permissionsForAutocompleteItems"
          :loading="isPermissionsForAutocompleteLoading"
          :total="permissionsTotalItems"
          placeholder="Search permission"
          label="Search & add permission"
          item-title="name"
          item-value="id"
          searchable
          class="mm-flex-grow form-container-field-wrapper"
          @search-change="onSearchChange"
          @update-params="fetchPermissionsForAutocomplete"
        >
          <template v-if="isAfterListContentVisible" #afterListContent>
            <m-m-button
              :loading="isButtonAddPermissionLoading"
              :is-disabled="isButtonAddPermissionDisabled"
              @click="onAddPermission"
            >
              {{ createPermissionButtonText }}
            </m-m-button>
          </template>
        </m-m-multiselect>
        <m-m-button
          :is-disabled="isButtonAppendPermissionToTableDisabled"
          :loading="isButtonAppendPermissionToTableLoading"
          variant="elevated"
          prepend-icon="plus-white"
          class="mm-mb-auto mm-mt-14 mm-ml-8 form-container-field-wrapper add-btn"
          @click="onAppendPermissionToTable"
        >
          Add
        </m-m-button>
      </div>
      <div class="mm-w-5 form-container-field-wrapper">
        <m-m-link
          :href="`/sp/${route.params.service_provider_id}/permissions`"
          target="_blank"
          text-align="left"
          color="primary"
          font-size="16px"
          class="mm-mt-17 cta"
        >
          <m-m-icon icon="settings" stroke="#072E51" class="mm-mr-2" />
          Manage permissions
        </m-m-link>
      </div>
    </div>
  </div>

  <dialog-delete-permission
    v-if="itemToDelete.name"
    :is-open="isDialogDeletePermissionOpen"
    :name="itemToDelete.name"
    :is-confirm-delete-button-submit-disabled="
      isButtonDeletePermissionsDisabled
    "
    :is-confirm-delete-button-submit-loading="isButtonDeletePermissionsLoading"
    @submit="deletePermission"
    @close="onDialogDeletePermissionClose"
  />
</template>

<style scoped lang="scss">
@media (max-width: $breakpoint-xs) {
  .form-container {
    &-row {
      width: 100%;
      display: block;
    }
    &-field-wrapper {
      width: 100%;
      margin-bottom: 20px;
      &.add-btn {
        margin: 0;
      }
      .cta {
        margin: 0;
      }
    }
  }
}
.form-container {
  width: calc(100% - 50px);
  margin: 20px 0;
}
</style>
