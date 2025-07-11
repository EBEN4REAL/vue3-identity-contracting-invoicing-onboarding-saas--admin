<script setup lang="ts">
import { ref, Ref, onMounted, computed, ComputedRef } from "vue";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { authService } from "~/auth/auth.service";
import { UserProfileMM } from "~/auth/auth.types";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import LogoSVG from "~/assets/images/LandingLogo.svg";
import {
  ServiceProviderRead,
  PaginationSchema_ServiceProviderRead_,
} from "~/iam/iam.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const selectOrganizationModel: Ref<string | null> = ref<string | null>(null);
const loginSps: Ref<PaginationSchema_ServiceProviderRead_ | null> = ref(null);
const userProfile: Ref<UserProfileMM | null> = ref(null);
const isLoading: Ref<boolean> = ref(false);
const serviceProvidersLoading: Ref<boolean> = ref(false);

const fetchServiceProviders = async (params?: TableRequestParams) => {
  try {
    serviceProvidersLoading.value = true;
    loginSps.value = await serviceProvidersService.getServiceProviders({
      ...params,
    });
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching service providers",
      status: "error",
    });
  } finally {
    serviceProvidersLoading.value = false;
  }
};

const filteredOrganizations: ComputedRef<ServiceProviderRead[]> = computed(
  () => {
    return loginSps?.value?.results.filter(
      (sp) => sp.id !== userProfile.value?.sp_org,
    );
  },
);

const loginAsOrganization = async () => {
  if (!selectOrganizationModel.value) {
    eventBus.$emit("onShowToast", {
      text: "Please select an organization",
      status: "error",
    });
    return;
  }

  try {
    isLoading.value = true;
    authService.loginAsOrganization(selectOrganizationModel.value);
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error logging in as organization",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

onMounted(async () => {
  userProfile.value = await authService.getProfile();
  await fetchServiceProviders();
});
</script>

<template>
  <div class="auth-card">
    <div>
      <div class="support-login-logo-container">
        <LogoSVG class="support-login-logo" />
      </div>
      <div
        v-sanitize-html="$t('provide_support.title')"
        data-cy="select-organization-header"
        class="mm-auth-view-content-title mm-mb-6"
      />
      <div
        v-sanitize-html="$t('provide_support.subtitle')"
        class="mm-auth-view-content-subtitle mm-mb-16"
      />
      <form
        v-mm-focus-first
        data-cy="login-support-select-organization-form"
        @submit.prevent="loginAsOrganization"
      >
        <m-m-autocomplete
          v-model="selectOrganizationModel"
          :items="filteredOrganizations"
          :total-items="loginSps?.total || 0"
          item-title="name"
          item-value="id"
          label="Organization"
          data-cy="select-support-organization"
          class="mm-mb-8"
          placeholder="Select organization"
          :loading="serviceProvidersLoading"
          @update-params="fetchServiceProviders"
        >
          <template #option="{ item }">
            <span>{{ item.name }}</span>
          </template>
        </m-m-autocomplete>

        <m-m-button
          cy="continue"
          variant="elevated"
          type="submit"
          :is-full-width="true"
          class="mm-auth-view-button-submit mm-mb-8"
        >
          Continue
        </m-m-button>
      </form>
    </div>
  </div>
</template>

<style scoped lang="scss">
.auth-card {
  padding-top: 56px;
  padding-bottom: 64px;
}
.support-login-logo-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 0 0 30px 0;

  .support-login-logo {
    max-width: 190px;
    max-height: 55px;
  }
}
</style>
