<script lang="ts" setup>
import { copyToClipboard } from "~/mm_ui_kit/src/helpers/copyToClipboard";
import { computed, ComputedRef, PropType } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  secretKey: {
    type: String,
    default: "",
  },
  clientId: {
    type: String,
    default: "",
  },
  mode: {
    type: String as PropType<
      "app-created" | "secret-created" | "role-based-app-created"
    >,
    default: "",
  },
});

const emit = defineEmits(["close"]);

const title: ComputedRef<string> = computed(() => {
  switch (props.mode) {
    case "app-created":
      return "Your application is successfully created";
    case "secret-created":
      return "Client secret successfully created";
    case "role-based-app-created":
      return "Your role-based application is successfully created";
    default:
      return "Something went wrong";
  }
});

const isModeAppCreated: ComputedRef<boolean> = computed(
  () => props.mode === "app-created",
);

const isModeSecretCreated: ComputedRef<boolean> = computed(
  () => props.mode === "secret-created",
);

const isClientIdVisible: ComputedRef<boolean> = computed(
  () => Boolean(props.clientId) && isModeAppCreated.value,
);

const onCopyClientSecretKey = () => {
  eventBus.$emit("onShowToast", {
    text: "Client secret key has been copied to your clipboard",
    status: "success",
  });
  copyToClipboard(props.secretKey);
};

const onCopyClientId = () => {
  eventBus.$emit("onShowToast", {
    text: "Client ID has been copied to your clipboard",
    status: "success",
  });
  copyToClipboard(props.clientId);
};

const onDialogClose = () => {
  emit("close");
};
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    size="medium"
    :title="title"
    icon="check-green"
    icon-size="auto"
    cy="dialog-secret-successfully-created"
    @close="onDialogClose"
  >
    <template v-if="isModeAppCreated" #subtitle>
      Use the Client ID and Client Secret below in the OpenID Connect settings
      in your application to finalize the connection between your application
      and Veriam. Also see
      <m-m-link
        href="https://docs.myveriam.com/getting-started/connect-your-application#using-openid-connect"
        target="_blank"
      >
        our documentation </m-m-link
      >. You can then continue configuring your access settings.
    </template>
    <template v-else-if="isModeSecretCreated" #subtitle>
      A new Client Secret is successfully created. Update the Client Secret in
      the OpenID Connect settings in your application to make use of it before
      you delete any old Client Secrets.
    </template>
    <div class="mm-flex">
      <m-m-input-readonly
        label="Client secret key"
        :value="secretKey"
        class="mm-flex-grow"
      />
      <m-m-button
        variant="outlined"
        prepend-icon="clipboard"
        icon-stroke="#072e51"
        data-cy="copy-secret-key"
        class="mm-mb-auto mm-ml-8 mm-mt-13"
        @click="onCopyClientSecretKey"
      >
        Copy Client Secret
      </m-m-button>
    </div>

    <m-m-alert
      status="warning"
      data-cy="alert"
      :is-closable="false"
      class="mm-mt-8"
    >
      Please make sure to save your client secret and store it securely. You
      will not be able to retrieve your client secret later.
    </m-m-alert>
    <div v-if="isClientIdVisible" class="mm-mt-16">
      <div class="mm-flex">
        <m-m-input-readonly
          label="Client ID"
          :value="clientId"
          class="mm-flex-grow"
        />
        <m-m-button
          variant="outlined"
          prepend-icon="clipboard"
          icon-stroke="#072e51"
          data-cy="copy-client-id"
          class="mm-mb-auto mm-ml-8 mm-mt-13"
          @click="onCopyClientId"
        >
          Copy Client ID
        </m-m-button>
      </div>
    </div>
    <template #footer>
      <m-m-button data-cy="button-close" @click="onDialogClose">
        Close
      </m-m-button>
    </template>
  </m-m-dialog>
</template>
