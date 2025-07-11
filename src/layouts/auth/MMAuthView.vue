<script setup lang="ts">
import { Ref, ref } from "vue";
import { useRoute } from "vue-router";
import { SVG_DIMENSIONS } from "~/mm_ui_kit/src/helpers/utils";
import { AlertTypes } from "~/mm_ui_kit/src/types/alert.types";
import MMSquareSVG from "~/assets/images/mm-square.svg";

const route = useRoute();
const error = ref(route.query.error);
const svgWidth: Ref<string> = ref(SVG_DIMENSIONS.WIDTH);
const svgHeight: Ref<string> = ref(SVG_DIMENSIONS.HEIGHT);
</script>

<template>
  <div class="mm-auth-view" data-cy="auth-view">
    <div class="mm-auth-view-content">
      <m-m-alert
        v-if="error"
        :status="AlertTypes['Error']"
        class="mm-auth-view-content-alert"
        data-cy="alert"
        @close="error = ''"
      >
        Error
      </m-m-alert>
      <router-view />
    </div>
    <div class="mm-mt-auto mm-mb-16" data-teleport="authViewFooter" />
  </div>
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

<style lang="scss">
.mm-auth-view {
  display: flex;
  flex: 1 0 auto;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: rgba(7, 46, 81, 0.1);

  &-content {
    position: relative;
    width: 360px;
    margin-top: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    z-index: 101;

    &-alert {
      position: absolute;
      top: -24px;
      right: 0;
      left: 0;
      transform: translateY(-100%);
    }
  }

  .mm-auth-view-content-title {
    color: #101828;
    font-size: 30px;
    line-height: 24px;
    text-align: center;
    font-weight: 600;
    margin-bottom: 12px;
  }

  .mm-auth-view-content-subtitle {
    color: #667085;
    font-size: 15px;
    line-height: 24px;
    margin-bottom: 32px;
    text-align: center;
  }

  .mm-auth-view-login-options-remember-me {
    float: left;
  }

  .mm-auth-view-continue-with-google {
    margin-bottom: 12px;
  }

  .mm-auth-view-separator {
    color: rgba(71, 84, 103, 1);
    font-size: 14px;
    line-height: 20px;
    margin: 24px 0;
    text-align: center;
  }

  .mm-auth-view-options-item-right {
    display: block;
    text-align: right;
  }

  .mm-auth-view-options-item-center {
    text-align: center;
  }

  .mm-auth-view-content-area .mm-auth-view-show-password-button {
    background-color: transparent;
    border: 0;
    cursor: pointer;
    outline: none;
    width: 24px;
    height: 24px;
    padding: 4px;
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
  }

  .mm-auth-white-box-for-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 56px;
    height: 56px;
    background-color: #fff;
    border: 1px solid #eaecf0;
    border-radius: 12px;
    box-shadow: 0 1px 2px 0 rgba(16, 24, 40, 0.05);
  }

  &-left-square-element {
    position: absolute;
    left: 0;
    bottom: 0;
    z-index: 100;
  }

  &-right-square-element {
    position: absolute;
    right: 0;
    top: 0;
    transform: rotate(0.5turn);
    z-index: 100;
  }
}
</style>
