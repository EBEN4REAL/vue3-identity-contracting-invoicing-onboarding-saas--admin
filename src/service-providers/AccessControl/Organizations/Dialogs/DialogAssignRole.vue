<script setup lang="ts">
import { computed, ComputedRef, onMounted, PropType, ref, Ref } from "vue";
import { PolicyTypeRead } from "~/policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { OrganizationRead } from "~/iam/iam.types";
import { policyTypesService } from "~/configuration/policy-types.service";
import { PolicyRead } from "~/service-providers/Policies/policies.types";

const props = defineProps({
  categoryId: {
    type: String,
    default: "",
  },
  customer: {
    type: Object as PropType<OrganizationRead>,
    default: () => ({}),
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  assignedRoles: {
    type: Array as PropType<PolicyRead[]>,
    default: () => [],
  },
});

const emit = defineEmits(["close-dialog", "update-roles"]);

const selectedRole: Ref<string> = ref("");
const roles: Ref<TableResponse<PolicyTypeRead> | null> = ref(null);
const isSubmitButtonLoading: Ref<boolean> = ref(false);
const isSubmitButtonDisabled = computed(
  () => isSubmitButtonLoading.value || selectedRole.value?.length == 0,
);
const isLoading: Ref<boolean> = ref(false);

const preparedRoles: ComputedRef<Array<PolicyRead & { disabled: boolean }>> =
  computed(() =>
    roles.value?.results?.map((roleItem: PolicyTypeRead) => ({
      ...roleItem,
      name: roleItem.external_facing_name,
      disabled: props.assignedRoles?.some(
        ({ type_id }) => type_id === roleItem.id,
      ),
    })),
  );
const getRoles = async (params?: TableRequestParams) => {
  try {
    isLoading.value = true;
    const result = await policyTypesService.getPolicyTypes(
      props.serviceProviderId,
      {
        category_id: props.categoryId,
        ...params,
      },
    );
    roles.value = result;
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching roles",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const selectRoleOptionClassList = (isDisabled: boolean) => [
  "mm-flex",
  "mm-flex-grow",
  isDisabled && "mm-opacity-50",
];

const handleUpdateAllRoles = (params?: TableRequestParams) => {
  emit("update-roles", params);
};

const onSubmit = async () => {
  try {
    isSubmitButtonLoading.value = true;
    await policiesService.assignPolicyToOrganization(props.serviceProviderId, {
      policy_type_id: selectedRole.value,
      organization_id: props.customer?.id,
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error assigning role",
      status: "error",
    });
  } finally {
    emit("update-roles");
    emit("close-dialog");
    isSubmitButtonLoading.value = false;
  }
};
onMounted(async () => await getRoles());
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Assign Roles"
    icon="shield-check-light"
    cy="dialog-assign-roles"
    @close="emit('close-dialog')"
  >
    <template #default>
      <div class="autocompletes-group">
        <m-m-autocomplete
          id="autocomplete-roles"
          v-model="selectedRole"
          :is-loading="isLoading"
          placeholder="Search role"
          label="Search & assign roles"
          cy="select-roles"
          icon-prepended="search-lg"
          clear-button="x-circle"
          :items="preparedRoles"
          :total-items="roles?.total"
          item-title="name"
          item-value="id"
          @update-params="handleUpdateAllRoles"
        >
          <template #option="{ item }">
            <div class="mm-flex mm-flex-justify-between mm-w-10">
              <div :class="selectRoleOptionClassList(item.disabled)">
                {{ item.external_facing_name }}
                <div
                  v-if="item.disabled"
                  class="mm-flex mm-flex-justify-between mm-flex-grow"
                >
                  <m-m-badge
                    class="mm-ml-3"
                    :status="BadgeTypes.Inactive"
                    text="Already added"
                    cy="badge-added"
                  />
                  <m-m-icon icon="check-thin-primary" width="12px" />
                </div>
              </div>
            </div>
          </template>
        </m-m-autocomplete>
      </div>
    </template>
    <template #footer>
      <m-m-button
        variant="outlined"
        min-width="100px"
        cy="button-cancel"
        @click="emit('close-dialog')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        :is-disabled="isSubmitButtonDisabled"
        :loading="isSubmitButtonLoading"
        cy="button-submit"
        @click="onSubmit"
      >
        Yes, Assign
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss">
.autocompletes-group {
  display: flex;
  flex-direction: column;
  gap: 30px;
}
</style>
