<script setup lang="ts">
import { ref } from "vue";

const SELECT_OPTIONS = [
  { title: "Option 1", value: "1" },
  { title: "Option 2", value: "2" },
  { title: "Option 3", value: "3" },
];

const SELECT_OPTIONS_WITH_ALREADY_ADDED = [
  { title: "Option 1", value: "1", $isDisabled: true },
  { title: "Option 2", value: "2", $isDisabled: true },
  { title: "Option 3", value: "3" },
];

const singleSelectModel = ref(null);
const multipleSelectModel = ref([]);
const multipleSelectModel_withAlreadyAdded = ref([]);
const multipleSelectModel_disabled = ref([]);
const multipleSelectModel_searchable = ref([]);
const singleSelectModel_loading = ref({ title: "Option 1", value: "1" });
</script>

<template>
  <div class="mm-mb-12">
    <h3 class="mm-page-subtitle mm-page-subtitle--h1 mm-mb-4">Multiselect:</h3>
    <m-m-multiselect
      v-model="singleSelectModel"
      label="Single select"
      placeholder="Select one option"
      item-title="title"
      item-value="value"
      :searchable="false"
      :options="SELECT_OPTIONS"
      class="mm-mb-16"
    />
    <m-m-multiselect
      v-model="multipleSelectModel"
      label="Multiple select"
      placeholder="Select multiple option"
      item-title="title"
      item-value="value"
      :searchable="false"
      :close-on-select="false"
      :options="SELECT_OPTIONS"
      multiple
      class="mm-mb-16"
    />
    <m-m-multiselect
      v-model="multipleSelectModel_withAlreadyAdded"
      label="Multiple select with already added"
      placeholder="Select multiple options"
      item-title="title"
      item-value="value"
      :searchable="false"
      :close-on-select="false"
      :options="SELECT_OPTIONS_WITH_ALREADY_ADDED"
      multiple
      class="mm-mb-16"
    />
    <m-m-multiselect
      v-model="multipleSelectModel_disabled"
      label="Disabled"
      placeholder="Select multiple options"
      disabled
      item-title="title"
      item-value="value"
      :searchable="false"
      :options="SELECT_OPTIONS_WITH_ALREADY_ADDED"
      multiple
      class="mm-mb-16"
    />
    <m-m-multiselect
      v-model="multipleSelectModel_searchable"
      label="Searchable with icon"
      placeholder="Select multiple options"
      item-title="title"
      item-value="value"
      :options="SELECT_OPTIONS"
      icon="search-lg"
      :multiple="true"
      class="mm-mb-16"
    />
    <m-m-multiselect
      :value="singleSelectModel_loading"
      label="Loading"
      placeholder="Select single option"
      item-title="title"
      item-value="value"
      :options="SELECT_OPTIONS"
      icon="search-lg"
      disabled
      loading
      class="mm-mb-16"
    />
  </div>
</template>

<style scoped lang="scss"></style>
