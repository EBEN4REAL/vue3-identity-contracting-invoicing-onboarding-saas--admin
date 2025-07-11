<script setup lang="ts">
import { ref, Ref, defineProps, PropType, ComputedRef, computed } from "vue";
import { useRouter } from "vue-router";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import DialogDeleteLicense from "../Dialogs/DialogDeleteLicense.vue";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { ConfigPublishStatusEnum } from "~/service-providers/ConfigPublish/enums";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";

const router = useRouter();

const props = defineProps({
  items: {
    type: Object as PropType<TableResponse<AgreementTypePoliciesRead> | null>,
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

const emit = defineEmits(["update", "on:delete-license"]);

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const emptyState: EmptyStateType = {
  title: "Create your first access license",
  description:
    "Access license contains policies and allows the customer organization to manage to which users the policies are assigned.",
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/ciam/set-up-access-controls#access-licenses",
  icon: "ticket-outline",
};

const TABLE_HEADERS: TableHeader[] = [
  {
    key: "name",
    label: "Name",
    sortable: true,
    sortIcon: true,
    order: "asc",
    sortName: "agreement_type.name",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    label: "Created date",
    key: "created_date",
    sortIcon: true,
    order: "desc",
    sortable: true,
    defaultSortItem: true,
    sortName: "agreement_type.created_date",
  },
  {
    key: "actions",
    label: "",
  },
];

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isLicenseEditable = (license: AgreementTypePoliciesRead): boolean =>
  license?.editable ?? true;

const isLicenseDeletable = (license: AgreementTypePoliciesRead): boolean =>
  license?.deletable ?? true;

const dropdownItems: ComputedRef<
  (row: AgreementTypePoliciesRead) => TypeDropdownItem[]
> = computed(() => {
  return (row: AgreementTypePoliciesRead): TypeDropdownItem[] => [
    {
      label: "View",
      type: "button",
      onClick: () => {
        onRedirectToLicenseDetails(row.id);
      },
    },
    {
      label: "Edit",
      type: "button",
      isDisabled: !isLicenseEditable(row) || !!isConfigPublishing.value,
      hint: isConfigPublishing.value
        ? "You cannot edit this license as config is currently being published"
        : "",
      onClick: () => {
        router.push({
          path: `/sp/${props.serviceProviderId}/licenses/${row.id}`,
          query: { editMode: "true" },
        });
      },
    },
    {
      label: "Duplicate",
      type: "button",
      isDisabled: !!isConfigPublishing.value,
      hint: isConfigPublishing.value
        ? "You cannot duplicate this license as config is currently being published"
        : "",
      onClick: () => {
        router.push({
          path: `/sp/${props.serviceProviderId}/licenses/new`,
          query: { duplicateMode: "true" },
        });
        agreementTypesService.state.license = row;
      },
    },
    {
      label: "Delete",
      type: "button",
      color: "error",
      hint: deleteLicenseHintText.value(row),
      isDisabled:
        isDeleteLicenseDisabled.value(row) ||
        isConfigPublishing.value ||
        !isLicenseDeletable(row),
      onClick: () => onDeleteLicense(row.id),
    },
  ];
});

const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const deleteDialogData: Ref<string> = ref("");

const isDeleteLicenseDisabled: ComputedRef<
  (license: AgreementTypePoliciesRead) => boolean
> = computed(() => {
  return (license: AgreementTypePoliciesRead): boolean =>
    license?.agreements_count > 0;
});

const deleteLicenseHintText: ComputedRef<
  (license: AgreementTypePoliciesRead) => string | null
> = computed(() => {
  return (license: AgreementTypePoliciesRead): string | null => {
    if (isDeleteLicenseDisabled.value(license)) {
      return "You cannot delete this license as there are active instances of it.";
    }
    if (isConfigPublishing.value) {
      return "You cannot delete this license as config is currently being published.";
    }
    return null;
  };
});

const onDeleteLicense = (id: string) => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
  deleteDialogData.value = id;
};

const onRedirectToLicenseDetails = (id: string) => {
  router.push({
    name: "accessLicenseDetails",
    params: {
      service_provider_id: props.serviceProviderId,
      license_id: id,
    },
  });
};

const onRedirectToLicenseCreate = () =>
  router.push({
    name: "SPAccessLicensesNew",
    params: {
      service_provider_id: props.serviceProviderId,
    },
  });

const detailedViewLink = (row: AgreementTypePoliciesRead) =>
  `/sp/${props.serviceProviderId}/licenses/${row?.id}`;

const initialQueryParams = ref<TableRequestParams>({
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});

const handleDeleteDialogClose = () => {
  emit("on:delete-license", deleteDialogData.value);
  isConfirmDeleteDialogOpen.value = false;
};

const handleUpdateParams = (params?: TableRequestParams) => {
  emit("update", {
    ...initialQueryParams.value,
    ...params,
  });
};
</script>

<template>
  <section class="mm-access-control-licenses">
    <m-m-table
      cy="access-control-licenses-table"
      :is-loading="isLoading"
      :empty-state="emptyState"
      :headers="TABLE_HEADERS"
      :rows="items?.results || []"
      description="Access license products configured"
      :total-rows="items?.total || 0"
      show-search
      @update-params="handleUpdateParams"
    >
      <template #empty-state-button>
        <m-m-button
          variant="elevated"
          size="small"
          prepend-icon="plus-white"
          cy="empty-state-button-create-license"
          :is-disabled="isConfigPublishing"
          @click="onRedirectToLicenseCreate"
        >
          Create license
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </template>
      <template #created_date="{ row }">
        <m-m-formatted-date
          :raw-date="row.created_date"
          format="D MMM YYYY, HH:mm"
        />
      </template>
      <template #action>
        <m-m-button
          variant="outlined"
          size="small"
          prepend-icon="plus"
          cy="button-create-license"
          :is-disabled="isConfigPublishing"
          @click="onRedirectToLicenseCreate"
        >
          Create license
          <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
            Config is currently being published.
          </m-m-tooltip>
        </m-m-button>
      </template>
      <template #name="{ row }">
        <m-m-link
          :to="detailedViewLink(row)"
          font-weigth="500"
          :data-cy="`column-name-${row.id}`"
        >
          {{ row.name }}
        </m-m-link>
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
    </m-m-table>
  </section>
  <DialogDeleteLicense
    :is-open="isConfirmDeleteDialogOpen"
    :license-id="deleteDialogData"
    :service-provider-id="serviceProviderId"
    @close-dialog="handleDeleteDialogClose"
    @update-licenses="handleUpdateParams"
  />
</template>
