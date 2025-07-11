<script setup>
import { ref } from "vue";
const link = ref(
  "https://docs.myveriam.com/for-providers/subscription-management/set-up-your-pricing-page",
);
</script>
<template>
  <div class="welcome-component">
    <p class="welcome-component__description mm-fw-400">
      Create a pricing page to showcase your plans, enabling self-service for
      your customers to choose and manage subscriptions effortlessly.
    </p>
    <p class="welcome-component__description mm-fw-400 mm-mt-10">
      Click
      <m-m-link class="mm-pa-1" :href="link" target="_blank">here</m-m-link>
      for more information on setting up your pricing page.
    </p>
  </div>
</template>
