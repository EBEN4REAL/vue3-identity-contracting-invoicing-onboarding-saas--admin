<script setup lang="ts">
import {
  ComponentPublicInstance,
  computed,
  ComputedRef,
  nextTick,
  onMounted,
  ref,
  Ref,
  watch,
} from "vue";
import { helpers, maxLength, required } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { Role, RoleValidationRules } from "./types";
import { useRolesStore } from "~/service-providers/Roles/roles.service";
import { usePermissionsStore } from "~/service-providers/Permissions/permissions.service";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { RoleRead } from "~/service-providers/Roles/roles.type";
import { authService } from "~/auth/auth.service";
import { PermissionRead } from "~/service-providers/Permissions/permissions.type";
import { useApplicationRoleBasedConfigStore } from "~/stores/useApplicationRoleBasedConfigStore";
import Multiselect from "~/components-library/modules/Multiselect.vue";
import { debounce } from "lodash";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";
import { TypeToastStatuses } from "~/mm_ui_kit/src/types/toast.types";

const permissionsStore = usePermissionsStore();
const rolesStore = useRolesStore();
const applicationRoleBasedConfigStore = useApplicationRoleBasedConfigStore();

const isRolesLoading: Ref<boolean> = ref(false);
const isRoleMultiselectDeactivated: Ref<boolean> = ref(false);
const isDuplicateRoleOrPermission: Ref<boolean> = ref(false);
const isPermissionsLoading: Ref<boolean> = ref(false);
const serviceProviderId: Ref<string> = ref("");
const roleItems: Ref<TableResponse<RoleRead> | null> = ref(null);
const searchQueryRoleValue: Ref<string | null> = ref(null);
const isCreatingRole: Ref<boolean> = ref(false);
const isCreatingPermission: Ref<boolean> = ref(false);
const addRoleButtonValue: Ref<string | null> = ref(null);
const roleMultiselectRefs = ref<Array<InstanceType<typeof Multiselect> | null>>(
  [],
);
const permissionMultiselectRefs = ref<
  Array<Array<InstanceType<typeof Multiselect> | null>>
>([]);

const permissions: Ref<TableResponse<PermissionRead> | null> = ref(null);

const selectedRoles: ComputedRef<string[]> = computed(() =>
  applicationRoleBasedConfigStore.roles.map((role) => role.name),
);

const isRolesAndPermissionsValid: ComputedRef<boolean> = computed(() =>
  applicationRoleBasedConfigStore.roles.every(
    (role) =>
      role.name &&
      role.permissions.every((permission) => permission?.name?.name),
  ),
);

const getPermissionsForAutocomplete: ComputedRef<
  (role: Role) => PermissionRead[]
> = computed(() => {
  return (role: Role): PermissionRead[] => {
    const rolePermissionNames = role.permissions.map((p) => p.name.name);

    return (permissions.value?.results || []).map((permission) => ({
      ...permission,
      $isDisabled: rolePermissionNames.includes(permission.name),
    }));
  };
});

const isButtonAddRoleVisible: ComputedRef<boolean[]> = computed(() =>
  applicationRoleBasedConfigStore.roles.map(
    (role) =>
      Boolean(role.searchQuery) && roleItems.value?.results.length === 0,
  ),
);

const isButtonAddPermissionVisible = (
  roleIndex: number,
  permissionIndex: number,
): boolean => {
  return (
    Boolean(
      applicationRoleBasedConfigStore.roles[roleIndex].permissions[
        permissionIndex
      ].searchQuery,
    ) && permissions.value?.results.length === 0
  );
};

const roleValidationRules: ComputedRef<{ roles: RoleValidationRules[] }> =
  computed(() => ({
    roles: applicationRoleBasedConfigStore.roles.map(() => ({
      searchQuery: {
        required: helpers.withMessage("Role name is required", required),
        maxLength: helpers.withMessage("Role name is too long", maxLength(64)),
        role: helpers.withMessage(
          "Please enter a name that only contains lowercase letters (a-z), numbers (0-9), underscores (_), or colons (:).",
          helpers.regex(/^[a-z0-9_:]+$/),
        ),
      },
    })),
  }));

