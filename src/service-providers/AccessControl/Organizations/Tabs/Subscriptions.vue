<script setup lang="ts">
import { PropType, Ref, ref } from "vue";
import { TableHeader, TableResponse } from "~/mm_ui_kit/src/types/table.types";
import DialogRemoveLicense from "../Dialogs/DialogRemoveLicense.vue";
import DialogAssignSubscription from "../Dialogs/DialogAssignSubscription.vue";
import { ServiceProviderOrganizationRead } from "~/iam/iam.types";
import { SPAgreementRead } from "~/service-providers/Licenses/licenses.types";
import dayjs from "dayjs";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";

const props = defineProps({
  user: {
    type: Object as PropType<ServiceProviderOrganizationRead>,
    required: true,
  },
  serviceProviderId: {
    type: String,
    required: true,
  },
  licenses: {
    type: Object as PropType<TableResponse<SPAgreementRead> | null>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  isSPViewerOnly: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["updateParams", "updateLicenses"]);
const isRemoveLicenseDialogOpen: Ref<boolean> = ref(false);
const isDialogAssignSubscriptionOpen: Ref<boolean> = ref(false);
const dialogRemoveLicenseData: Ref<SPAgreementRead | null> = ref(null);
const key: Ref<number> = ref(0);
const badgeStatus = (license: SPAgreementRead) => {
  if (license && !license.cancelled && !license.active) {
    return BadgeTypes.Warning;
  } else {
    return license.cancelled
      ? BadgeTypes.Cancelled
      : license.active
        ? BadgeTypes.Active
        : BadgeTypes.Inactive;
  }
};

const badgeText = (agreement: SPAgreementRead) =>
  badgeStatus(agreement) == "warning" ? "Pending" : "";
const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Subscription name",
    key: "agreement_name",
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "Effective from date",
    key: "effective_from_date",
  },
  {
    label: "Effective to date",
    key: "valid_until",
  },
  {
    label: "Status",
    key: "cancelled",
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const getDropdownItems = (row: SPAgreementRead): TypeDropdownItem[] => [
  {
    label: "Cancel subscription",
    isDisabled: props.isSPViewerOnly,
    type: "button",
    color: "error",
    onClick: () => handleRemoveLicenseDialog(row),
  },
];

const handleRemoveLicenseDialog = (license: SPAgreementRead) => {
  isRemoveLicenseDialogOpen.value = true;
  dialogRemoveLicenseData.value = license;
};

const licenseDescription = (row: SPAgreementRead) => row.description || "-";

const handleAssignLicenseDialog = () => {
  isDialogAssignSubscriptionOpen.value = true;
};

const updateLicense = () => {
  emit("updateLicenses");
};

const formatDate = (date: string | null) =>
  date ? dayjs(date).format("DD-MMM-YY") : "-";
</script>

<template>
  <div>
    <m-m-expandable-card title="Subscriptions" cy="subscriptions-expandable">
      <m-m-table
        show-search
        background-color="#F2F4F7"
        :is-loading="isLoading"
        :headers="TABLE_HEADERS"
        empty-state="No subscriptions"
        :rows="licenses?.results || []"
        :total-rows="licenses?.total || 0"
        cy="subscriptions-table"
        @update-params="emit('updateParams', $event)"
      >
        <template #empty-state-button>
          <m-m-button
            variant="elevated"
            size="small"
            prepend-icon="plus-white"
            class="mm-ml-auto"
            cy="empty-state-allocate-license"
            :is-disabled="isSPViewerOnly"
            @click="handleAssignLicenseDialog"
          >
            New subscription
          </m-m-button>
        </template>
        <template #action>
          <m-m-button
            variant="outlined"
            size="small"
            prepend-icon="plus"
            class="mm-ml-auto"
            cy="allocate-license"
            :is-disabled="isSPViewerOnly"
            @click="handleAssignLicenseDialog"
          >
            New subscription
          </m-m-button>
        </template>
        <template #agreement_name="{ row }">
          <span class="font-weight-500" :data-cy="`column-name-${row.id}`">
            {{ row.agreement_name }}
          </span>
        </template>
        <template #description="{ row }">
          <m-m-text-ellipsis :data-cy="`column-description-${row.id}`"
            >{{ licenseDescription(row as SPAgreementRead) }}
          </m-m-text-ellipsis>
        </template>
        <template #effective_from_date="{ row }">
          {{ formatDate(row.effective_from_date) }}
        </template>
        <template #valid_until="{ row }">
          {{ formatDate(row.valid_until) }}
        </template>
        <template #cancelled="{ row }">
          <m-m-badge :status="badgeStatus(row)" :text="badgeText(row)" />
        </template>
        <template #actions="{ row }">
          <div class="mm-flex mm-flex-justify-end">
            <m-m-dropdown
              list-side="left"
              :items="getDropdownItems(row)"
              :cy="`actions-dropdown-${row.id}`"
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
    </m-m-expandable-card>
  </div>

  <DialogRemoveLicense
    v-if="serviceProviderId && isRemoveLicenseDialogOpen"
    :is-open="isRemoveLicenseDialogOpen"
    :customer="props.user"
    :license="dialogRemoveLicenseData"
    :service-provider-id="serviceProviderId"
    @close-dialog="isRemoveLicenseDialogOpen = false"
    @update-licenses="updateLicense"
  />
  <DialogAssignSubscription
    v-if="licenses && isDialogAssignSubscriptionOpen"
    :key="key"
    :is-open="isDialogAssignSubscriptionOpen"
    :customer="props.user"
    :service-provider-id="serviceProviderId"
    :licenses="licenses"
    @close-dialog="isDialogAssignSubscriptionOpen = false"
    @update-agreements="updateLicense"
  />
</template>

<style scoped lang="scss"></style>
