<script setup lang="ts">
import { PropType, Ref, ref } from "vue";
import { PolicyRead } from "~/service-providers/Policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  orgName: {
    type: String,
    required: true,
  },
  userId: {
    type: String,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  policy: {
    type: Object as PropType<PolicyRead>,
    default: () => {},
  },
});

const emit = defineEmits(["closeDialog", "updatePolicies"]);
const isLoading: Ref<boolean> = ref(false);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");

const removePolicy = async () => {
  try {
    isLoading.value = true;
    await policiesService.removePolicyFromOrganization(
      props.serviceProviderId,
      {
        policy_type_id: props.policy.type_id,
        organization_id: props.userId,
      },
    );
    onDialogClose();
    emit("updatePolicies");
    isLoading.value = false;
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = error.response.data;
    isLoading.value = false;
  }
};

const onDialogClose = () => {
  emit("closeDialog");
};
</script>
<template>
  <div>
    <m-m-dialog
      :is-open="isOpen"
      title="Remove policy"
      :subtitle="`Are you sure you want to remove this policy assigned to ${props.orgName}?`"
      icon="warning"
      icon-color="error"
      cy="dialog-remove-policy"
      @close="onDialogClose"
    >
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
          @click="removePolicy"
        >
          Yes, remove
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
<style scoped lang="scss"></style>
