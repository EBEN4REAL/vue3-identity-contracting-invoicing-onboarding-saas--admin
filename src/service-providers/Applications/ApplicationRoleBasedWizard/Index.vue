<script setup lang="ts">
import { ref, computed, Ref, ComputedRef, onMounted } from "vue";
import ApplicationVerification from "./ApplicationVerification.vue";
import RolesAndPermissionsVerification from "./RolesAndPermissionsVerification.vue";
import ReviewChanges from "./ReviewChanges.vue";
import {
  TypeApplicationConfigWizardStep,
  TypeApplicationVerificationComponent,
  TypeComponentRef,
  TypeRolesAndPermissionsVerificationComponent,
} from "./types";
import {
  ApplicationRoleBasedConfigWizard,
  ApplicationWizardStepTitles,
} from "./constants";
import { configurationService } from "~/configuration/configuration.service";
import { authService } from "~/auth/auth.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useRoute, useRouter } from "vue-router";
import DialogSecretSuccessfullyCreated from "~/service-providers/ApplicationDetails/Dialogs/DialogSecretSuccessfullyCreated.vue";
import { useApplicationRoleBasedConfigStore } from "~/stores/useApplicationRoleBasedConfigStore";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";

const router = useRouter();
const route = useRoute();
const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isComponentReadyForRender: Ref<boolean> = ref(false);

const refs = {
  applicationVerification: ref<TypeApplicationVerificationComponent | null>(
    null,
  ),
  rolesAndPermissions: ref<TypeRolesAndPermissionsVerificationComponent | null>(
    null,
  ),
  reviewChanges: ref<InstanceType<typeof ReviewChanges> | null>(null),
};

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

// Define the steps and their corresponding components and references
const steps: Record<number, TypeApplicationConfigWizardStep> = {
  [ApplicationRoleBasedConfigWizard.ApplicationVerification]: {
    component: ApplicationVerification,
    ref: refs.applicationVerification,
  },
  [ApplicationRoleBasedConfigWizard.RolesAndPermissionsVerification]: {
    component: RolesAndPermissionsVerification,
    ref: refs.rolesAndPermissions,
  },
  [ApplicationRoleBasedConfigWizard.ReviewChanges]: {
    component: ReviewChanges,
    ref: refs.reviewChanges,
  },
};

const applicationRoleBasedConfigStore = useApplicationRoleBasedConfigStore();

const currentStep: Ref<keyof typeof steps> = ref(
  ApplicationRoleBasedConfigWizard.ApplicationVerification,
);
const isDialogSecretSuccessfullyCreatedOpen: Ref<boolean> = ref(false);
const secret: Ref<string> = ref("");
const createdApplicationId: Ref<string> = ref("");
const serviceProviderId: Ref<string | null> = ref(null);
const isButtonSubmitLoading: Ref<boolean> = ref(false);

const currentComponent: ComputedRef<
  TypeApplicationConfigWizardStep["component"]
> = computed(() => steps[currentStep.value]?.component);

const currentComponentRef: ComputedRef<TypeComponentRef> = computed(
  () => steps[currentStep.value]?.ref as TypeComponentRef,
);

const isFormApplicationValid: ComputedRef<boolean> = computed(() => {
  if (isInEditMode.value)
    return !refs.applicationVerification.value?.v$.$invalid;
  return (
    !refs.applicationVerification.value?.v$.$invalid &&
    isApplicationNameValid.value
  );
});

const isRolesAndPermissionsValid: ComputedRef<boolean> = computed(
  () =>
    Boolean(refs.rolesAndPermissions.value?.isRolesAndPermissionsValid) &&
    Boolean(!refs.rolesAndPermissions.value?.isDuplicateRoleOrPermission),
);

const isApplicationVerificationStep: ComputedRef<boolean> = computed(
  () =>
    currentStep.value ===
    ApplicationRoleBasedConfigWizard.ApplicationVerification,
);

const isApplicationNameValid: ComputedRef<boolean> = computed(() =>
  Boolean(refs.applicationVerification.value?.isApplicationNameValid),
);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(() => {
  if (isButtonSubmitLoading.value) return true;

  switch (currentStep.value) {
    case ApplicationRoleBasedConfigWizard.ApplicationVerification:
      return !isFormApplicationValid.value;
    case ApplicationRoleBasedConfigWizard.RolesAndPermissionsVerification:
      return !isRolesAndPermissionsValid.value;
    case ApplicationRoleBasedConfigWizard.ReviewChanges:
      return false;
    default:
      return true;
  }
});