const permissionValidationRules: ComputedRef<{
  permissions: Record<string, unknown>;
}> = computed(() => {
  const rules: Record<string, unknown> = {};
  applicationRoleBasedConfigStore.roles.forEach((role, roleIndex) => {
    role.permissions.forEach((_, permissionIndex) => {
      const key = `${roleIndex}-${permissionIndex}`;
      rules[key] = {
        searchQuery: {
          required: helpers.withMessage("Permission is required", required),
          maxLength: helpers.withMessage(
            "Permission name is too long",
            maxLength(64),
          ),
          permission: helpers.withMessage(
            "Please enter a name that only contains lowercase letters (a-z), numbers (0-9), underscores (_), or colons (:).",
            helpers.regex(/^[a-z0-9_:]+$/),
          ),
        },
      };
    });
  });
  return { permissions: rules };
});

const $vRoles = useVuelidate(
  roleValidationRules,
  computed(() => ({
    roles: applicationRoleBasedConfigStore.roles,
  })),
);

const $vPermissions = useVuelidate(
  permissionValidationRules,
  computed(() => {
    const perms: Record<string, unknown> = {};
    applicationRoleBasedConfigStore.roles.forEach((role, roleIndex) => {
      role.permissions.forEach((permission, permissionIndex) => {
        const key = `${roleIndex}-${permissionIndex}`;
        perms[key] = permission;
      });
    });
    return { permissions: perms };
  }),
);

const createRoleButtonText = (roleName: string): string =>
  `Add role "${roleName}"`;

const createPermissionButtonText = (permissionName: string): string =>
  `Add permission "${permissionName}"`;

const addRole = () => {
  applicationRoleBasedConfigStore.roles.push({
    id: crypto.randomUUID(),
    name: "",
    permissions: [],
    searchQuery: "",
  });
  $vRoles.value.$touch();
};

const removeRole = (index: number) => {
  if (applicationRoleBasedConfigStore.roles.length > 1) {
    applicationRoleBasedConfigStore.roles =
      applicationRoleBasedConfigStore.roles.filter(
        (role) => role.id !== applicationRoleBasedConfigStore.roles[index].id,
      );
    $vRoles.value.$touch();
  }
};

const addPermission = debounce((role: Role) => {
  const roleObj = applicationRoleBasedConfigStore.getRoleById(role.id);
  if (roleObj) {
    roleObj.permissions.push({
      id: crypto.randomUUID(),
      name: "",
      searchQuery: "",
    });
  }
  $vPermissions.value.$touch();
}, 100);

const removePermission = (role: Role, permissionIndex: number) => {
  const roleObj = applicationRoleBasedConfigStore.getRoleById(role.id);
  if (roleObj) {
    roleObj.permissions = role.permissions.filter(
      (permission) => permission.id !== role.permissions[permissionIndex].id,
    );
  }
  $vPermissions.value.$touch();
};

const fetchPermissions = async (params: TableRequestParams) => {
  if (!serviceProviderId.value) return;
  try {
    isPermissionsLoading.value = true;
    permissions.value = await permissionsStore.fetchPermissions(
      serviceProviderId.value,
      params,
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "An error occured when fetching permisisons",
      status: "error",
    });
  } finally {
    isPermissionsLoading.value = false;
  }
};

const rolesTotal: ComputedRef<number> = computed(
  () => roleItems.value?.total || 0,
);

const permisisonsTotal: ComputedRef<number> = computed(
  () => permissions.value?.total || 0,
);

const fetchRoles = async (params: TableRequestParams) => {
  if (!serviceProviderId.value) return;
  try {
    isRolesLoading.value = true;
    roleItems.value = await rolesStore.fetchRoles(
      serviceProviderId.value,
      params,
    );
  } finally {
    isRolesLoading.value = false;
    addRoleButtonValue.value = searchQueryRoleValue.value;
  }
};

