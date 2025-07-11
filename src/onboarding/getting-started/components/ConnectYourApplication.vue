<script setup>
import { ref } from "vue";

const link = ref(
  "https://docs.myveriam.com/getting-started/connect-your-application",
);
</script>

<template>
  <div class="welcome-component">
    <p class="welcome-component__description mm-fw-400">
      Connect the application that needs to support the Veriam login by
      configuring the OIDC connection. This might require some information from
      a developer to set up correctly.
    </p>

    <p class="welcome-component__description mm-fw-400 mm-mt-10">
      Click
      <m-m-link class="mm-pa-1" :href="link" target="_blank">here</m-m-link>
      for more information regarding connecting your application.
    </p>
  </div>
</template>
