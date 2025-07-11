<script lang="ts" setup>
import { ref, reactive, Ref } from "vue";
import { useVuelidate } from "@vuelidate/core";
import { required, helpers, maxLength } from "@vuelidate/validators";
import {
  TypeCreateOrganizationGroupForm,
  TypeValidatorCreateOrganizationGroup,
} from "~/organizations/organizations.types";
import { TypeEditOrganizationGroupFormRules } from "~/organizations/OrganizationGroups/types";

const form = reactive<TypeCreateOrganizationGroupForm>({
  name: "",
  description: "",
});

const formRules: TypeEditOrganizationGroupFormRules = {
  name: {
    required: helpers.withMessage("Policy name is required", required),
    maxLength: helpers.withMessage("Policy name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage(
      "Too long policy description",
      maxLength(256),
    ),
  },
};

const v$: TypeValidatorCreateOrganizationGroup = useVuelidate(formRules, form);

const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const isSaving: Ref<boolean> = ref(false);

defineProps({
  isOpen: Boolean,
  serviceProviderId: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["close", "submit"]);

const submitForm = async () => {
  const result = await v$.value.$validate();

  if (!result) {
    return;
  }

  emit("submit", form);
};

const resetForm = () => {
  setTimeout(() => {
    form.name = "";
    form.description = "";
    isAlertVisible.value = false;
    alertText.value = "";
  }, 100);
  v$.value.$reset();
};

const closeModal = () => {
  resetForm();
  emit("close");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Create policy"
    icon="shield-plus"
    cy="create-child-policy-type-dialog"
    @close="closeModal"
  >
    <template #default>
      <m-m-alert
        v-if="isAlertVisible"
        status="error"
        cy="create-child-policy-type-alert"
        class="mm-mb-12"
        @close="isAlertVisible = false"
      >
        {{ alertText }}
      </m-m-alert>
      <form
        v-mm-focus-first
        class="mm-page-dialog-form"
        data-cy="create-child-policy-type-dialog"
      >
        <div>
          <m-m-input
            v-model="form.name"
            label="Policy Name"
            :errors="v$.name.$errors"
            required
            placeholder="Enter Policy Name"
            cy="create-child-policy-type"
            @update:model-value="v$.name.$touch"
            @blur="v$.name.$touch"
          />
        </div>
        <div>
          <m-m-input
            v-model="form.description"
            label="Description"
            inputmode="textarea"
            :errors="v$.description.$errors"
            placeholder="Write something about this policy..."
            cy="create-child-policy-type-description"
            @blur="v$.description.$touch"
          />
        </div>
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" @click="closeModal"> Dismiss </m-m-button>
      <m-m-button
        variant="elevated"
        cy="create-child-policy-type-submit-button"
        :loading="isSaving"
        prepend-icon="plus-white"
        @click="submitForm"
      >
        Create child policy
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
