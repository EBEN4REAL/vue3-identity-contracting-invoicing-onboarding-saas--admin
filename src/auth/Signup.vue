<script setup lang="ts">
import { authService } from "~/auth/auth.service";

authService.signup();
</script>

<template>
  <m-m-progress-circular :size="128" :width="12" />
</template>

<style scoped lang="scss"></style>
