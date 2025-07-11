<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref } from "vue";
import { PermissionRead } from "~/service-providers/Permissions/permissions.type";
import { usePermissionsStore } from "~/service-providers/Permissions/permissions.service";
import { useRoute } from "vue-router";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  permission: {
    type: Object as PropType<PermissionRead>,
    default: null,
  },
  isConfigPublishing: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["close", "submit"]);

const route = useRoute();

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () => props.isConfigPublishing || isButtonSaveDisabled.value,
);

const permissionsStore = usePermissionsStore();
const isButtonSaveDisabled: Ref<boolean> = ref(false);
const isSubmitButtonLoading: Ref<boolean> = ref(false);

const submitForm = async () => {
  isButtonSaveDisabled.value = true;
  isSubmitButtonLoading.value = true;

  try {
    await permissionsStore.deletePermission(
      route.params.service_provider_id as string,
      props.permission?.id as string,
    );

    emit("submit");
    emit("close");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting permission",
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
    :title="`Delete ${permission?.name}`"
    subtitle="Are you sure you want to delete this permission?"
    icon="trash"
    icon-color="error"
    cy="dialog-delete-permission"
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
