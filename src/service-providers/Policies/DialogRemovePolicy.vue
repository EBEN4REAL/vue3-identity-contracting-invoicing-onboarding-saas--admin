<!-- TODO: Remove File after confirming no need for rollback -->

<script lang="ts" setup>
import { PropType } from "vue";
import { AllPolicyRead } from "./policies.types";
import { computed } from "vue";

const props = defineProps({
  data: {
    type: Object as PropType<AllPolicyRead | null>,
    default: null,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
  orgName: {
    type: String,
    default: null,
  },
  userName: {
    type: String,
    default: null,
  },
});

const emit = defineEmits(["closeDialog", "submitDialog"]);

const onDialogClose = () => {
  emit("closeDialog");
};
const submit = () => {
  emit("submitDialog");
};

const assignedTo = computed(() => {
  return props.data?.policy_assignment === "ORGANIZATION"
    ? "Organization"
    : props.userName;
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Remove policy"
    :subtitle="`Are you sure you want to remove this policy assigned to ${props.orgName} from org ${assignedTo}?`"
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
      <m-m-button variant="danger" cy="button-submit" @click="submit">
        Yes, delete
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
