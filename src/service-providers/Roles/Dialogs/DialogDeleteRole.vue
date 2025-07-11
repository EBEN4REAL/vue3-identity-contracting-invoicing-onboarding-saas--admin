<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { RoleRead } from "~/service-providers/Roles/roles.type";
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
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => props.isConfigPublishing || isButtonSaveDisabled.value,
);

const submitForm = async () => {
  isButtonSaveDisabled.value = true;
  isSubmitButtonLoading.value = true;

  try {
    await rolesStore.deleteRole(
      route.params.service_provider_id as string,
      props.role?.id as string,
    );

    emit("submit");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting role",
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
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="`Delete ${role?.name}`"
    subtitle="Are you sure you want to delete this role?"
    icon="trash"
    icon-color="error"
    cy="dialog-delete-role"
    @close="closeModal"
  >
    <template #footer>
      <m-m-button variant="outlined" @click="closeModal"> Cancel </m-m-button>
      <m-m-button
        variant="danger"
        cy="button-submit"
        :is-disabled="isButtonSubmitDisabled"
        :loading="isSubmitButtonLoading"
        @click="submitForm"
      >
        Yes, delete
        <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
          Config is currently being published.
        </m-m-tooltip>
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
