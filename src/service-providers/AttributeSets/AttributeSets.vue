<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { attributeSetsService } from "~/configuration/attribute-sets.service";
import { authService } from "~/auth/auth.service";
import {
  EmptyStateType,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import {
  AttributeSetWithAttributeTypesRead,
  AttributeSetWithCountsRead,
} from "~/onboarding/onboarding.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { tableHeaders } from "./tableHeaders";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import DialogDeleteAttributeSet from "./AttributeSet/Dialogs/DialogDeleteAttributeSet.vue";
import { attributeSetAttributeOfItems } from "~/service-providers/AttributeSets/attributeSetAttributeOfHelper";
import { useUnpublishedConfigChangesStore } from "~/stores/unpublishedConfig/unpublishedConfig";
import { ConfigPublishStatusEnum } from "../ConfigPublish/enums";
import { useRouter } from "vue-router";
import { Button, DropdownItem } from "~/mm_ui_kit/src/types/overviewPage.types";
import ConfigPublishBanner from "../ConfigPublishBanner/ConfigPublishBanner.vue";
import MMOverviewPage from "~/mm_ui_kit/src/components/MMOverviewPage.vue";
import { useUiStore } from "~/stores/useUiStore";

const uiStore = useUiStore();
const router = useRouter();
const isLoading: Ref<boolean> = ref(true);
const serviceProviderId: Ref<string> = ref("");
const attributeSets: Ref<TableResponse<AttributeSetWithCountsRead> | null> =
  ref(null);
const attributeSetToDelete: Ref<AttributeSetWithAttributeTypesRead | null> =
  ref(null);
const isDialogDeleteAttributeSetOpened: Ref<boolean> = ref(false);
const isButtonConfirmDeleteDisabled: Ref<boolean> = ref(false);
const isButtonConfirmDeleteLoading: Ref<boolean> = ref(false);
const generateAttributeSetCanNotDeleteMessage = (count: number): string =>
  `This attribute set is being used by ${count} applications. You can only delete this attribute set if there are no references.`;

const emptyState: EmptyStateType = {
  title: "No attribute sets",
  icon: "application-icon",
  description:
    "Define the list of user or organization attributes required from users to access your application/s.",
};

const unpublishedChangesStore = useUnpublishedConfigChangesStore();
const overviewHeaderRef: Ref<InstanceType<typeof MMOverviewPage> | null> =
  ref(null);

const isConfigPublishing: ComputedRef<boolean> = computed(() =>
  Boolean(
    unpublishedChangesStore.configPublishStatus ===
      ConfigPublishStatusEnum.PUBLISHING.enum,
  ),
);

const isAttributeSetDeletable = (
  attributeSet: AttributeSetWithCountsRead,
): boolean => attributeSet?.deletable ?? true;

const isAttributeSetEditable = (
  attributeSet: AttributeSetWithCountsRead,
): boolean => attributeSet?.editable ?? true;

const dropdownItems = (
  attributeSet: AttributeSetWithCountsRead,
): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "link",
    to: `/sp/${serviceProviderId.value}/attribute-sets/${attributeSet.id}`,
  },
  {
    label: "Edit",
    type: "button",
    hint: isConfigPublishing.value
      ? "You cannot edit this attribute set as config is currently being published"
      : "",
    isDisabled:
      !isAttributeSetEditable(attributeSet) ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly,
    onClick: () => {
      router.push({
        path: `/sp/${serviceProviderId.value}/attribute-sets/${attributeSet.id}`,
        query: { editMode: "true" },
      });
    },
  },
  {
    label: `Delete`,
    isDisabled:
      !!attributeSet.usagesCount ||
      isConfigPublishing.value ||
      uiStore.isSPViewerOnly ||
      !isAttributeSetDeletable(attributeSet),
    hint: attributeSet.usagesCount
      ? generateAttributeSetCanNotDeleteMessage(attributeSet.usagesCount)
      : deleteAttributeSetConfigHintText.value,
    type: "button",
    color: "error",
    onClick: () => onDialogAttributeSetOpen(attributeSet),
  },
];

const dropdownItemsCreateAttribute: ComputedRef<TypeDropdownItem[]> = computed(
  () => [
    {
      label: "Organization",
      type: "link",
      to: `/sp/${serviceProviderId.value}/attribute-sets/new#organization`,
    },
    {
      label: "User",
      type: "link",
      to: `/sp/${serviceProviderId.value}/attribute-sets/new#user`,
    },
  ],
);

const deleteAttributeSetConfigHintText: ComputedRef<string> = computed(() =>
  isConfigPublishing.value
    ? "You cannot delete this attribute set as config is currently being published"
    : "",
);

const dropdownItemsCreateAttributeSet: ComputedRef<DropdownItem[]> = computed(
  () => [
    {
      key: "organization",
      action: () => {
        router.push(
          `/sp/${serviceProviderId.value}/attribute-sets/new#organization`,
        );
      },
    },
    {
      key: "user",
      action: () => {
        router.push(`/sp/${serviceProviderId.value}/attribute-sets/new#user`);
      },
    },
  ],
);

