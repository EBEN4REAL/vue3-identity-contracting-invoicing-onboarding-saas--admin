<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { authService } from "~/auth/auth.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
} from "~/mm_ui_kit/src/types/table.types";
import router from "~/router/index.router";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import DialogAssignPolicies from "~/service-providers/ApplicationDetails/Dialogs/DialogAssignPolicies.vue";
import DialogConfirmDeleteApplication from "~/service-providers/ApplicationDetails/Dialogs/DialogConfirmDeleteApplication.vue";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import {
  OauthClientRead,
  PaginationSchema_OauthClientRead_,
} from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "./ConfigPublish/enums";
import { useFlag } from "@unleash/proxy-client-vue";
import { useTranslation } from "i18next-vue";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "./ConfigPublishBanner/ConfigPublishBanner.vue";
import { useUiStore } from "~/stores/useUiStore";

const { t } = useTranslation();

const uiStore = useUiStore();

const isCWApplicationRoleBased = useFlag("cw_application_wizard");

const serviceProviderId: Ref<string | null> = ref(null);
const isSPAdmin: Ref<boolean> = ref(false);
const isSPEditor: Ref<boolean> = ref(false);
const isLoading: Ref<boolean> = ref(true);
const oauthClients: Ref<PaginationSchema_OauthClientRead_ | null> = ref(null);
const isDialogAssignPoliciesOpen: Ref<boolean> = ref(false);
const applicationForPolicyAssignment: Ref<OauthClientRead | null> = ref(null);
const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const emptyState: EmptyStateType = {
  title: "Create your application",
  icon: "applications-icon",
  description: "Configure and connect your application with Veriam",
  learnMoreHref:
    "https://docs.myveriam.com/getting-started/connect-your-application",
};
const formatResponseType = (row: OauthClientRead) => {
  if (row.grant_type.includes("authorization_code")) return "Website";
  else if (row.grant_type.includes("refresh_token")) return "Api";
  return "Invalid grant type";
};

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const deleteApplicationConfigHintText: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this application as config is currently being published"
    : "",
);

const isApplicationDeletable = (application: OauthClientRead): boolean =>
  application?.deletable ?? true;

const isApplicationEditable = (application: OauthClientRead): boolean =>
  application?.editable ?? true;

const dropdownItems = (application: OauthClientRead): TypeDropdownItem[] => [
  {
    label: "View",
    type: "link",
    to: `/sp/${serviceProviderId.value}/applications/${application.id}`,
  },
  {
    label: "Edit",
    type: "link",
    isDisabled: uiStore.isSPViewerOnly,
    hint: isConfigPublishing.value
      ? "You cannot edit this application as config is currently being published"
      : "",
    isDisabled: !isApplicationEditable(application) || isConfigPublishing.value,
    to: `/sp/${serviceProviderId.value}/applications/${application.id}`,
  },
  {
    label: "Assign policy",
    isDisabled: uiStore.isSPViewerOnly,
    type: "button",
    onClick: () => {
      handleApplicationForPolicyAssignment(application.id);
      onDialogAssignPoliciesOpen();
    },
  },
  {
    label: "Delete",
    type: "button",
    isDisabled: uiStore.isSPViewerOnly,
    color: "error",
    isDisabled:
      isConfigPublishing.value || !isApplicationDeletable(application),
    hint: deleteApplicationConfigHintText.value,
    onClick: () => {
      handleApplicationForPolicyAssignment(application.id);
      handleConfirmDelete();
    },
  },
];

const handleActionButton = () => {
  oAuthClientsService.state.oAuthClient = null;
  router.replace(`/sp/${serviceProviderId.value}/applications/new`);
};

const handleConfirmDelete = () => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
};

const onDialogAssignPoliciesOpen = () => {
  isDialogAssignPoliciesOpen.value = true;
};

const handleApplicationForPolicyAssignment = (id: string) => {
  applicationForPolicyAssignment.value =
    oauthClients.value?.results.find((oauthClient) => oauthClient.id === id) ||
    null;

  oAuthClientsService.state.oAuthClient = applicationForPolicyAssignment.value;
};

const onDialogUnassignPoliciesClose = () => {
  isDialogAssignPoliciesOpen.value = false;
};

// GET APPLICATIONS DATA
const getOAuthClients = async (
  params: TableRequestParams = {
    limit: ITEMS_PER_PAGE[0],
    offset: "0",
  },
) => {
  if (!serviceProviderId.value) {
    return;
  }
  isLoading.value = true;
  const response = await oAuthClientsService.getServiceProviderOauthClients(
    serviceProviderId.value,
    params,
  );
  isLoading.value = false;
  if (response?.results?.length) {
    response?.results.forEach((application) => {
      application.hidden = application?.wizard?.hidden || false;
    });
  }
  oauthClients.value = response;
};
const onDialogDeleteApplicationClose = async () => {
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
  isConfirmDeleteDialogOpen.value = false;
};

const handleUpdateParams = async (params: TableRequestParams) => {
  const userProfile = await authService.getProfile();
  if (serviceProviderId.value == null) {
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
    }
  }
  getOAuthClients(params);
};
const detailedViewLink = (row: OauthClientRead) =>
  `/sp/${serviceProviderId.value}/applications/${row?.id}`;

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  isSPAdmin.value = await authService.isUserSPAdmin();
  isSPEditor.value = await authService.isUserSPEditor();
});

