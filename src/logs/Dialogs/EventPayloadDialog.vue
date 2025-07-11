<script lang="ts" setup>
import { defineProps, defineEmits, PropType, ComputedRef, computed } from "vue";
import { FormattedAuditEvent } from "../Tabs/AuditLog/audit-events.types";
import { EventRead } from "~/events/events.types";

const props = defineProps({
  event: {
    type: Object as PropType<FormattedAuditEvent | EventRead | null>,
    default: null,
  },
  isOpen: {
    type: Boolean,
    default: false,
  },
});

const formattedPayload: ComputedRef<string> = computed(() => {
  if (!props?.event?.payload) return "";

  return Object.entries(props.event.payload)
    .map(([key, value]) => `${key}: ${value}`)
    .join("\n");
});

const emit = defineEmits(["close"]);

const closeModal = () => {
  emit("close");
};
</script>

<template>
  <m-m-dialog
    :is-open="props?.isOpen"
    title="Payload details"
    :subtitle="`Type: ${props?.event?.type}`"
    icon="document-text"
    icon-size="24px"
    cy="events-payload-dialog"
    @close="closeModal"
  >
    <template #default>
      <pre class="mm-text-white">{{ formattedPayload }}</pre>
    </template>
    <template #footer>
      <m-m-button variant="outlined" @click="closeModal">Dismiss</m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
