<script setup lang="ts">
import { computed, ComputedRef } from "vue";
import type { TypeDataIteratorItem } from "~/mm_ui_kit/src/types/dataIterator.types";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { useTranslation } from "i18next-vue";

const { t } = useTranslation();

const isMFARequired: ComputedRef<boolean> = computed(
  () => oAuthClientsService.state.oAuthClient?.mfa_required ?? false,
);

const mfaBadgeStatus: ComputedRef<string> = computed(() =>
  isMFARequired.value ? BadgeTypes.Active : BadgeTypes.Inactive,
);

const translationKey =
  "configuration.applications.application_details.tab_settings.sections.basic_info.fields";

const dataIteratorData: ComputedRef<TypeDataIteratorItem[]> = computed(() => [
  {
    key: "name",
    label: t(`${translationKey}.app_name.label`),
    labelTooltip: t(`${translationKey}.app_name.label_tooltip`),
    text: oAuthClientsService.state.oAuthClient?.name,
    isEmpty: !oAuthClientsService.state.oAuthClient?.name,
  },
  {
    key: "description",
    label: t(`${translationKey}.description.label`),
    labelTooltip: t(`${translationKey}.description.label_tooltip`),
    text: oAuthClientsService.state.oAuthClient?.description,
    isEmpty: !oAuthClientsService.state.oAuthClient?.description,
  },
  {
    key: "url",
    label: t(`${translationKey}.url.label`),
    labelTooltip: t(`${translationKey}.url.label_tooltip`),
    isEmpty: !oAuthClientsService.state.oAuthClient?.url,
    emptyText: "Not added",
    informationType: "redirect",
    information: `${oAuthClientsService.state.oAuthClient?.url}`,
    informationRedirect: `${oAuthClientsService.state.oAuthClient?.url}`,
  },

  {
    key: "grant_type",
    label: t(`${translationKey}.type.label`),
    labelTooltip: t(`${translationKey}.type.label_tooltip`),
    text: oAuthClientsService.state.oAuthClient?.grant_type,
    isEmpty: !oAuthClientsService.state.oAuthClient?.grant_type,
  },
  {
    key: "mfa_required",
    label: t(`${translationKey}.required_mfa.label`),
    labelTooltip: t(`${translationKey}.required_mfa.label_tooltip`),
    text: isMFARequired.value ? "Yes" : "No",
    hasBadge: true,
    badgeText: isMFARequired.value ? "Yes" : "No",
    badgeStatus: mfaBadgeStatus.value,
  },
]);
</script>

<template>
  <m-m-data-iterator :data="dataIteratorData" :columns="2" />
</template>
