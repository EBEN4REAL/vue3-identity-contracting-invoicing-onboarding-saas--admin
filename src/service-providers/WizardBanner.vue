<script setup lang="ts">
import { computed, ComputedRef, PropType } from "vue";
import { WizardItemRead } from "~/configuration/configuration.types";
import { useUiStore } from "~/stores/useUiStore";

const props = defineProps({
  wizard: {
    type: Object as PropType<WizardItemRead>,
    default: () => ({}),
  },
  itemId: {
    type: String,
    default: "",
  },
});

const uiStore = useUiStore();

const link = !uiStore.isSPViewerOnly
  ? `/sp${props.wizard.path}/${props.wizard.id}?item=${props.itemId}`
  : "#";

const isWizardHidden: ComputedRef<boolean> = computed(
  () => props.wizard?.hidden,
);
</script>

<template>
  <m-m-alert has-call-to-action :is-closable="false">
    This item is part of <span class="mm-fw-600">{{ wizard?.name }}</span>
    <span v-if="isWizardHidden"> and is currently hidden</span>. Click
    <m-m-link :to="link" class="mm-fs-16">here</m-m-link> to edit.
  </m-m-alert>
</template>
