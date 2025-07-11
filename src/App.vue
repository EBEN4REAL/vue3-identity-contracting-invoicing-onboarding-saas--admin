<template>
  <v-app class="mm-app" data-cy="app">
    <component :is="$route.meta.layout || 'div'"></component>
    <m-m-toast />
  </v-app>
</template>
<script setup>
import { useHubSpotChat } from "./mm_ui_kit/src/composables/useHubspotChat";
useHubSpotChat();
</script>

<style scoped>
.mm-app {
  background-color: rgb(255, 255, 255);
  width: 100%;
}
</style>