// TABLE CONFIG
const TABLE_HEADERS: ComputedRef<TableHeader[]> = computed(() => [
  {
    label: t("configuration.applications.overview.table_headers.name"),
    key: "name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "name",
  },
  {
    label: t("configuration.applications.overview.table_headers.description"),
    key: "description",
    sortable: false,
  },
  {
    label: t("configuration.applications.overview.table_headers.url"),
    key: "url",
  },
  {
    label: t("configuration.applications.overview.table_headers.type"),
    key: "type",
    sortable: false,
  },
  {
    label: t("configuration.applications.overview.table_headers.created_date"),
    key: "created_date",
    sortable: true,
    sortIcon: true,
    order: "desc",
    sortName: "created_date",
    defaultSortItem: true,
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
]);

const createDropdownItems: ComputedRef<Button[]> = computed(() => {
  const items = [];

  if (isCWApplicationRoleBased.value) {
    items.push({
      key: "new_application_with_roles",
      isDisabled: uiStore.isSPViewerOnly,
      action: () => {
        router.push(`/sp/application/role-based-wizard`);
      },
    });
  }

  items.push({
    key: "new_advanced_application",
    isDisabled: uiStore.isSPViewerOnly,
    action: () => {
      router.push(`/sp/${serviceProviderId.value}/applications/new`);
    },
  });

  return items;
});

const buttonsWithEnabledCWFlag: ComputedRef<Record<string, unknown>[]> =
  computed(() => [
    {
      key: "add_button",
      isDropdown: true,
      dropdownItems: createDropdownItems.value,
      isDisabled: !!isConfigPublishing.value || uiStore.isSPViewerOnly,
      tooltipText: isConfigPublishing.value
        ? "Config is currently being published."
        : "",
    },
  ]);

const buttonWithDisabledCWFlag: ComputedRef<Record<string, unknown>[]> =
  computed(() => [
    {
      key: "add_button",
      isDisabled: !!isConfigPublishing.value || uiStore.isSPViewerOnly,
      action: () => {
        router.push(`/sp/${serviceProviderId.value}/applications/new`);
      },
    },
  ]);

const buttons: ComputedRef<Record<string, unknown>[]> = computed(() =>
  isCWApplicationRoleBased.value
    ? buttonsWithEnabledCWFlag.value
    : buttonWithDisabledCWFlag.value,
);
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="applications"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <div class="mm-applications">
      <m-m-table
        show-search
        :is-loading="isLoading"
        :headers="TABLE_HEADERS"
        :rows="oauthClients?.results"
        :total-rows="oauthClients?.total"
        cy="applications-table"
        :empty-state="emptyState"
        @update-params="handleUpdateParams"
      >
        <template #empty-state-button>
          <m-m-button
            cy="empty-state-button-add-aplication"
            size="small"
            prepend-icon="plus-white"
            :is-disabled="isConfigPublishing"
            @click="handleActionButton"
          >
            Add application
            <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
              Config is currently being published.
            </m-m-tooltip>
          </m-m-button>
        </template>
        <template #name="{ row }">
          <m-m-link
            :to="detailedViewLink(row)"
            font-weigth="500"
            :cy="`name-${row?.id}`"
          >
            {{ row.name }}
          </m-m-link>
        </template>
        <template #description="{ row }">
          <m-m-text-ellipsis max-width="350px">{{
            row.description
          }}</m-m-text-ellipsis>
        </template>
        <template #created_date="{ row }">
          <m-m-formatted-date
            :raw-date="row.created_date"
            format="D MMM YYYY, HH:mm"
          />
        </template>
        <template #url="{ row }">
          <m-m-link :href="row.url ? (row.url as string) : ''">
            <m-m-text-ellipsis max-width="200px">{{
              row.url
            }}</m-m-text-ellipsis>
          </m-m-link>
        </template>
        <template #type="{ row }">
          {{ formatResponseType(row) }}
        </template>
        <template #actions="{ row }">
          <div class="mm-flex mm-flex-justify-end">
            <m-m-dropdown
              list-side="left"
              :items="dropdownItems(row)"
              :cy="`actions-dropdown-${row.id}`"
              max-width="218px"
            >
              <template #activator>
                <m-m-button
                  prepend-icon="dots-vertical"
                  variant="text"
                  :cy="`actions-${row.id}`"
                />
              </template>
            </m-m-dropdown>
          </div>
        </template>
      </m-m-table></div
  ></m-m-overview-page>
  <dialog-assign-policies
    v-if="serviceProviderId && applicationForPolicyAssignment?.id"
    :is-open="isDialogAssignPoliciesOpen"
    :service-provider-id="serviceProviderId"
    :application-id="applicationForPolicyAssignment.id"
    :application-name="applicationForPolicyAssignment.name"
    @update="getOAuthClients"
    @close="onDialogUnassignPoliciesClose"
  />
  <dialog-confirm-delete-application
    v-if="serviceProviderId && applicationForPolicyAssignment?.id"
    :is-open="isConfirmDeleteDialogOpen"
    :service-provider-id="serviceProviderId"
    @close="onDialogDeleteApplicationClose"
    @submit="getOAuthClients"
  />
  <!--Can be removed once we have translations -->
  <m-m-config-banner />
</template>

<style scoped lang="scss">
.mm-applications {
  &-header {
    display: flex;
    justify-content: space-between;
  }
}

.url-list {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: flex-start;
}
</style>
