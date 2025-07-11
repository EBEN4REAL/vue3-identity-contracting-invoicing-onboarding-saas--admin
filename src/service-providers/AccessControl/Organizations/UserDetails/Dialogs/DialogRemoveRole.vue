<script setup lang="ts">
import { computed, PropType, ref } from "vue";
import { ServiceProviderOrganizationUserRead } from "~/iam/iam.types";
import { PolicyTypeRead } from "~/policies/policies.types";
import { policiesService } from "~/service-providers/policies.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  data: {
    type: Object as PropType<PolicyTypeRead>,
    default: () => ({}),
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  organizationId: {
    type: String,
    required: true,
  },
  organizationName: {
    type: String,
    required: true,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  user: {
    type: Object as PropType<ServiceProviderOrganizationUserRead>,
    default: () => ({}),
  },
});

const loading = ref(false);
const isDisabled = ref(false);
const emit = defineEmits(["closeDialog", "rolesUpdated"]);

const onDialogClose = () => {
  emit("closeDialog");
};

const subtitleText = computed(() => {
  return `Are you sure you want to remove this role assigned to ${props.user.user.first_name} ${props.user.user.last_name} from ${props.organizationName}?`;
});

const removePolicy = async () => {
  try {
    loading.value = true;
    isDisabled.value = true;
    await policiesService.removePolicy(props.serviceProviderId, {
      policy_type_id: props.data.type_id,
      organization_user_id: props.user.organization_user.id,
      organization_id: props.organizationId,
    });
    emit("rolesUpdated");
    loading.value = false;
    onDialogClose();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Something went wrong",
      status: "error",
    });
  } finally {
    loading.value = false;
    isDisabled.value = false;
  }
};
</script>
<template>
  <div>
    <m-m-dialog
      :is-open="isOpen"
      title="Remove policy"
      :subtitle="subtitleText"
      icon="trash"
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
          :loading="loading"
          :is-disabled="isDisabled"
          @click="removePolicy"
        >
          Yes, remove
        </m-m-button>
      </template>
    </m-m-dialog>
  </div>
</template>
<style scoped lang="scss"></style>
