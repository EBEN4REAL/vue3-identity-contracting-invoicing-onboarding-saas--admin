<script lang="ts" setup>
import { ref, Ref, watch, computed } from "vue";
import { helpers, maxLength, email, required } from "@vuelidate/validators";
import {
  TypeCreateOrganizationForm,
  CreateOrganizationFormRules,
} from "~/service-providers/AccessControl/Organizations/Organizations.types";
import useVuelidate from "@vuelidate/core";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { emailValidator } from "~/mm_ui_kit/src/helpers/emailValidator";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";
import { TypeToastStatuses } from "~/mm_ui_kit/src/types/toast.types";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  selectedOrganization: {
    type: String,
    default: null,
  },
  serviceProviderId: { type: String, default: "" },
  context: { type: String, default: "account" },
});

const isButtonSubmitDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);

const newCustomer: Ref<TypeCreateOrganizationForm> = ref({
  name: props?.selectedOrganization || "",
  admin_email: "",
  user_emails: [],
});

const formRules: CreateOrganizationFormRules = {
  name: {
    required: helpers.withMessage("Account name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  admin_email: {
    required: helpers.withMessage("Admin email address is required", required),
    email: helpers.withMessage("Please enter a valid email address", email),
  },
  user_emails: {
    emails: helpers.withMessage(
      "Check the format of email address(es)",
      emailValidator,
    ),
  },
};
const v$ = useVuelidate(formRules, newCustomer);

const emit = defineEmits(["close", "submit", "on:create-customer"]);

const submit = async () => {
  v$.value.$touch();

  if (v$.value.$invalid) return;

  try {
    isButtonSubmitDisabled.value = true;
    isButtonSubmitLoading.value = true;
    const response = await serviceProvidersService.createCustomer(
      props.serviceProviderId,
      newCustomer.value,
    );
    showToast({
      text: response?.was_created
        ? `${props.selectedOrganization ? "Users added successfully" : `${props.context} was created`}`
        : "Account added",
      status: "success",
    });

    emit("close");
    emit("submit");
    if (props.selectedOrganization)
      emit("on:create-customer", response.organization);
  } catch (error) {
    if (error?.response?.status === 409) {
      const formattedContext =
        props.context.charAt(0).toUpperCase() + props.context.slice(1);
      showToast({
        text: `${formattedContext} already exists`,
        status: TypeToastStatuses.Warning,
        duration: 5000,
      });
      return;
    }
    eventBus.$emit("onShowToast", {
      text: "Error creating organization",
      status: "error",
    });
  } finally {
    isButtonSubmitDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

const subtitle = computed(() => {
  return `Create ${props.context === "account" ? `an ${props.context.toLowerCase()}` : `a ${props.context.toLowerCase()}`} manually and invite ${props.context.toLowerCase()} users`;
});

watch(
  () => props.isOpen,
  () => {
    newCustomer.value = {
      name: props.selectedOrganization || "",
      admin_email: "",
      user_emails: [],
    };
    v$.value.$reset();
  },
);

defineExpose({
  v$,
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    size="large"
    :title="`Create ${context}`"
    :subtitle="subtitle"
    icon="user-plus"
    cy="dialog-create-customer"
    @close="emit('close')"
  >
    <template #default>
      <form v-mm-focus-first class="mm-page-dialog-form">
        <m-m-input
          v-model="newCustomer.name"
          :required="true"
          cy="input-create-customer-organization"
          label="Account name"
          :errors="v$.name.$errors"
          placeholder="Account name"
          @update:model-value="v$.name.$touch"
          @keyup.enter="submit"
        />
        <div>
          <m-m-input
            v-model="newCustomer.admin_email"
            :required="true"
            cy="input-create-customer-admin-email"
            label="Admin email address"
            :errors="v$.admin_email.$errors"
            placeholder="Admin email address"
            @keyup.enter="submit"
          />
          <div
            class="mm-page-subtitle mm-page-subtitle--h2 mm-flex mm-flex-align-center mm-flex-gap-2"
          >
            <m-m-icon icon="info" width="15px" height="15px" stroke="#475467" />
            All account related communications and the first user will be
            created with this email address.
          </div>
        </div>
        <m-m-tags-input
          v-model="newCustomer.user_emails"
          label="Email address for users"
          cy="input-create-cutomer-user-emails"
          placeholder="Add one or more email addresses"
          type="email"
          :errors="v$.user_emails.$errors"
          @blur="v$.user_emails.$touch"
        />
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="emit('close')">
        Cancel
      </m-m-button>
      <m-m-button
        variant="elevated"
        :disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        cy="button-submit"
        prepend-icon="plus-white"
        @click="submit"
      >
        Create
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss">
.icon-background {
  background-color: #f4f5f7;
  padding: 8px;
  border-radius: 8px;
}
</style>
