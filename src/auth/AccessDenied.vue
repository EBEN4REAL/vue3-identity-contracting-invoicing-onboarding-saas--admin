<script setup lang="ts">
import config from "~/mm.config.json";
import { authService } from "./auth.service";
import { Ref, ref } from "vue";
import { SVG_DIMENSIONS } from "../mm_ui_kit/src/helpers/utils";
import MMSquareSVG from "../assets/images/mm-square.svg";

const svgWidth: Ref<string> = ref(SVG_DIMENSIONS.WIDTH);
const svgHeight: Ref<string> = ref(SVG_DIMENSIONS.HEIGHT);

const handleLogout = () => {
  authService.logout();
};
</script>

<template>
  <div>
    <m-m-button
      variant="outlined"
      size="medium"
      cy="access-denied-logout-button"
      class="button-logout"
      @click="handleLogout"
    >
      Logout
    </m-m-button>
  </div>
  <PageNotFound
    error-type="Oops! You don't have access"
    message="You need permission to access the Admin Portal, please chat to your administrator to give you access"
    back-to-label="Customer Portal"
    :back-to-link="config.scApp.url"
  />
  <component
    :is="MMSquareSVG"
    :width="svgWidth"
    :height="svgHeight"
    data-cy="left-square-element"
    class="mm-auth-view-left-square-element"
  />
  <component
    :is="MMSquareSVG"
    :width="svgWidth"
    :height="svgHeight"
    data-cy="right-square-element"
    class="mm-auth-view-right-square-element"
  />
</template>

<style scoped lang="scss">
.button-logout {
  position: absolute;
  right: 20px;
  top: 40px;
  z-index: 101;
}
</style>
