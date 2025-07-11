<script setup lang="ts">
import { PropType } from "vue";
import { TypeComparisonOperator } from "~/service-providers/filters.type";

defineProps({
  comparisonOperator: {
    type: String as PropType<TypeComparisonOperator>,
    default: null,
  },
});
</script>

<template>
  <div class="comparison-operator">{{ comparisonOperator }}</div>
</template>

<style scoped lang="scss">
.comparison-operator {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 30px;
  font-size: 14px;
  font-weight: 600;
  line-height: 20px;
  text-align: left;
  color: #9da4ae;
  margin-left: 14px;
  text-transform: uppercase;

  &:before,
  &:after {
    content: "";
    width: 1px;
    height: 23px;
    background-color: #9da4ae;
  }
}
</style>
