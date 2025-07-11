<script setup lang="ts">
import { computed, ComputedRef } from "vue";
import { copyToClipboard } from "~/mm_ui_kit/src/helpers/copyToClipboard";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import type { TypeDataIteratorItem } from "~/mm_ui_kit/src/types/dataIterator.types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { useTranslation } from "i18next-vue";

const { t } = useTranslation();

const translationKey =
  "configuration.applications.application_details.tab_settings.sections.connection_config.fields";
import config from "~/mm.config.json";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";

const props = defineProps({
  openIdUrl: {
    type: String,
    default: "",
  },
});

const dataIteratorData: ComputedRef<TypeDataIteratorItem[]> = computed(() => {
  const redirectUrls =
    oAuthClientsService.state.oAuthClient?.authorized_redirect_uris?.map(
      (url) => ({
        text: url,
        hasCopyText: true,
        hasTooltip: true,
        textType: "Signup URL",
        tooltipText:
          "Use a direct signup URL to redirect users to signup for a Veriam account for your application without requiring a redirect from the application",
        copyText: "Copy direct signup URL",
        hiddenCopyText: `${config.idp.url}/oauth2/authorize?client_id=${oAuthClientsService.state.oAuthClient?.id}&redirect_uri=${url}&response_type=code&state=0&screen_hint=signup`,
        informationAction: "copyOpenIdUrl",
      }),
    );
  return [
    {
      key: "client_id",
      label: "Client ID",
      labelTooltip: t(`${translationKey}.client_id.label_tooltip`),
      text: oAuthClientsService.state.oAuthClient?.id,
      isEmpty: Boolean(!oAuthClientsService.state.oAuthClient?.id?.length),
      emptyText: "Not added",
    },
    {
      key: "config_url",
      label: "Copy Veriam open ID URL",
      labelTooltip: t(`${translationKey}.config_url.label_tooltip`),
      text: props.openIdUrl,
      isEmpty: !props.openIdUrl,
      emptyText: "Not added",
      information: null,
      informationType: "action",
      informationAction: "copyOpenIdUrl",
      informationIcon: null,
    },
    {
      key: "redirect_url",
      label: "Redirect URL(s)",
      labelTooltip: t(`${translationKey}.redirect_url.label_tooltip`),
      text: redirectUrls,
      textType: "LIST",
      isEmpty:
        !oAuthClientsService.state.oAuthClient?.authorized_redirect_uris!
          .length,
      information: null,
      informationType: "redirect",
      multiple: true,
    },
  ];
});

const copyOpenIdUrl = () => {
  copyToClipboard(props.openIdUrl);
  eventBus.$emit("onShowToast", {
    text: "Veriam open ID URL has been copied to your clipboard",
    status: "info",
  });
};

const handleSignupUrlCopyText = (signupUrl: string) => {
  copyToClipboard(signupUrl);
  showToast({
    text: "Direct signup URL copied to your clipboard.",
    status: "success",
    duration: 4000,
  });
};
</script>

<template>
  <m-m-data-iterator
    :data="dataIteratorData"
    cy-id-text="application-details-item-text"
    :columns="2"
    @on:copytext="handleSignupUrlCopyText"
    @do:action="copyOpenIdUrl"
  />

  <div
    class="form-container mm-flex mm-flex-column mm-flex-gap-12"
    data-cy="client-secrets"
  >
    <div
      v-for="clientSecret in oAuthClientsService.state.oAuthClient?.secrets"
      :key="clientSecret.id"
      :data-cy="`client-secret-${clientSecret.id}`"
      class="mm-flex mm-flex-align-center"
    >
      <div class="client-secret-field">
        <div class="mm-page-item-label">Client secret</div>
        <m-m-formatted-date
          :raw-date="clientSecret.created_date"
          format="DD MMM YYYY HH:mm"
          :utc-offset="0"
        />
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.form-container {
  width: calc(100% - 50px);
  margin: 0 10px 20px;
}
</style>
