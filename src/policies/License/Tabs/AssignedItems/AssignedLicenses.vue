<script setup lang="ts">
import { computed, ComputedRef, Ref, ref } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { badgeStatus, badgeText } from "~/mm_ui_kit/src/helpers/agreementUtils";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { SPAgreementRead } from "~/service-providers/Licenses/licenses.types";
import { policiesService } from "~/service-providers/policies.service";
import DialogCreateAgreement from "../../Dialogs/DialogCreateAgreement.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();
const router = useRouter();
const route = useRoute();
const props = defineProps({
  serviceProviderId: {
    type: String,
    default: "",
  },
  licenseName: {
    type: String,
    default: "",
  },
  isAgreementPublished: {
    type: Boolean,
    default: false,
  },
  noDefaultPolicies: {
    type: Boolean,
    default: false,
  },
});

const isLoading = ref(false);
const isDialogCreateAgreementOpen = ref(false);
const assignedLicenses: Ref<TableResponse<SPAgreementRead> | null> = ref(null);
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

const isButtonAllocateLicenseDisabled: ComputedRef<boolean> = computed(
  () =>
    props.isAgreementPublished ||
    props.noDefaultPolicies ||
    uiStore.isSPViewerOnly,
);

const getAssignedLicenses = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    if (!props.serviceProviderId) return;
    const requestParams = {
      category: "ACCESS",
      agreement_type_ids: route.params.license_id.toString(),
      ...(params || { limit: ITEMS_PER_PAGE[0], offset: "0" }),
    };
    assignedLicenses.value = await policiesService.getAgreements(
      props.serviceProviderId,
      requestParams,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching assigned licenses",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="mm-flex mm-flex-justify-end mm-mb-10">
    <m-m-button
      variant="outlined"
      size="small"
      prepend-icon="plus"
      cy="button-allocate-item"
      :disabled="isButtonAllocateLicenseDisabled"
      @click="isDialogCreateAgreementOpen = true"
    >
      Allocate license
      <m-m-tooltip v-if="!isAgreementPublished" display-position="toLeft"
        >You cannot assign this item as it needs to be published
        first</m-m-tooltip
      >
      <m-m-tooltip v-if="noDefaultPolicies" display-position="toLeft"
        >Can't allocate this license because there are no default policies
        attached. Attach a default policy first and then you can assign
        it.</m-m-tooltip
      >
    </m-m-button>
  </div>
  <m-m-table
    :is-loading="isLoading"
    :headers="TABLE_HEADERS"
    :rows="assignedLicenses?.results"
    :total-rows="assignedLicenses?.total"
    empty-state="No licenses"
    cy="assigned-licenses-table"
    @update-params="getAssignedLicenses"
  >
    <template #empty-state-button>
      <m-m-button
        variant="elevated"
        size="small"
        prepend-icon="plus-white"
        cy="empty-state-button-allocate-item"
        :is-disabled="isButtonAllocateLicenseDisabled"
        @click="isDialogCreateAgreementOpen = true"
      >
        Allocate license
        <m-m-tooltip v-if="!isAgreementPublished" display-position="center"
          >You cannot assign this item as it needs to be published
          first</m-m-tooltip
        >
        <m-m-tooltip v-if="noDefaultPolicies" display-position="center"
          >Can't allocate this license because there are no default policies
          attached. Attach a default policy first and then you can assign
          it.</m-m-tooltip
        >
      </m-m-button>
    </template>
    <template #agreement_name="{ row }">
      <m-m-link
        :to="`/sp/access-control/access-license/${row.id}`"
        font-weigth="500"
        :cy="`name-${row?.id}`"
      >
        {{ row.agreement_name }}
      </m-m-link>
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
      <m-m-badge :status="badgeStatus(row)" :text="badgeText(row)" indicator />
    </template>
    <template #actions="{ row }">
      <div class="mm-flex mm-flex-justify-end">
        <m-m-dropdown
          list-side="left"
          :items="[
            {
              label: 'View details',
              type: 'button',
              onClick: () => {
                router.push(`/sp/access-control/access-license/${row.id}`);
              },
            },
          ]"
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
  <DialogCreateAgreement
    v-if="isDialogCreateAgreementOpen"
    :is-open="isDialogCreateAgreementOpen"
    :is-access-license="true"
    :license-name="licenseName"
    :service-provider-id="props.serviceProviderId"
    @close-dialog="isDialogCreateAgreementOpen = false"
    @update-list="getAssignedLicenses"
  />
</template>

<style scoped lang="scss"></style>
