<script setup>
import { ref } from "vue";
const link = ref(
  "https://docs.myveriam.com/for-providers/subscription-management/configure-your-plans",
);
</script>
<template>
  <div class="welcome-component">
    <p class="welcome-component__description mm-fw-400">
      Create and manage plans to bundle access, pricing, and legal agreements -
      simplifying subscription and access control in one unified template.
    </p>
    <p class="welcome-component__description mm-fw-400 mm-mt-10">
      Click
      <m-m-link class="mm-pa-1" :href="link" target="_blank">here</m-m-link>
      for more information on configuring your subscription plans.
    </p>
  </div>
</template>
