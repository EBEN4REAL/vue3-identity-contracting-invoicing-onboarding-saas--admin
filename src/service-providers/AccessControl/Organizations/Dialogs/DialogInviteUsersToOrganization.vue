<script lang="ts" setup>
import { ref, computed, reactive, Ref, onMounted, ComputedRef } from "vue";
import { useVuelidate } from "@vuelidate/core";
import { required, helpers } from "@vuelidate/validators";
import { OrganizationUsersCreate } from "~/iam/iam.types";
import {
  TypeInviteUsersForm,
  TypeInviteUsersFormRules,
  TypeValidatorInviteUsersForm,
} from "~/users/users.types";
import { authService } from "~/auth/auth.service";
import { emailValidator } from "~/mm_ui_kit/src/helpers/emailValidator";
import { serviceProvidersService } from "~/service-providers/service-providers.service";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  organizationId: {
    type: String,
    default: "",
  },
});

const inviteUsersForm = reactive<TypeInviteUsersForm>({
  emails: [],
});
const loading: Ref<boolean> = ref(false);
const serviceProviderId: Ref<string> = ref("");

const formRules: TypeInviteUsersFormRules = {
  emails: {
    required: helpers.withMessage("Emails are required", required),
    emails: helpers.withMessage(
      "Check the format of email address",
      emailValidator,
    ),
  },
};

const v$: TypeValidatorInviteUsersForm = useVuelidate(
  formRules,
  inviteUsersForm,
  { $scope: "inviteUsers" },
);

const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");

const emit = defineEmits(["close", "submit"]);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () =>
    loading.value ||
    v$.value.emails.$invalid ||
    inviteUsersForm.emails.length === 0,
);

const inviteUsersButtonText = computed(() => {
  if (inviteUsersForm.emails.length === 0) {
    return "Invite users";
  }
  return `Invite ${inviteUsersForm.emails.length} user${
    inviteUsersForm.emails.length > 1 ? "s" : ""
  }`;
});

const submitForm = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) return;
  const inviteUsersRequest: OrganizationUsersCreate = {
    users: inviteUsersForm.emails.map((email) => ({
      email,
    })),
  };

  try {
    loading.value = true;
    await serviceProvidersService.createSPOrganizationUsers(
      serviceProviderId.value,
      props.organizationId,
      inviteUsersRequest,
    );
    emit("submit");
    closeInviteUsersModal();
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = "Failed to create organization users";
    loading.value = false;
  } finally {
    loading.value = false;
  }
};

const resetInviteUsersForm = () => {
  v$.value.$reset();
  inviteUsersForm.emails = [];
  isAlertVisible.value = false;
  alertText.value = "";
};

const closeInviteUsersModal = () => {
  resetInviteUsersForm();
  emit("close");
};

const onAlertClose = () => {
  isAlertVisible.value = false;
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Invite users"
    subtitle="Invite users to create a Veriam account"
    icon="invite-user"
    @close="closeInviteUsersModal"
  >
    <template #default>
      <m-m-alert
        v-if="isAlertVisible"
        status="error"
        cy="invite-users-form-alert"
        class="mm-mb-12"
        @close="onAlertClose"
      >
        {{ alertText }}
      </m-m-alert>
      <form v-mm-focus-first class="mm-page-dialog-form">
        <m-m-tags-input
          v-model="inviteUsersForm.emails"
          label="Email address"
          placeholder="Add one or more email addresses"
          type="email"
          required
          :errors="v$.emails.$errors"
          @blur="v$.emails.$touch"
        />
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" @click="closeInviteUsersModal">
        Dismiss
      </m-m-button>
      <m-m-button
        variant="elevated"
        :is-disabled="isButtonSubmitDisabled"
        :loading="loading"
        @click="submitForm"
      >
        {{ inviteUsersButtonText }}
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
