<script setup lang="ts">
import { TypeChip } from "~/mm_ui_kit/src/types/chips";
import { ref, Ref } from "vue";

const chipsValue: Ref<string> = ref("all");
const chipsData: TypeChip[] = [
  {
    title: "All",
    value: "all",
  },
];

for (let i = 1; i <= 20; i++) {
  chipsData.push({
    title: `Chip #${i}`,
    value: `chip-${i}`,
  });
}
</script>

<template>
  <div class="chips-wrapper">
    <h4 class="mm-mb-4">Chips value = {{ chipsValue }}</h4>
    <m-m-chips v-model="chipsValue" :chips="chipsData" />
  </div>
</template>

<style scoped lang="scss">
.chips-wrapper {
  width: 800px;
}
</style>