const isButtonContinueDisabled: ComputedRef<boolean> = computed(() => {
  return isButtonSubmitDisabled.value || isConfigPublishing.value;
});

const title: ComputedRef<string> = computed(
  () =>
    ApplicationWizardStepTitles[
      currentStep.value as keyof typeof ApplicationWizardStepTitles
    ],
);

const showErrorToast = (error: unknown, entity: string) => {
  if (error?.response.status === 409) {
    eventBus.$emit("onShowToast", {
      text: "Role(s) contains duplicate entries, choose a unique role(s)",
      status: "error",
    });
  } else if (error?.response.status === 422) {
    eventBus.$emit("onShowToast", {
      text: `Please enter a ${entity} that only contains lowercase letters (a-z), numbers (0-9), underscores (_), or colons (:).`,
      status: "error",
    });
  } else {
    eventBus.$emit("onShowToast", {
      text: `An error occurred while fetching saving changes`,
      status: "error",
    });
  }
};

const saveChanges = async () => {
  if (!serviceProviderId.value || isButtonSubmitDisabled.value) return;
  isButtonSubmitLoading.value = true;
  const policy_types = applicationRoleBasedConfigStore.roles.map((role) => ({
    name: role.name.name,
    entitlements: role.permissions.map((permission) => permission.name.name),
  }));
  try {
    const response =
      await configurationService.createApplicationRoleBasedWizard(
        serviceProviderId.value,
        {
          name: applicationRoleBasedConfigStore.applicationForm.name,
          oauth_client: {
            name: applicationRoleBasedConfigStore.applicationForm.name,
            mfa_required: Boolean(
              applicationRoleBasedConfigStore.applicationForm.mfa_required,
            ),
            type: applicationRoleBasedConfigStore.applicationForm.type,
            redirect_uris:
              applicationRoleBasedConfigStore.applicationForm.redirectUrls?.filter(
                (url: string) => url.length > 0,
              ),
          },
          policy_types,
        },
      );
    createdApplicationId.value = response.oauth_client.id || "";
    secret.value = response.oauth_client.client_secret;
    isDialogSecretSuccessfullyCreatedOpen.value = true;
  } catch (error) {
    showErrorToast(error, "role or permission");
  } finally {
    isButtonSubmitLoading.value = false;
  }
};

// progress to the next step
const progressToNextStep = async (): Promise<void> => {
  const applicationVerificationRef = refs.applicationVerification.value;
  const rolesAndPermissionsVerificationRef = refs.rolesAndPermissions.value;

  if (
    currentStep.value ===
      ApplicationRoleBasedConfigWizard.ApplicationVerification &&
    applicationVerificationRef
  ) {
    if (!isInEditMode.value)
      await applicationVerificationRef.validateApplication();
    if (!isFormApplicationValid.value) {
      return;
    }
    currentStep.value =
      ApplicationRoleBasedConfigWizard.RolesAndPermissionsVerification;
  } else if (
    currentStep.value ===
      ApplicationRoleBasedConfigWizard.RolesAndPermissionsVerification &&
    rolesAndPermissionsVerificationRef
  ) {
    if (!isRolesAndPermissionsValid.value) {
      return;
    }
    currentStep.value = ApplicationRoleBasedConfigWizard.ReviewChanges;
  } else {
    await saveChanges();
  }
};

const resetConfigWizard = (): void => {
  if (refs.applicationVerification.value) {
    applicationRoleBasedConfigStore.reset();
    router.replace(`/sp/applications`);
  }
};

const buttonText: ComputedRef<string> = computed(() => {
  switch (currentStep.value) {
    case ApplicationRoleBasedConfigWizard.ApplicationVerification:
      return "Continue";
    case ApplicationRoleBasedConfigWizard.RolesAndPermissionsVerification:
      return "Review changes";
    default:
      return "Save changes";
  }
});

