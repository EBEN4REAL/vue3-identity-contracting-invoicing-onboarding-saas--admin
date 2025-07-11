<script setup lang="ts">
import { computed, ComputedRef, PropType, ref, Ref, watch } from "vue";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { attributeSetsService } from "~/configuration/attribute-sets.service";
import {
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { TypeAssignTo } from "~/service-providers/ApplicationDetails/types";
import { oAuthClientsService } from "~/configuration/oauth-clients.service";
import { AttributeSetWithCountsRead } from "~/onboarding/onboarding.types";
import Multiselect from "vue-multiselect";
import { useTranslation } from "i18next-vue";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  assignTo: {
    type: String as PropType<TypeAssignTo>,
    default: null,
  },
  serviceProviderId: { type: String, default: "" },
  alreadyAssignedAttributeSets: {
    type: Array as PropType<
      { title: string; value: string; $isDisabled: boolean }[]
    >,
    default: () => [],
  },
});

const emit = defineEmits(["close", "submit"]);

const { t } = useTranslation();

const attributeSets: Ref<TableResponse<AttributeSetWithCountsRead> | null> =
  ref(null);
const isButtonSubmitDisabled: Ref<boolean> = ref(false);
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isButtonAddAttributeSetDisabled: Ref<boolean> = ref(false);
const isButtonAddAttributeSetLoading: Ref<boolean> = ref(false);
const isAttributeSetsItemsForSelectLoading: Ref<boolean> = ref(false);
const attributeSetsItemsForSelect: Ref<
  { title: string; value: string; $isDisabled?: boolean }[]
> = ref(props.alreadyAssignedAttributeSets);
const attributeSetsValues: Ref<string[]> = ref([]);
const attributeSetsSearch: Ref<string> = ref("");
const multiselectRef: Ref<InstanceType<typeof Multiselect> | null> = ref(null);

const title: ComputedRef<string> = computed(
  () =>
    `Assign ${props.assignTo} attribute set to ${oAuthClientsService.state.oAuthClient?.name}`,
);

const subtitle: ComputedRef<string> = computed(
  () =>
    `Select attribute set to be assigned to ${oAuthClientsService.state.oAuthClient?.name}`,
);

const dialogDataCy: ComputedRef<string> = computed(
  () => `dialog-assign-${props.assignTo}-attribute-set`,
);

const attributeSetsTotal: ComputedRef<number> = computed(
  () => attributeSets.value?.total || 0,
);

const createAttributeSetButtonText: ComputedRef<string> = computed(
  () => `Create attribute set "${attributeSetsSearch.value}"`,
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(attributeSetsSearch.value) &&
    !isAttributeSetsItemsForSelectLoading.value &&
    !attributeSetsItemsForSelect.value.find(
      (attributeSet) => attributeSet.title === attributeSetsSearch.value,
    ),
);

const attributeSetsValuesIds: ComputedRef<string[]> = computed(() =>
  attributeSetsValues.value.map((attributeSet) => attributeSet.value),
);

const getAttributeSets = async (params: TableRequestParams) => {
  try {
    isAttributeSetsItemsForSelectLoading.value = true;
    attributeSets.value = await attributeSetsService.getAttributeSets(
      props.serviceProviderId,
      { attribute_of: props.assignTo?.toUpperCase(), ...params },
    );

    const attributeSetResponseResults = attributeSets.value?.results || [];
    const newAttributeSetsItemsForSelect = attributeSetResponseResults.map(
      (attributeSet) => {
        const isAttributeSetAlreadyAdded = attributeSetsValues.value.some(
          (alreadyAddedAttributeSet) =>
            alreadyAddedAttributeSet.value === attributeSet.id,
        );

        return {
          title: attributeSet.name,
          value: attributeSet.id,
          wizard: attributeSet?.wizard,
          $isDisabled:
            isAttributeSetAlreadyAdded ||
            Boolean(attributeSet.wizard?.isolated),
        };
      },
    );

    attributeSetsItemsForSelect.value = [
      ...new Map(
        [
          ...attributeSetsItemsForSelect.value,
          ...newAttributeSetsItemsForSelect,
        ].map((obj) => [JSON.stringify(obj), obj]),
      ).values(),
    ];
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: err?.response?.data?.detail || err,
      status: "error",
    });
  } finally {
    isAttributeSetsItemsForSelectLoading.value = false;
  }
};

