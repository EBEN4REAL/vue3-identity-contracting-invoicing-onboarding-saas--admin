<script setup lang="ts">
defineProps({
  isOpen: {
    default: false,
    type: Boolean,
  },
});

const emit = defineEmits(["close", "submit"]);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Discard changes"
    subtitle="Are you sure you want to discard any changes?"
    icon="error"
    icon-color="error"
    cy="dialog-discard"
    @close="emit('close')"
  >
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel"
        size="medium"
        @click="emit('close')"
      >
        No
      </m-m-button>
      <m-m-button
        variant="danger"
        data-cy="button-submit"
        @click="emit('submit')"
      >
        Yes, discard
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
