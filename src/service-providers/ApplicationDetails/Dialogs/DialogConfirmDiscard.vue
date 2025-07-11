<script setup lang="ts">
defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["submit", "close"]);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Discard changes"
    subtitle="Are you sure you want to discard any changes?"
    icon="error"
    icon-color="error"
    cy="dialog-confirm-discard"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        cy="button-cancel"
        size="medium"
        @click="emit('close')"
      >
        No
      </m-m-button>
      <m-m-button variant="danger" cy="button-submit" @click="emit('submit')">
        Yes, discard
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