const getAttributeSets = async (params: TableRequestParams) => {
  try {
    isLoading.value = true;
    if (!serviceProviderId.value) {
      const userProfile = await authService.getProfile();
      serviceProviderId.value = userProfile?.sp_org || "";
    }
    attributeSets.value = await attributeSetsService.getAttributeSets(
      serviceProviderId.value,
      params,
    );

    attributeSets.value?.results.forEach(
      async (attributeSet: AttributeSetWithCountsRead) => {
        const attributeSetUsages = await getAttributeSetUsages(attributeSet.id);
        attributeSet.hidden = attributeSet?.wizard?.hidden || false;
        attributeSet.usagesCount = attributeSetUsages?.results.length;
      },
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching attribute sets",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const getAttributeSetUsages = async (
  attribute_set_id: string,
  params?: TableRequestParams,
) => {
  try {
    return await attributeSetsService.getAttributeSetUsages(
      serviceProviderId.value,
      attribute_set_id,
      params,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching attribute sets usages",
      status: "error",
    });
  }
};

const deleteAttributeSet = async () => {
  try {
    isButtonConfirmDeleteDisabled.value = true;
    isButtonConfirmDeleteLoading.value = true;

    await attributeSetsService.deleteAttributeSet(
      serviceProviderId.value,
      attributeSetToDelete.value?.id as string,
    );

    await getAttributeSets({ limit: "10", offset: "0" });

    onDialogAttributeSetClose();
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error deleting attribute set",
      status: "error",
    });
  } finally {
    isButtonConfirmDeleteDisabled.value = false;
    isButtonConfirmDeleteLoading.value = false;
  }
};

const onDialogAttributeSetOpen = (
  attributeSet: AttributeSetWithAttributeTypesRead,
) => {
  attributeSetToDelete.value = attributeSet;
  isDialogDeleteAttributeSetOpened.value = true;
};

const onDialogAttributeSetClose = () => {
  isDialogDeleteAttributeSetOpened.value = false;
  overviewHeaderRef.value?.configBannerRef?.getUnpublishedConfig();
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "create_attribute_set",
    isDropdown: true,
    dropdownItems: dropdownItemsCreateAttributeSet.value,
    isDisabled: isConfigPublishing.value || uiStore.isSPViewerOnly,
    tooltipText: isConfigPublishing.value
      ? "Config is currently being published."
      : "",
  },
]);
</script>

<template>
  <m-m-overview-page
    ref="overviewHeaderRef"
    resource-id="attribute_sets.overview"
    :buttons="buttons"
    :config-banner-cmp="ConfigPublishBanner"
  >
    <m-m-table
      :is-loading="isLoading"
      :headers="tableHeaders"
      :rows="attributeSets?.results"
      :total-rows="attributeSets?.total"
      cy="table-attribute-sets"
      show-search
      :empty-state="emptyState"
      @update-params="getAttributeSets"
    >
      <template #empty-state-button>
        <m-m-dropdown
          list-side="left"
          :items="dropdownItemsCreateAttribute"
          cy="empty-state-dropdown-create-attribute-set"
        >
          <template #activator>
            <m-m-button
              variant="elevated"
              size="small"
              prepend-icon="plus-white"
              cy="empty-state-button-create-attribute-set"
              :is-disabled="isConfigPublishing"
            >
              Create attribute set
              <m-m-tooltip v-if="isConfigPublishing" display-position="toLeft">
                Config is currently being published.
              </m-m-tooltip>
            </m-m-button>
          </template>
        </m-m-dropdown>
      </template>
      <template #name="{ row }">
        <m-m-link
          :to="`/sp/${serviceProviderId}/attribute-sets/${row.id}`"
          font-weigth="500"
          :cy="`column-name-${row?.id}`"
        >
          {{ row.name }}
        </m-m-link>
      </template>
      <template #type="{ row }">
        {{ attributeSetAttributeOfItems[row.type] }}
      </template>
      <template #created_date="{ row }">
        <m-m-formatted-date
          :raw-date="row.created_date"
          format="D MMM YYYY, HH:mm"
        />
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
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
      </template> </m-m-table
  ></m-m-overview-page>

  <m-m-config-banner />

  <dialog-delete-attribute-set
    v-if="attributeSetToDelete"
    :is-open="isDialogDeleteAttributeSetOpened"
    :data="attributeSetToDelete"
    :is-button-confirm-delete-disabled="isButtonConfirmDeleteDisabled"
    :is-button-confirm-delete-loading="isButtonConfirmDeleteLoading"
    @submit="deleteAttributeSet"
    @close="onDialogAttributeSetClose"
  />
</template>

<style scoped lang="scss"></style>
