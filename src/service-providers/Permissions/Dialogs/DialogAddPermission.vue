<script setup lang="ts">
import { computed, ComputedRef, reactive, ref, Ref, watch } from "vue";
import { helpers, maxLength, required } from "@vuelidate/validators";
import { useVuelidate } from "@vuelidate/core";
import {
  TypePermissionForm,
  TypePermissionFormRules,
  TypeValidationPermissionCreateEdit,
} from "~/service-providers/Permissions/permissions.type";
import { usePermissionsStore } from "~/service-providers/Permissions/permissions.service";
import { useRoute } from "vue-router";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  isConfigPublishing: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["close", "submit"]);

const route = useRoute();

const permissionsStore = usePermissionsStore();

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => props.isConfigPublishing || isButtonSaveDisabled.value,
);

const form = reactive<TypePermissionForm>({
  name: "",
  description: "",
});
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);

const formRules: TypePermissionFormRules = {
  name: {
    required: helpers.withMessage("Name is required", required),
    maxLength: helpers.withMessage("Name is too long", maxLength(64)),
  },
  description: {
    maxLength: helpers.withMessage("Description is too long", maxLength(256)),
  },
};

const v$: TypeValidationPermissionCreateEdit = useVuelidate(formRules, form);

const submitForm = async () => {
  v$.value.$validate();

  if (v$.value.$invalid) return;

  isButtonSaveDisabled.value = true;
  isSubmitButtonLoading.value = true;

  try {
    await permissionsStore.createPermission(
      route.params.service_provider_id as string,
      form,
    );

    emit("submit");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error adding permission",
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

const onFormFieldBlur = (field: keyof TypePermissionForm) => {
  if (form[field]) v$.value[field].$touch();
};

watch(
  () => props.isOpen,
  () => {
    if (!props.isOpen) {
      form.name = "";
      form.description = "";
      v$.value.$reset();
    }
  },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    title="Create permission"
    subtitle="Add a permission which can be assigned to policies."
    icon="user-circle"
    cy="dialog-add-permission"
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
          @blur="onFormFieldBlur('name')"
        />
        <m-m-input
          v-model="form.description"
          label="Description"
          inputmode="textarea"
          :errors="v$.description.$errors"
          placeholder="Description"
          cy="input-description"
          @blur="onFormFieldBlur('description')"
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
        Create
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
