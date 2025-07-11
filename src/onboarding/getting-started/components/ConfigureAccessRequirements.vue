<script setup>
import { ref } from "vue";

const link = ref(
  "https://docs.myveriam.com/getting-started/configure-your-access-requirements",
);
</script>

<template>
  <div class="welcome-component">
    <p class="welcome-component__description mm-fw-400">
      Determine how you want to set up your access restrictions and configure
      the system according to these. See the help center for guidance on how to
      <m-m-link class="mm-px-1" :href="link" target="_blank"
        >determine</m-m-link
      >
      your access requirements and for
      <m-m-link class="mm-px-1" :href="link" target="_blank">examples</m-m-link>
      of how to configure these scenarios.
    </p>
  </div>
</template>
