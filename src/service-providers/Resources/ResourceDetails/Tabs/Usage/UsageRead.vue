<script setup lang="ts">
import { TableHeader } from "~/mm_ui_kit/src/types/table.types";

const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Name",
    key: "name",
    sortable: true,
  },
  {
    label: "Description",
    key: "description",
    sortable: true,
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];
</script>

<template>
  <m-m-expandable-card
    title="Applications (0)"
    class="mm-py-4 mm-flex mm-flex-row"
  >
    <m-m-table
      class="mm-w-10"
      :headers="TABLE_HEADERS"
      :rows="[]"
      cy="usage-table"
    >
    </m-m-table>
  </m-m-expandable-card>
</template>

<style scoped lang="scss"></style>
