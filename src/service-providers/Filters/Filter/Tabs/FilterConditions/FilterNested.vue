<script setup lang="ts">
import { PropType } from "vue";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { FilterRead } from "~/service-providers/Filters/filters.types";

const emit = defineEmits(["go-to-filter", "remove"]);

defineProps({
  filter: {
    type: Object as PropType<FilterRead>,
    default: () => ({}),
  },
  noRemove: {
    type: Boolean,
    default: false,
  },
});
</script>

<template>
  <m-m-card class="filter-nested">
    <div class="mm-flex mm-flex-justify-between mm-flex-align-center mm-pa-8">
      <div class="mm-flex mm-flex-column">
        <div class="mm-flex">
          <div
            class="mm-page-title--h3 mm-fw-500 mm-mr-4"
            data-cy="filter-nested-name"
          >
            {{ filter.name }}
          </div>
          <m-m-badge :status="BadgeTypes['Warning']" text="Existing" />
        </div>

        <div
          v-if="filter.description"
          class="mm-page-subtitle--h2"
          data-cy="filter-nested-description"
        >
          {{ filter.description }}
        </div>
      </div>
      <div class="mm-flex mm-flex-align-center mm-flex-gap-8">
        <m-m-button
          append-icon="arrow-up-right-primary"
          variant="outlined-light"
          is-tile
          size="small"
          cy="button-filter-nested-go-to-filter"
          @click="emit('go-to-filter')"
        >
          Go to filter
        </m-m-button>
        <m-m-button
          v-if="!noRemove"
          variant="tertiary"
          prepend-icon="close"
          is-tile
          size="small"
          cy="button-filter-nested-remove"
          @click="emit('remove')"
        >
          Remove
        </m-m-button>
      </div>
    </div>
  </m-m-card>
</template>

<style scoped lang="scss">
.filter-nested {
  background-color: #fdfdfe;
}
</style>