const showErrorToast = (error: unknown, entity: string) => {
  if (error?.response?.status === 409) {
    eventBus.$emit("onShowToast", {
      text: `${entity} with this name already exists`,
      status: "error",
    });
  } else if (error?.response?.status === 422) {
    eventBus.$emit("onShowToast", {
      text: `Please enter a ${entity} that only contains lowercase letters (a-z), numbers (0-9), underscores (_), or colons (:).`,
      status: "error",
    });
  } else {
    eventBus.$emit("onShowToast", {
      text: `An error occurred while fetching ${entity}`,
      status: "error",
    });
  }
};

const onCreateRoleForOIDC = async (roleIndex: number) => {
  try {
    const query = applicationRoleBasedConfigStore.roles[roleIndex].searchQuery;
    const roleId = crypto.randomUUID();
    applicationRoleBasedConfigStore.roles[roleIndex].id = roleId;
    applicationRoleBasedConfigStore.roles[roleIndex].name = {
      id: roleId,
      name: query,
    };
    applicationRoleBasedConfigStore.roles[roleIndex].searchQuery = query;
    deactivateRoleMultiselect(roleIndex);
    $vRoles.value?.roles?.[roleIndex]?.searchQuery?.$validate();
  } catch (error) {
    showErrorToast(error, "role");
  } finally {
  }
};

const onCreatePermissionForOIDC = async (
  roleIndex: number,
  permissionIndex: number,
) => {
  try {
    const permissionId = crypto.randomUUID();
    const permissionName =
      applicationRoleBasedConfigStore.roles[roleIndex].permissions[
        permissionIndex
      ].searchQuery;
    applicationRoleBasedConfigStore.roles[roleIndex].permissions[
      permissionIndex
    ].name = {
      ...applicationRoleBasedConfigStore.roles[roleIndex].permissions[
        permissionIndex
      ],
      name: permissionName,
      id: permissionId,
      searchQuery: permissionName,
    };
    applicationRoleBasedConfigStore.roles[roleIndex].permissions[
      permissionIndex
    ].searchQuery = permissionName;
    deactivatePermissionMultiselect(roleIndex, permissionIndex);
  } catch (error) {
    showErrorToast(error, "permission");
  } finally {
    isCreatingPermission.value = false;
  }
};

const getUserProfile = async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
};

const disabledRoleOptions: ComputedRef<string[]> = computed(() =>
  selectedRoles.value.map((role) => role.name),
);

const formattedOptions: ComputedRef<Role[]> = computed(() => {
  return (roleItems.value?.results || []).map((option) => ({
    ...option,
    $isDisabled: disabledRoleOptions.value.includes(option.name),
  }));
});

const isButtonCreateRoleDisabled = (roleIndex: number) =>
  $vRoles.value?.roles?.[roleIndex]?.searchQuery?.$errors?.length ||
  isCreatingRole.value;

const isButtonCreatePermissionDisabled = (
  roleIndex: number,
  permissionIndex: number,
) =>
  $vPermissions.value?.permissions?.[`${roleIndex}-${permissionIndex}`]
    ?.searchQuery?.$errors.length || isCreatingPermission.value;

const setRoleQuery = (roleIndex: number, query: string) => {
  isRoleMultiselectDeactivated.value = false;
  if (roleIndex >= 0) {
    applicationRoleBasedConfigStore.roles[roleIndex].searchQuery = query;
    $vRoles.value?.roles?.[roleIndex]?.searchQuery?.$touch();
    if ($vRoles.value?.roles?.[roleIndex]?.searchQuery?.$errors?.length) {
      const errorMessage = $vRoles.value?.roles?.[
        roleIndex
      ]?.searchQuery?.$errors
        .map(
          (error: { $validator: string; $message: string }) => error.$message,
        )
        .join("\n");

      showToast({
        text: errorMessage,
        status: TypeToastStatuses.Warning,
        duration: 4000,
      });
    }
  }
};

