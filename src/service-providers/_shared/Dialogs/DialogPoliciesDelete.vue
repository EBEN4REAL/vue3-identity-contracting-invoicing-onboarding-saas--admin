<script lang="ts" setup>
import { PropType } from "vue";
import { TypeDialogPoliciesDeleteData } from "~/service-providers/ConfigurationTabs/Policies/policies.types";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  data: {
    type: Object as PropType<TypeDialogPoliciesDeleteData>,
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
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Delete ${props.data?.policyName}`"
    subtitle="Are you sure you want to delete this policy?"
    icon="trash"
    icon-color="error"
    cy="dialog-policies-delete"
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
