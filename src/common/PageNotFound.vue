<script setup lang="ts">
import LogoSVG from "~/assets/images/logo.svg";

const props = defineProps({
  errorType: {
    type: String,
    default: "404",
  },
  message: {
    type: String,
    default: "Sorry! This page cannot be found. Please go back home.",
  },
  backToLabel: {
    type: String,
    default: "Home",
  },
  backToLink: {
    type: String,
    default: "/",
  },
});

const backTo = () => {
  window.location.href = props.backToLink;
};
</script>

<template>
  <div class="mm-flex mm-flex-align-center page-not-found">
    <div class="mm-flex mm-flex-column mm-flex-align-start">
      <LogoSVG id="logo" width="140px" data-cy="logo" />
      <h1
        id="title"
        class="page-not-found-title"
        data-cy="page-not-found-title"
      >
        {{ props.errorType }}
      </h1>
      <div data-cy="message" class="mm-page-title--h2 mm-mb-12">
        {{ props.message }}
      </div>
      <div class="mm-flex mm-flex-justify-end mm-mb-4">
        <m-m-button
          variant="elevated"
          size="small"
          cy="back-to-button"
          @click="backTo"
        >
          Back to {{ props.backToLabel }}
        </m-m-button>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.page-not-found {
  height: 100vh;
  width: 90%;
  margin-left: auto;

  &-title {
    font-size: 72px;
    line-height: 90px;
    letter-spacing: -1.4px;
  }
}
</style>