const setPermissionQuery = (
  roleIndex: number,
  permissionIndex: number,
  query: string,
) => {
  if (roleIndex >= 0 && permissionIndex >= 0) {
    applicationRoleBasedConfigStore.roles[roleIndex].permissions[
      permissionIndex
    ].searchQuery = query;

    $vPermissions.value?.permissions?.[
      `${roleIndex}-${permissionIndex}`
    ]?.searchQuery?.$touch();

    nextTick(() => {
      const validationErrors =
        $vPermissions.value?.permissions?.[`${roleIndex}-${permissionIndex}`]
          ?.searchQuery?.$errors;

      if (validationErrors?.length) {
        const errorMessage = validationErrors
          .map(
            (error: { $validator: string; $message: string }) => error.$message,
          )
          .join("\n");

        showToast({
          text: errorMessage,
          status: TypeToastStatuses.Warning,
          duration: 4000,
        });
      }
    });
  }
};

const deactivateRoleMultiselect = (itemIndex: number) => {
  roleMultiselectRefs.value[itemIndex]?.multiselectRef.deactivate();
  isRoleMultiselectDeactivated.value = true;
};

const deactivatePermissionMultiselect = (
  roleIndex: number,
  permissionIndex: number,
) => {
  permissionMultiselectRefs.value[roleIndex]?.[
    permissionIndex
  ]?.multiselectRef?.deactivate?.();
};

const setRoleMultiselectRef = (
  el: InstanceType<typeof Multiselect> | null,
  roleIndex: number,
) => {
  roleMultiselectRefs.value[roleIndex] = el;
};

const setPermissionMultiselectRef = (
  el: InstanceType<typeof Multiselect> | null,
  roleIndex: number,
  permissionIndex: number,
) => {
  if (!permissionMultiselectRefs.value[roleIndex]) {
    permissionMultiselectRefs.value[roleIndex] = [];
  }
  permissionMultiselectRefs.value[roleIndex][permissionIndex] = el;
};

const onRoleMultiselectClickOutside = (roleIndex: number) => {
  const role = applicationRoleBasedConfigStore.roles[roleIndex];
  if (!role.searchQuery?.trim() && role.name?.name?.trim()) {
    role.searchQuery = role.name.name;
    $vRoles.value?.roles?.[roleIndex]?.searchQuery?.$touch();
  }
};

const onPermissionMultiselectClickOutside = (
  roleIndex: number,
  permissionIndex: number,
) => {
  const permission =
    applicationRoleBasedConfigStore.roles[roleIndex].permissions[
      permissionIndex
    ];
  const searchQuery = permission.searchQuery?.trim();
  const permissionName = permission.name?.name?.trim();

  if (!searchQuery && permissionName) {
    permission.searchQuery = permissionName;
    $vPermissions.value?.permissions?.[
      `${roleIndex}-${permissionIndex}`
    ]?.searchQuery?.$touch();
  }
};

const makeRoleRef =
  (roleIndex: number) => (el: Element | ComponentPublicInstance | null) =>
    setRoleMultiselectRef(el as InstanceType<typeof Multiselect>, roleIndex);

const makePermissionRef =
  (roleIndex: number, permissionIndex: number) =>
  (el: Element | ComponentPublicInstance | null) =>
    setPermissionMultiselectRef(
      el as InstanceType<typeof Multiselect>,
      roleIndex,
      permissionIndex,
    );

watch(
  () => applicationRoleBasedConfigStore.roles,
  (newRoles) => {
    if (!newRoles || newRoles.length === 0) return;

    const roleNames = new Set<string>();
    let duplicateRole = "";

    for (const role of newRoles) {
      // Check for duplicate role name
      if (roleNames.has(role.name.name)) {
        duplicateRole = role.searchQuery;
        break;
      }
      roleNames.add(role.searchQuery);
    }

    nextTick(() => {
      if (duplicateRole && isRoleMultiselectDeactivated.value) {
        showToast({
          text: `Duplicate role name found: "${duplicateRole}". Roles should be unique`,
          status: TypeToastStatuses.Warning,
          duration: 4000,
        });
        isDuplicateRoleOrPermission.value = true;
      } else {
        isDuplicateRoleOrPermission.value = false;
      }
    });
  },
  { deep: true },
);

onMounted(async () => {
  await getUserProfile();
  await fetchPermissions({ limit: "10", offset: "0" });
  await fetchRoles({ limit: "10", offset: "0" });
});

defineExpose({
  isRolesAndPermissionsValid,
  isDuplicateRoleOrPermission,
});
</script>

