<script setup lang="ts">
import { ref, Ref, defineProps, PropType, computed, ComputedRef } from "vue";
import { useRouter } from "vue-router";
import { useFlag } from "@unleash/proxy-client-vue";
import { policiesService } from "~/service-providers/policies.service";
import { SPAgreementRead } from "~/service-providers/Licenses/licenses.types";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { badgeStatus, badgeText } from "~/mm_ui_kit/src/helpers/agreementUtils";
import { ITEMS_PER_PAGE } from "~/common/constants";
import DialogCancelLicense from "../Dialogs/DialogCancelLicense.vue";
import { sectionIcons } from "~/mm_ui_kit/src/helpers/iconsMap";
import DialogAllocateLicense from "~/service-providers/Licenses/Dialogs/DialogAllocateAgreement.vue";
import { defaultSortItem } from "~/mm_ui_kit/src/helpers/defaultSortItem";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";

const router = useRouter();
const licenseDetailsEnabled = useFlag("license_details_page");
const isAllocateLicenseDialogOpen: Ref<boolean> = ref(false);

const props = defineProps({
  items: {
    type: Object as PropType<TableResponse<SPAgreementRead> | null>,
    default: null,
  },
  serviceProviderId: {
    type: String,
    required: true,
    default: "",
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
});

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isCancelLicenseDialogOpen: Ref<boolean> = ref(false);
const dialogCancelLicenseData: Ref<SPAgreementRead | null> = ref(null);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const emit = defineEmits(["update"]);

const emptyState: EmptyStateType = {
  icon: sectionIcons["accessLicense"],
  title: "Allocate your first license",
  description:
    "This allows the organization to manage which of their users have access to the policies in the access license.",
  learnMoreHref:
    "https://docs.myveriam.com/getting-started/provide-access-to-customers#provide-a-free-license",
};

const TABLE_HEADERS: TableHeader[] = [
  {
    key: "agreement_name",
    sortName: "name",
    label: "License name",
    sortable: true,
    sortIcon: true,
    order: "asc",
  },
  {
    key: "service_consumer_name",
    label: "Customer",
  },
  {
    key: "created_date",
    label: "Created date",
    sortable: true,
    sortIcon: true,
    order: "desc",
    defaultSortItem: true,
  },
  {
    key: "effective_from_date",
    label: "Effective from",
    sortable: true,
    sortIcon: true,
    order: "desc",
  },
  {
    key: "valid_until",
    label: "Effective to",
  },
  {
    key: "cancelled",
    label: "Status",
    sortable: false,
    filter: {
      type: "select",
      options: [
        { label: "Active", value: "false" },
        { label: "Cancelled", value: "true" },
      ],
    },
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const dropdownItems = (row: SPAgreementRead) => {
  const dropdownActions = [
    {
      isHidden: !licenseDetailsEnabled,
      label: "View license",
      type: "button",
      onClick: () => {
        router.push(`/sp/access-control/access-license/${row.id}`);
      },
    },
  ];

  if (!row?.cancelled) {
    dropdownActions.push({
      label: "Cancel license",
      color: "error",
      type: "button",
      onClick: () => handleCancelLicenseDialog(row),
    });
  }

  return dropdownActions;
};

const handleCancelLicenseDialog = (license: SPAgreementRead) => {
  isCancelLicenseDialogOpen.value = true;
  dialogCancelLicenseData.value = license;
};

const handleLicenseCancel = async (license: SPAgreementRead) => {
  await policiesService.cancelAgreements(props.serviceProviderId, license.id);
  isCancelLicenseDialogOpen.value = false;

  emit("update", initialQueryParams.value);
};

const detailedView = (row: SPAgreementRead) =>
  `/sp/access-control/access-license/${row?.id}`;

const initialQueryParams = ref<TableRequestParams>({
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
  sort: defaultSortItem(TABLE_HEADERS),
});

const handleUpdateParams = (params?: TableRequestParams) => {
  emit("update", {
    ...initialQueryParams.value,
    ...params,
  });
};
</script>

<template>
  <section class="mm-access-control-allocated-licenses">
    <m-m-table
      cy="access-control-allocated-licenses-table"
      :is-loading="isLoading"
      :rows="items?.results || []"
      :headers="TABLE_HEADERS"
      description="Licenses allocated to accounts"
      :total-rows="items?.total || 0"
      show-search
      :empty-state="emptyState"
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          size="small"
          prepend-icon="plus-white"
          cy="empty-state-button-open-licenses"
          :is-disabled="isConfigPublishing"
          @click="isAllocateLicenseDialogOpen = true"
        >
          Allocate license
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </template>
      <template #action>
        <m-m-button
          variant="outlined"
          size="small"
          prepend-icon="plus"
          cy="button-open-licenses"
          :is-disabled="isConfigPublishing"
          @click="isAllocateLicenseDialogOpen = true"
        >
          Allocate license
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </template>
      <template #agreement_name="{ row }">
        <m-m-link
          v-if="licenseDetailsEnabled"
          :to="detailedView(row)"
          font-weigth="500"
          :cy="`name-${row?.id}`"
        >
          {{ row.agreement_name }}
        </m-m-link>
        <div v-else>
          {{ row.agreement_name }}
        </div>
      </template>
      <template #service_consumer_name="{ row }">
        <span>
          {{ row.service_consumer_name }}
        </span>
      </template>
      <template #created_date="{ row }">
        <m-m-formatted-date :raw-date="row.created_date" />
      </template>
      <template #effective_from_date="{ row }">
        <m-m-formatted-date :raw-date="row.effective_from_date" />
      </template>
      <template #valid_until="{ row }">
        <m-m-formatted-date :raw-date="row.valid_until" />
      </template>
      <template #cancelled="{ row }">
        <span>
          {{ row.status }}
        </span>
        <m-m-badge
          :status="badgeStatus(row)"
          :text="badgeText(row)"
          indicator
        />
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="dropdownItems(row)"
            :cy="`actions-dropdown-${row.service_consumer_id}`"
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
    </m-m-table>
    <DialogCancelLicense
      :is-open="isCancelLicenseDialogOpen"
      @close-dialog="isCancelLicenseDialogOpen = false"
      @submit-dialog="
        dialogCancelLicenseData && handleLicenseCancel(dialogCancelLicenseData)
      "
    />
    <DialogAllocateLicense
      :is-open="isAllocateLicenseDialogOpen"
      :is-access-license="true"
      @close-dialog="isAllocateLicenseDialogOpen = false"
      @update-list="handleUpdateParams"
    />
  </section>
</template>
