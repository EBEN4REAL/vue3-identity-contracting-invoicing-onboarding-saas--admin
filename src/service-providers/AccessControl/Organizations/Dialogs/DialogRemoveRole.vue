<script lang="ts" setup>
import { PropType, Ref, ref } from "vue";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { policiesService } from "~/service-providers/policies.service";
import { RoleRead } from "~/service-providers/Roles/roles.type";

const props = defineProps({
  role: {
    type: Object as PropType<RoleRead>,
    required: true,
    default: () => ({}),
  },
  account: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    required: true,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  policyTypeId: {
    type: String,
    required: true,
  },
});

const emit = defineEmits(["closeDialog", "updateRoles"]);
const isLoading: Ref<boolean> = ref(false);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");

const onDialogClose = () => {
  emit("closeDialog");
};

const unassignRole = async () => {
  try {
    isLoading.value = true;
    await policiesService.removePolicyFromOrganization(
      props.serviceProviderId,
      {
        policy_type_id: props.policyTypeId,
        organization_id: props.account.organization?.id,
      },
    );
    onDialogClose();
    emit("updateRoles");
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = error.response.data;
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Remove role"
    :subtitle="`Are you sure you want to remove the role ${role.name} assigned to ${account?.organization.name}?`"
    icon="trash"
    icon-color="error"
    cy="dialog-remove-role"
    @close="onDialogClose"
  >
    <m-m-alert
      v-if="isAlertVisible"
      status="error"
      cy="allocated-role-alert"
      class="mm-mb-12"
      @close="isAlertVisible = false"
    >
      {{ alertText }}
    </m-m-alert>
    <template #footer>
      <m-m-button
        variant="outlined"
        cy="button-cancel"
        min-width="100px"
        @click="onDialogClose"
        >No</m-m-button
      >
      <m-m-button
        variant="danger"
        cy="button-submit"
        :loading="isLoading"
        @click="unassignRole"
      >
        Yes, remove
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
