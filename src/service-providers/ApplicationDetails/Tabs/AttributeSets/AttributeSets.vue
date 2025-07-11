<script setup lang="ts">
import { computed, ComputedRef, onMounted, ref, Ref } from "vue";
import { TypeAssignTo } from "~/service-providers/ApplicationDetails/types";
import { AttributeSetWithAttributeTypesRead } from "~/onboarding/onboarding.types";
import { useRoute } from "vue-router";
import { attributeSetsService } from "~/configuration/attribute-sets.service";
import { TableHeader } from "~/mm_ui_kit/src/types/table.types";
import { attributeSetAttributeOfItems } from "~/service-providers/AttributeSets/attributeSetAttributeOfHelper";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import DialogConfirmRemoveAttributeSet from "../../Dialogs/DialogConfirmRemoveAttributeSet.vue";
import DialogAssignAttributeSet from "../../Dialogs/DialogAssignAttributeSet.vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { useTranslation } from "i18next-vue";
import { useUiStore } from "~/stores/useUiStore";

const { t } = useTranslation();

const translationKey =
  "configuration.applications.application_details.tab_settings.sections.attr_sets";

const route = useRoute();

defineProps({
  isInEditMode: {
    type: Boolean,
    default: false,
  },
});

const tableHeaders: ComputedRef<TableHeader[]> = computed(() => [
  {
    key: "name",
    label: t(`${translationKey}.table_headers.name`),
  },
  {
    key: "description",
    label: t(`${translationKey}.table_headers.description`),
  },
  {
    key: "type",
    label: t(`${translationKey}.table_headers.type`),
  },
  {
    key: "required_attribute_types",
    label: t(`${translationKey}.table_headers.required_attribute_types`),
  },
  {
    key: "optional_attribute_types",
    label: t(`${translationKey}.table_headers.optional_attribute_types`),
  },
  {
    key: "actions",
    label: "",
  },
]);

const emit = defineEmits(["get-config-status"]);

const uiStore = useUiStore();

const attributeSetToRemove: Ref<AttributeSetWithAttributeTypesRead | null> =
  ref(null);
const assignTo: Ref<TypeAssignTo> = ref("user");
const isDialogRemoveAttributeSetOpened: Ref<boolean> = ref(false);
const isDialogAssignAttributeSetOpened: Ref<boolean> = ref(false);
const attributeSets: Ref<AttributeSetWithAttributeTypesRead[]> = ref([]);

const dropdownItems = (
  attributeSet: AttributeSetWithAttributeTypesRead,
): TypeDropdownItem[] => [
  {
    label: "View attribute set",
    type: "link",
    to: `/sp/${route.params.service_provider_id}/attribute-sets/${attributeSet.id}`,
  },
  {
    label: "Remove attribute set",
    type: "button",
    isDisabled: uiStore.isSPViewerOnly,
    color: "error",
    onClick() {
      attributeSetToRemove.value = attributeSet;
      isDialogRemoveAttributeSetOpened.value = true;
    },
  },
];

const alreadyAssignedAttributeSets: ComputedRef<
  { title: string; value: string; $isDisabled: boolean }[]
> = computed(() =>
  attributeSets.value.map((attributeSet) => ({
    title: `${attributeSet.name}`,
    value: `${attributeSet.id}`,
    $isDisabled: true,
  })),
);

const onDialogConfirmRemoveAttributeSetClose = () => {
  attributeSetToRemove.value = null;
  isDialogRemoveAttributeSetOpened.value = false;
};

const onDialogAssignAttributeSetOpen = (type: TypeAssignTo) => {
  assignTo.value = type;
  isDialogAssignAttributeSetOpened.value = true;
};

const onDialogAssignAttributeSetClose = () => {
  isDialogAssignAttributeSetOpened.value = false;
};

const getAttributeSetsForOAuthClient = async () => {
  try {
    const oAuthClientIds =
      oAuthClientsService.state.oAuthClient?.attribute_set_ids || [];

    attributeSets.value = await Promise.all(
      oAuthClientIds.map((id: string) =>
        attributeSetsService.getAttributeSet(
          route.params.service_provider_id as string,
          id,
        ),
      ),
    );
  } catch (error) {
    const err = error as { response?: { status?: number } };
    if (err.response?.status !== 404) {
      eventBus.$emit("onShowToast", {
        text: "Error fetching attribute sets",
        status: "error",
      });
    }
  }
};

const onSubmitAssignAttributeSet = async (ids: string[]) => {
  if (!oAuthClientsService.state.oAuthClient?.attribute_set_ids) return;
  oAuthClientsService.state.oAuthClient.attribute_set_ids.push(...ids);
  await getAttributeSetsForOAuthClient();
  emit("get-config-status");
};

const onSubmitRemoveAttributeSet = (id: string) => {
  attributeSets.value = attributeSets.value.filter(
    (attributeSet: AttributeSetWithAttributeTypesRead) =>
      attributeSet.id !== id,
  );
  if (!oAuthClientsService.state.oAuthClient?.attribute_set_ids) return;
  oAuthClientsService.state.oAuthClient.attribute_set_ids =
    oAuthClientsService.state.oAuthClient.attribute_set_ids.filter(
      (attributeSetId: string) => attributeSetId !== id,
    );
  emit("get-config-status");
};

onMounted(async () => {
  await getAttributeSetsForOAuthClient();
});
</script>

<template>
  <m-m-table
    :headers="tableHeaders"
    :rows="attributeSets"
    cy="table-attribute-set"
    empty-state="No attribute sets"
    :description="$t(`${translationKey}.subtitle`)"
  >
    <template v-if="isInEditMode" #action>
      <div class="mm-flex mm-flex-column-gap-6">
        <div>
          <m-m-button
            variant="outlined"
            size="small"
            prepend-icon="plus"
            cy="button-assign-organization-attribute-set"
            @click="onDialogAssignAttributeSetOpen('organization')"
          >
            {{ $t(`${translationKey}.assign_org_button`) }}
          </m-m-button>
        </div>
        <div>
          <m-m-button
            variant="outlined"
            size="small"
            prepend-icon="plus"
            cy="button-assign-user-attribute-set"
            @click="onDialogAssignAttributeSetOpen('user')"
          >
            {{ $t(`${translationKey}.assign_user_button`) }}
          </m-m-button>
        </div>
      </div>
    </template>
    <template #type="{ row }">
      {{ attributeSetAttributeOfItems[row.type] }}
    </template>
    <template #required_attribute_types="{ row }">
      {{ row.required_attribute_types.length }}
    </template>
    <template #optional_attribute_types="{ row }">
      {{ row.optional_attribute_types.length }}
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

  <dialog-confirm-remove-attribute-set
    v-if="attributeSetToRemove"
    :is-open="isDialogRemoveAttributeSetOpened"
    :service-provider-id="route.params.service_provider_id as string"
    :attribute-set="attributeSetToRemove"
    @submit="onSubmitRemoveAttributeSet"
    @close="onDialogConfirmRemoveAttributeSetClose"
  />

  <dialog-assign-attribute-set
    :is-open="isDialogAssignAttributeSetOpened"
    :service-provider-id="route.params.service_provider_id as string"
    :assign-to="assignTo"
    :already-assigned-attribute-sets="alreadyAssignedAttributeSets"
    @submit="onSubmitAssignAttributeSet"
    @close="onDialogAssignAttributeSetClose"
  />
</template>

<style scoped lang="scss"></style>