const onSubmit = async () => {
  try {
    isButtonSubmitDisabled.value = true;
    isButtonSubmitLoading.value = true;

    await oAuthClientsService.postAttributeSetToOAuthClient(
      props.serviceProviderId,
      oAuthClientsService.state.oAuthClient?.id as string,
      attributeSetsValuesIds.value,
    );

    emit("submit", attributeSetsValuesIds.value);
    emit("close");
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error assigning attribute set",
      status: "error",
    });
  } finally {
    isButtonSubmitDisabled.value = false;
    isButtonSubmitLoading.value = false;
  }
};

const onSearchChange = (value: string) => {
  attributeSetsSearch.value = value;
};

const onCreateAttributeSet = async () => {
  try {
    isButtonAddAttributeSetDisabled.value = true;
    isButtonAddAttributeSetLoading.value = true;

    const attributeSet = await attributeSetsService.createAttributeSet(
      props.serviceProviderId,
      {
        name: attributeSetsSearch.value,
        type: props.assignTo?.toUpperCase(),
        required_attribute_types: [],
        optional_attribute_types: [],
      },
    );

    attributeSetsValues.value.push({
      title: attributeSet.name,
      value: attributeSet.id,
    });

    multiselectRef.value?.closeMultiselect();

    eventBus.$emit("onShowToast", {
      text: t("configuration.toast_messages.subitem_successfully_created"),
      status: "info",
    });
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: err?.response?.data?.detail || err,
      status: "error",
    });
  } finally {
    isButtonAddAttributeSetDisabled.value = false;
    isButtonAddAttributeSetLoading.value = false;
  }
};

watch(
  () => props.isOpen,
  async () => {
    if (props.isOpen) {
      attributeSetsValues.value = [];
      attributeSetsItemsForSelect.value = [];
    }
  },
);

watch(
  () => attributeSetsValuesIds.value,
  () => {
    isButtonSubmitDisabled.value = !Boolean(attributeSetsValues.value.length);
  },
);
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    :title="title"
    :subtitle="subtitle"
    icon="shield-check-light"
    :cy="dialogDataCy"
    @close="emit('close')"
  >
    <m-m-multiselect
      ref="multiselectRef"
      v-model="attributeSetsValues"
      :options="attributeSetsItemsForSelect"
      :loading="isAttributeSetsItemsForSelectLoading"
      :total="attributeSetsTotal"
      multiple
      searchable
      @search-change="onSearchChange"
      @update-params="getAttributeSets"
    >
      <template v-if="isAfterListContentVisible" #afterListContent>
        <m-m-button
          :loading="isButtonAddAttributeSetDisabled"
          :is-disabled="isButtonAddAttributeSetDisabled"
          @click="onCreateAttributeSet"
        >
          {{ createAttributeSetButtonText }}
        </m-m-button>
      </template>
      <template #disabled-text="{ option }">
        <span v-if="option.wizard?.isolated">
          {{ t("multiselect.part_of") }}
          <m-m-link :to="`/sp${option.wizard.path}`" class="mm-fs-16">
            {{ option.wizard.name }}
          </m-m-link>
        </span>
        <span v-else-if="option.$isDisabled">
          {{ t("multiselect.already_added") }}
        </span>
      </template>
    </m-m-multiselect>
    <template #footer>
      <m-m-button
        variant="outlined"
        data-cy="button-cancel"
        size="medium"
        @click="emit('close')"
      >
        Cancel
      </m-m-button>
      <m-m-button
        data-cy="button-submit"
        :is-disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        @click="onSubmit"
      >
        Assign
      </m-m-button>
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss"></style>
