<script setup lang="ts">
import LogoSVG from "~/assets/images/veriam_logo.svg";
import { Ref, onMounted, ref } from "vue";
import { UserProfileMM } from "./auth.types";
import { authService } from "./auth.service";
import { organizationsService } from "~/organizations/organizations.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import config from "~/mm.config.json";
const userProfile: Ref<UserProfileMM | null> = ref(null);

const registerOrgAsSP = async () => {
  if (userProfile.value) {
    try {
      const response = await organizationsService.registerOrgAsSP(
        userProfile.value.org as string,
      );
      if (response) {
        authService.login();
      }
    } catch (error) {
      if (error.response?.status === 409) {
        authService.login();
      } else {
        eventBus.$emit("onShowToast", {
          text: error,
          status: "error",
        });
      }
    }
  }
};

const goBack = () => {
  window.location.href = config.scApp.url;
};

onMounted(async () => {
  userProfile.value = await authService.getProfile();
});
</script>

<template>
  <div class="auth-card">
    <div class="mm-flex mm-flex-align-center mm-flex-column mm-w-10">
      <div class="mm-auth-view-login-logo-container">
        <LogoSVG class="mm-auth-view-logo" data-cy="default-logo" />
      </div>
      <div class="mm-auth-view-login-content-title mm-mb-6">
        Start using Veriam admin for your business
      </div>
      <div class="mm-auth-view-content-subtitle" data-cy="org-message">
        Manage access, subscriptions, and data for all your B2B customers in our
        admin portal.
      </div>
      <div class="mm-mt-2 mm-mb-16">
        <ul>
          <li class="mm-flex mm-flex-align-center mm-flex-gap-4 mm-mb-4">
            <m-m-icon
              icon="check-circle"
              width="35"
              height="34"
              class="mm-mr-2 mm-flex-shrink-0"
            />
            <span class="mm-auth-view-login-span mm-page-subtitle--h2"
              >Easily set up customer access and subscriptions</span
            >
          </li>
          <li class="mm-flex mm-flex-align-center mm-flex-gap-4 mm-mb-4">
            <m-m-icon
              icon="check-circle"
              width="35"
              height="34"
              class="mm-mr-2 mm-flex-shrink-0"
            />
            <span class="mm-auth-view-login-span mm-page-subtitle--h2"
              >Integrate with a few lines of code</span
            >
          </li>
          <li class="mm-flex mm-flex-align-center mm-flex-gap-4 mm-mb-4">
            <m-m-icon
              icon="check-circle"
              width="35"
              height="34"
              class="mm-mr-2 mm-flex-shrink-0"
            />
            <span class="mm-auth-view-login-span mm-page-subtitle--h2"
              >Give users one login for everything they access through
              Veriam</span
            >
          </li>
          <li class="mm-flex mm-flex-align-center mm-flex-gap-4">
            <m-m-icon
              icon="check-circle"
              width="35"
              height="34"
              class="mm-mr-2 mm-flex-shrink-0"
            />
            <span class="mm-auth-view-login-span mm-page-subtitle--h2"
              >Free access management, forever</span
            >
          </li>
        </ul>
      </div>
      <m-m-button
        cy="continue"
        variant="elevated"
        type="submit"
        :is-full-width="true"
        class="mm-mb-8"
        @click="registerOrgAsSP"
      >
        Continue
      </m-m-button>
      <m-m-button
        cy="back-customer-portal"
        variant="outlined"
        type="submit"
        :is-full-width="true"
        class="mm-mb-8"
        @click="goBack"
      >
        Back to customer portal
      </m-m-button>
    </div>
    <div class="mm-auth-view-login-footer mm-mt-15">
      By continuing, I agree with Veriam's
      <m-m-link
        href="/tc/terms.pdf"
        target="_blank"
        class="mm-auth-view-login-footer-decorated"
        >&nbsp;terms of service&nbsp;
      </m-m-link>
      and
      <m-m-link
        href="/tc/privacy.pdf"
        target="_blank"
        class="mm-auth-view-login-footer-decorated"
        >&nbsp;privacy policy
      </m-m-link>
    </div>
  </div>
</template>

<style scoped lang="scss">
.mm-auth-view-login {
  &-logo {
    align-self: center;

    &-container {
      align-self: center;
      margin: 0 0 30px 0;
    }
  }

  &-content {
    &-title {
      font-size: 26px;
      font-weight: 600;
      line-height: 38px;
      text-align: center;
    }
  }

  &-span {
    text-align: left;
  }

  &-footer {
    margin-top: 30px;
    font-size: 12px;
    font-weight: 400;
    line-height: 18px;
    text-align: center;
    color: #9ea5af;

    &-decorated {
      color: #9ea5af;
      font-size: 12px;
      text-decoration: underline;
    }
  }
}
</style>
