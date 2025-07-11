<script setup>
import { ref } from "vue";
const link = ref(
  "https://docs.myveriam.com/for-providers/ciam/connect-your-application#using-openid-connect",
);
</script>
<template>
  <div class="welcome-component">
    <p class="welcome-component__description mm-fw-400">
      Finalize the configuration in your application and put the connection
      live. After this, users can user their Veriam account to login to your
      application!
    </p>
    <p class="welcome-component__description mm-fw-400 mm-mt-10">
      To see detailed steps on how to do this,
      <m-m-link class="mm-pa-1" :href="link" target="_blank"
        >check out this article</m-m-link
      >
    </p>
  </div>
</template>
