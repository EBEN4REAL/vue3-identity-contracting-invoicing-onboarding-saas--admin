<script setup lang="ts">
import { computed, ComputedRef, Ref, ref } from "vue";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import {
  EmptyStateType,
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { authService } from "~/auth/auth.service";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import router from "~/router/index.router";
import DialogDeleteLicense from "../AccessControl/AccessLicense/Dialogs/DialogDeleteLicense.vue";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import ConfigPublishBanner from "~/service-providers/ConfigPublishBanner/ConfigPublishBanner.vue";

const emptyState: EmptyStateType = {
  title: "Create your first access license",
  description:
    "Access license contains policies and allows the customer organization to manage to which users the policies are assigned.",
  learnMoreHref:
    "https://docs.myveriam.com/for-providers/ciam/set-up-access-controls#access-licenses",
};

const serviceProviderId: Ref<string | null> = ref(null);
const isLoading: Ref<boolean> = ref(true);

const licenses: Ref<TableResponse<AgreementTypePoliciesRead> | null> =
  ref(null);
const currentParams: Ref<TableRequestParams> = ref({
  category: "ACCESS",
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
});
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const isConfirmDeleteDialogOpen: Ref<boolean> = ref(false);
const deleteDialogData: Ref<string> = ref("");
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
    sortName: "agreement_type.created_date",
    defaultSortItem: true,
  },
  {
    key: "actions",
    label: "",
  },
];

const unpublishedChangesStore = useUnpublishedConfigChangesStore();

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isLicenseDeletable = (license: AgreementTypePoliciesRead): boolean =>
  license?.deletable ?? true;

const isLicenseEditable = (license: AgreementTypePoliciesRead): boolean =>
  license?.editable ?? true;

const dropdownItems = (row: AgreementTypePoliciesRead): TypeDropdownItem[] => [
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
    isDisabled: isConfigPublishing.value || !isLicenseEditable(row),
    hint: isConfigPublishing.value
      ? "You cannot edit this license as config is currently being published"
      : "",
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/licenses/${row.id}`,
        query: { editMode: "true" },
      });
    },
  },
  {
    label: "Duplicate",
    type: "button",
    isDisabled: isConfigPublishing.value,
    hint: isConfigPublishing.value
      ? "You cannot duplicate this license as config is currently being published"
      : "",
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/licenses/new`,
        query: { duplicateMode: "true" },
      });
      agreementTypesService.state.license = row;
    },
  },
  {
    label: "Delete",
    type: "button",
    color: "error",
    hint: isDeleteLicenseDisabled(row)
      ? deleteLicenseHintText(row)
      : deleteLicenseConfigHintText.value,
    isDisabled:
      isDeleteLicenseDisabled(row) ||
      isConfigPublishing.value ||
      !isLicenseDeletable(row),
    onClick: () => onDeleteLicense(row.id),
  },
];

const isDeleteLicenseDisabled = (license: AgreementTypePoliciesRead) =>
  license.agreements_count > 0;

const deleteLicenseHintText = (license: AgreementTypePoliciesRead) => {
  return isDeleteLicenseDisabled(license)
    ? "You cannot delete this license as there are active instances of it."
    : null;
};

const deleteLicenseConfigHintText: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this license as config is currently being published"
    : "",
);

const onDeleteLicense = (id: string) => {
  isConfirmDeleteDialogOpen.value = !isConfirmDeleteDialogOpen.value;
  deleteDialogData.value = id;
};

const detailedViewLink = (row: AgreementTypePoliciesRead) =>
  `/sp/${serviceProviderId.value}/licenses/${row?.id}`;

const onRedirectToLicenseDetails = (id: string) => {
  router.push({
    name: "accessLicenseDetails",
    params: {
      service_provider_id: serviceProviderId.value,
      license_id: id,
    },
  });
};

const onRedirectToLicenseCreate = () =>
  router.push({
    name: "SPAccessLicensesNew",
    params: {
      service_provider_id: serviceProviderId.value,
    },
  });

const getAgreementTypes = async (params?: TableRequestParams) => {
  try {
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || "";
    }
    licenses.value = await agreementTypesService.getAgreementTypes(
      serviceProviderId.value,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching licenses",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const handleUpdateParams = async (params: TableRequestParams) => {
  currentParams.value = { ...currentParams.value, ...params };
  await getAgreementTypes(currentParams.value);
};

const handleDeleteDialogClose = async () => {
  isConfirmDeleteDialogOpen.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_access_license",
    action: () => onRedirectToLicenseCreate(),
    isDisabled: isConfigPublishing.value,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
  ,
]);
</script>
<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="access_licenses.overview"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <div>
      <m-m-table
        cy="access-licenses-table"
        :is-loading="isLoading"
        :rows="licenses?.results || []"
        :empty-state="emptyState"
        :headers="TABLE_HEADERS"
        :total-rows="licenses?.total || 0"
        show-search
        @update-params="handleUpdateParams"
      >
        <template #empty-state-button>
          <m-m-button
            variant="elevated"
            size="small"
            prepend-icon="plus-white"
            cy="button-create-license"
            @click="onRedirectToLicenseCreate"
          >
            Create license
          </m-m-button>
        </template>
        <template #created_date="{ row }">
          <m-m-formatted-date
            :raw-date="row.created_date"
            format="D MMM YYYY, HH:mm"
          />
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
      </m-m-table></div
  ></m-m-overview-page>
  <DialogDeleteLicense
    :is-open="isConfirmDeleteDialogOpen"
    :license-id="deleteDialogData"
    :service-provider-id="serviceProviderId as string"
    @close-dialog="handleDeleteDialogClose"
    @update-licenses="handleUpdateParams(currentParams)"
  />
</template>
<style scoped></style>