<template>
  <div
    class="mm-flex mm-flex-column mm-flex-gap-3 mm-w-5 mm-application-wizard"
  >
    <div
      v-for="(role, roleIndex) in applicationRoleBasedConfigStore.$state.roles"
      :key="role.id"
      class="role-container mm-mt-3 mm-pa-10"
    >
      <div class="mm-config-wizard-label mm-mt-10">Role</div>
      <div
        class="mm-flex mm-flex-align-center mm-flex-justify-between mm-flex-gap-3"
      >
        <m-m-multiselect
          :ref="makeRoleRef(roleIndex)"
          v-model="role.name"
          v-mm-click-outside="onRoleMultiselectClickOutside(roleIndex)"
          :options="formattedOptions"
          :total="rolesTotal"
          item-title="name"
          item-value="name"
          class="mm-w-10"
          :errors="$vRoles?.roles?.[roleIndex]?.searchQuery?.$errors"
          searchable
          @search-change="setRoleQuery(roleIndex, $event)"
          @update-params="fetchRoles"
        >
          <template v-if="isButtonAddRoleVisible[roleIndex]" #afterListContent>
            <m-m-button
              :is-disabled="isButtonCreateRoleDisabled(roleIndex)"
              :loading="isCreatingRole"
              @click="onCreateRoleForOIDC(roleIndex)"
            >
              {{ createRoleButtonText(role.searchQuery) }}
            </m-m-button>
          </template>
        </m-m-multiselect>
        <m-m-icon
          v-if="applicationRoleBasedConfigStore.roles.length > 1"
          icon="trash2"
          class="mm-cursor-pointer"
          @click="removeRole(roleIndex)"
        />
      </div>
      <div class="mm-ml-10">
        <div
          v-if="role.permissions.length"
          class="mm-config-wizard-label mm-mt-10"
        >
          Permissions
        </div>
        <div
          v-for="(permission, permissionIndex) in role.permissions"
          :key="permission.id"
          class="mm-flex mm-flex-align-center mm-flex-gap-3 mm-mt-3"
        >
          <m-m-multiselect
            :ref="makePermissionRef(roleIndex, permissionIndex)"
            v-model="permission.name"
            v-mm-click-outside="
              onPermissionMultiselectClickOutside(roleIndex, permissionIndex)
            "
            :options="getPermissionsForAutocomplete(role)"
            :total="permisisonsTotal"
            :errors="
              $vPermissions?.permissions?.[`${roleIndex}-${permissionIndex}`]
                ?.searchQuery?.$errors
            "
            item-title="name"
            class="mm-w-10"
            item-value="id"
            searchable
            @search-change="
              setPermissionQuery(roleIndex, permissionIndex, $event)
            "
            @update-params="fetchPermissions"
          >
            <template
              v-if="isButtonAddPermissionVisible(roleIndex, permissionIndex)"
              #afterListContent
            >
              <m-m-button
                :loading="isCreatingPermission"
                :is-disabled="
                  isButtonCreatePermissionDisabled(roleIndex, permissionIndex)
                "
                @click="onCreatePermissionForOIDC(roleIndex, permissionIndex)"
              >
                {{ createPermissionButtonText(permission.searchQuery) }}
              </m-m-button>
            </template>
          </m-m-multiselect>
          <m-m-icon
            icon="trash2"
            class="mm-cursor-pointer"
            @click="removePermission(role, permissionIndex)"
          />
        </div>
        <m-m-button
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-mt-6"
          @click="addPermission(role)"
        >
          Add permission
        </m-m-button>
      </div>
    </div>
  </div>
  <m-m-button
    size="small"
    variant="outlined"
    prepend-icon="plus"
    class="mm-mt-6"
    @click="addRole"
  >
    Add role
  </m-m-button>
</template>

<style lang="scss" scoped>
.mm-config-wizard-label {
  color: #384250;
  font-size: 14px;
  font-style: normal;
  font-weight: 500;
  line-height: 20px;
}
.role-container {
  border: 1px solid #e5e7eb;
  border-radius: 5px;
}
@media (max-width: $breakpoint-xs) {
  .mm-application-wizard {
    width: 100%;
  }
}
</style>
