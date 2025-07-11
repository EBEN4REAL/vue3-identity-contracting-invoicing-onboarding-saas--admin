<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref, watch } from "vue";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import {
  RoleRead,
  TypeRoleForm,
  TypeRoleFormRules,
  TypeValidationRoleCreateEdit,
} from "~/service-providers/Roles/roles.type";
import { useRolesStore } from "~/service-providers/Roles/roles.service";
import { useRoute } from "vue-router";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  role: {
    type: Object as PropType<RoleRead>,
    default: null,
  },
  isConfigPublishing: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["close", "submit"]);

const route = useRoute();

const rolesStore = useRolesStore();

const form: Ref<TypeRoleForm> = ref({
  name: props.role?.name,
  description: props.role?.description,
});
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => props.isConfigPublishing || isButtonSaveDisabled.value,
);

const formRules: TypeRoleFormRules = {
  name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(256)),
  },
};

const v$: TypeValidationRoleCreateEdit = useVuelidate(formRules, form);

const submitForm = async () => {
  v$.value.$validate();

  if (v$.value.$invalid) return;

  isButtonSaveDisabled.value = true;
  isSubmitButtonLoading.value = true;

  try {
    await rolesStore.updateRole(
      route.params.service_provider_id as string,
      props.role?.id as string,
      form.value,
    );

    emit("submit");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error updating role",
      status: "error",
    });
  } finally {
    isButtonSaveDisabled.value = false;
    isSubmitButtonLoading.value = false;
  }
};

const closeModal = () => {
  emit("close");
};

watch(
  () => props.isOpen,
  () => {
    if (!props.isOpen) {
      v$.value.$reset();
    } else {
      form.value = {
        name: props.role?.name,
        description: props.role?.description,
      };
    }
  },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Edit role"
    subtitle="Edit role which can be assigned to policies."
    icon="user-circle"
    cy="dialog-edit-role"
    @close="closeModal"
  >
    <template #default>
      <form v-mm-focus-first class="mm-page-dialog-form">
        <m-m-input
          v-model="form.name"
          label="Name"
          :errors="v$.name.$errors"
          required
          placeholder="Enter name"
          cy="input-name"
          @update:model-value="v$.name.$touch"
          @blur="v$.name.$touch"
        />
        <m-m-input
          v-model="form.description"
          label="Description"
          inputmode="textarea"
          :errors="v$.description.$errors"
          placeholder="Description"
          cy="input-description"
          @blur="v$.description.$touch"
        />
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" @click="closeModal"> Cancel </m-m-button>
      <m-m-button
        variant="elevated"
        cy="button-submit"
        :is-disabled="isButtonSubmitDisabled"
        :loading="isSubmitButtonLoading"
        @click="submitForm"
      >
        Save
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