const backButtonText: ComputedRef<string> = computed(() => {
  switch (currentStep.value) {
    case ApplicationRoleBasedConfigWizard.RolesAndPermissionsVerification:
      return "Back to application details";
    case ApplicationRoleBasedConfigWizard.ReviewChanges:
      return "Back to roles details";
    default:
      return "Discard";
  }
});

const isInEditMode: ComputedRef<boolean> = computed(() =>
  Boolean(route.query.item),
);

const handleBackButton = async () => {
  if (
    currentStep.value ===
    ApplicationRoleBasedConfigWizard.ApplicationVerification
  ) {
    resetConfigWizard();
  } else {
    currentStep.value = currentStep.value - 1;
    if (
      currentStep.value ===
      ApplicationRoleBasedConfigWizard.ApplicationVerification
    ) {
      setTimeout(() => {
        refs.applicationVerification.value?.v$.$touch();
        refs.applicationVerification.value?.validateApplication();
      }, 300);
    }
  }
};

const onDialogSecretSuccessfullyCreatedClose = () => {
  isDialogSecretSuccessfullyCreatedOpen.value = false;
  applicationRoleBasedConfigStore.reset();
  router.replace(
    `/sp/${serviceProviderId.value}/applications/${createdApplicationId.value}`,
  );
};

const getServiceProviderOauthClient = async () => {
  try {
    await oAuthClientsService.getServiceProviderOauthClient(
      route.query.item as string,
      serviceProviderId.value as string,
    );
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching application details",
      status: "error",
    });
  }
};

onMounted(async () => {
  await unpublishedChangesStore.getUnpublishedConfig();
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  if (isInEditMode.value) {
    await getServiceProviderOauthClient();
  }
  isComponentReadyForRender.value = true;
});
</script>

<template>
  <m-m-teleport to="common-page-layout-header-icon">
    <m-m-icon icon="connect-app" />
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-title">
    <div
      v-sanitize-html="
        $t(
          'configuration.applications.application_new.new_application_with_roles.title',
        )
      "
    ></div>
  </m-m-teleport>
  <m-m-teleport to="common-page-layout-header-subtitle">
    <div
      v-sanitize-html="
        $t(
          'configuration.applications.application_new.new_application_with_roles.subtitle',
        )
      "
    ></div>
  </m-m-teleport>

  <m-m-step-wrapper :title="title">
    <template #component>
      <component
        :is="currentComponent"
        v-if="isComponentReadyForRender"
        :ref="currentComponentRef"
      />
    </template>
    <template #subtitle>
      <div v-if="isApplicationVerificationStep" class="mm-my-10">
        <div class="mm-mb-3">
          Provide some basic information for your application. You will be able
          to change more advanced settings later if needed.
        </div>
        <div>
          After finishing the wizard, you will be presented with the clientID
          and client Secret you need to setup the OpenID Connect connection
          between your application and Veriam. See
          <m-m-link
            class="mm-px-1"
            href="https://docs.myveriam.com/for-providers/ciam/connect-your-application"
            target="_blank"
            >here</m-m-link
          >
          for more information regarding connecting your application.
        </div>
      </div>
    </template>
  </m-m-step-wrapper>

  <div
    class="mm-flex mm-flex-justify-between application-wizard-button-container"
  >
    <m-m-button variant="outlined" @click="handleBackButton">
      {{ backButtonText }}
    </m-m-button>
    <m-m-button
      variant="elevated"
      :is-disabled="isButtonContinueDisabled"
      :loading="isButtonSubmitLoading"
      @click="progressToNextStep"
    >
      {{ buttonText }}
      <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
        Config is currently being published.
      </m-m-tooltip>
    </m-m-button>
  </div>

  <dialog-secret-successfully-created
    :is-open="isDialogSecretSuccessfullyCreatedOpen"
    mode="app-created"
    :secret-key="secret"
    :client-id="createdApplicationId"
    @close="onDialogSecretSuccessfullyCreatedClose"
  />
</template>

<style lang="scss" scoped>
@media (max-width: $breakpoint-xs) {
  .mm-application-wizard {
    width: 100% !important;
  }
  .application-wizard-button-container {
    display: flex;
    flex-direction: column;
    button {
      width: 100%;
      margin-bottom: 20px;
    }
    button:first-child {
      order: 2;
    }
    button:nth-child(2) {
      order: 1;
    }
  }
}
</style>
