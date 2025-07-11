<script setup lang="ts">
import { computed, PropType, ref, toRef } from "vue";
import BasicInformationEdit from "../BasicInformation/BasicInformationEdit.vue";
import BasicInformationRead from "../BasicInformation/BasicInformationRead.vue";
import ConnectionConfigurationEdit from "../ConnectionConfiguration/ConnectionConfigurationEdit.vue";
import ConnectionConfigurationRead from "../ConnectionConfiguration/ConnectionConfigurationRead.vue";
import AttributeSets from "../AttributeSets/AttributeSets.vue";
import { useFlag } from "@unleash/proxy-client-vue";

const props = defineProps({
  openIdUrl: {
    type: String,
    default: "",
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
  mode: {
    type: String as PropType<"edit" | "create" | undefined>,
    default: undefined,
  },
  isExpandableBasicInfoOpen: {
    type: Boolean,
    default: true,
  },
  isExpandableConnectionConfigOpen: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits([
  "get-mfa-required-status",
  "update:basicInfoOpen",
  "update:connectionConfigOpen",
  "application-update",
  "get-config-status",
]);
const attributeSetsEnabled = useFlag("attribute_sets");
const refBasicInformation = ref(null);
const refConnectionConfiguration = ref(null);
const isEditMode = computed(() => props.mode === "edit");
const isCreateMode = computed(() => props.mode === "create");

const isBasicInformationOpen = toRef(props, "isExpandableBasicInfoOpen");
const isConnectionConfigurationOpen = toRef(
  props,
  "isExpandableConnectionConfigOpen",
);

const translationKey =
  "configuration.applications.application_details.tab_settings";

const getConfigStatus = () => emit("get-config-status");

defineExpose({
  refBasicInformation,
  refConnectionConfiguration,
});
</script>

<template>
  <div>
    <m-m-expandable-card
      :title="$t(`${translationKey}.sections.basic_info.title`)"
      :is-opened="isBasicInformationOpen"
      :required="isCreateMode || isEditMode"
      @update:is-opened="emit('update:basicInfoOpen', $event)"
    >
      <BasicInformationEdit
        v-if="isCreateMode || isEditMode"
        ref="refBasicInformation"
        :mode="mode"
        class="form-container"
        @get-mfa-required-status="emit('get-mfa-required-status', $event)"
      />
      <BasicInformationRead v-else />
    </m-m-expandable-card>
    <m-m-expandable-card
      :title="$t(`${translationKey}.sections.connection_config.title`)"
      class="mm-mt-10"
      :is-opened="isConnectionConfigurationOpen"
      :required="isCreateMode || isEditMode"
      @update:is-opened="emit('update:connectionConfigOpen', $event)"
    >
      <ConnectionConfigurationEdit
        v-if="isCreateMode || isEditMode"
        ref="refConnectionConfiguration"
        :open-id-url="props.openIdUrl"
        :service-provider-id="serviceProviderId"
        :mode="props.mode"
        @application-update="emit('application-update')"
      />
      <ConnectionConfigurationRead v-else :open-id-url="props.openIdUrl" />
    </m-m-expandable-card>
    <m-m-expandable-card
      v-if="!isCreateMode && attributeSetsEnabled"
      :title="$t(`${translationKey}.sections.attr_sets.title`)"
      class="mm-mt-10 table-elem"
      is-opened
    >
      <AttributeSets
        :is-in-edit-mode="isEditMode"
        :service-provider-id="props.serviceProviderId"
        @get-config-status="getConfigStatus"
      />
    </m-m-expandable-card>
  </div>
</template>
<style scoped lang="scss">
:deep(.mm-table) {
  padding: 0 24px 24px;
}
:deep(.mm-expandable-card--active.table-elem) {
  background-color: #f2f4f7;
}
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
.form-container {
  width: calc(100% - 50px);
  margin: 15px 20px 20px;
}
</style>
