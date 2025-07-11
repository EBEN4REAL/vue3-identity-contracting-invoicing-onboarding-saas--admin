<script setup lang="ts">
import { authService } from "~/auth/auth.service";
import { onMounted, Ref, ref } from "vue";
import { AlertTypes } from "~/mm_ui_kit/src/types/alert.types";

const NO_MATCHING_STATE_ERROR: string = "No matching state found in storage";

const authorizationError: Ref<boolean> = ref(false);

onMounted(async () => {
  authService
    .handleLoginRedirect()
    .then(async (user) => {
      if (user.url_state) {
        window.location.href = user.url_state;
      } else {
        const profile = await authService.getProfile();
        authService.isUserSPViewer().then((isSPViewer: boolean) => {
          if (isSPViewer) {
            window.location.href = "/sp/getting-started";
          } else if (!isSPViewer && profile && profile.sp_org === null) {
            window.location.href = "/login-sc-to-sp";
          } else {
            window.location.href = "/access-denied";
          }
        });
      }
    })
    .catch((err: Error) => {
      console.error(err);
      if (err.message === NO_MATCHING_STATE_ERROR) {
        authService.login();
      } else {
        authorizationError.value = true;
      }
    });
});
</script>

<template>
  <m-m-progress-circular v-if="!authorizationError" :size="128" :width="12" />
  <m-m-alert v-else :status="AlertTypes['Error']" :is-closable="false"
    >Something went wrong
  </m-m-alert>
</template>
