<script setup lang="ts">
import { PropType, Ref, onMounted, ref } from "vue";
import { authService } from "~/auth/auth.service";
import {
  ServiceProviderOrganizationRead,
  ServiceProviderOrganizationUserRead,
} from "~/iam/iam.types";
import { TableResponse } from "~/mm_ui_kit/src/types/table.types";
import { PolicyRead } from "~/service-providers/Policies/policies.types";
import Policies from "./Policies.vue";
import Roles from "./Roles.vue";
const props = defineProps({
  policies: {
    type: Object as PropType<TableResponse<PolicyRead>>,
    default: () => ({}),
  },
  roles: {
    type: Object as PropType<TableResponse<PolicyRead>>,
    default: () => ({}),
  },
  organizationId: {
    type: String,
    required: true,
  },
  customer: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    default: () => ({}),
  },
  user: {
    type: Object as PropType<ServiceProviderOrganizationUserRead>,
    default: () => ({}),
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  rolePolicyTypeCategoryId: {
    type: String,
    required: true,
  },
  policyTypeCategoryId: {
    type: String,
    required: true,
  },
});
const emit = defineEmits(["updatePolicies", "updateRoles"]);
const serviceProviderId: Ref<string> = ref("");
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  isSPAdmin.value = (await authService.isUserSPAdmin()) === true;
  isSPEditor.value = (await authService.isUserSPEditor()) === true;
});
</script>

<template>
  <Policies
    :policy-type-category-id="policyTypeCategoryId"
    :is-loading="isLoading"
    :policies="policies || []"
    :customer="customer"
    :user="user"
    :organization-id="props.organizationId"
    @update-policies="emit('updatePolicies')"
  />
  <Roles
    :role-policy-type-category-id="rolePolicyTypeCategoryId"
    :is-loading="isLoading"
    :roles="roles || []"
    :customer="customer"
    :user="user"
    :organization-id="props.organizationId"
    @update-roles="emit('updateRoles')"
  />
</template>

<style scoped lang="scss"></style>
