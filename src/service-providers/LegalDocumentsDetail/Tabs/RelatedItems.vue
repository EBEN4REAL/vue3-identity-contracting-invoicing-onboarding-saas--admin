<script setup lang="ts">
import { Ref, ref, ComputedRef, computed } from "vue";
import { useRoute } from "vue-router";
import {
  TableHeader,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { agreementTypesService } from "~/configuration/agreement-types.service";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { getErrorMessage } from "~/service-providers/_shared/helpers/configErrorMessageHelper";
import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";

const props = defineProps({
  documentsSignedCount: {
    type: Number,
    default: 0,
  },
  agreements: {
    type: Array<string>,
    default: () => [],
  },
});

const route = useRoute();
const licenses: Ref<TableResponse<AgreementTypePoliciesRead> | null> =
  ref(null);
const TABLE_HEADERS: TableHeader[] = [
  {
    label: "Name",
    key: "name",
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "",
    key: "actions",
    sortable: false,
  },
];

const resolveRedirectUrl = (id: string) => {
  return route.query.from === "plans"
    ? `/sp/${route.params.service_provider_id}/plans/${id}`
    : `/sp/${route.params.service_provider_id}/access-licenses/${id}`;
};

const tableDropdownItems = (
  row: AgreementTypePoliciesRead,
): TypeDropdownItem[] => [
  {
    label: "View details",
    type: "link",
    to: resolveRedirectUrl(row.id),
  },
];

const serviceProviderId: ComputedRef<string> = computed(
  () => `${route.params.service_provider_id}`,
);

const handleUpdateParams = async (params: TableRequestParams) => {
  try {
    const queryParams = new URLSearchParams(params);
    if (props.agreements.length) {
      for (let i = 0; i < props.agreements.length; i++) {
        queryParams.append("agreement_type_ids", props.agreements[i]);
      }
      licenses.value = await agreementTypesService.getAgreementTypes(
        serviceProviderId.value,
        queryParams,
      );
    }
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: getErrorMessage(error, true),
      status: "error",
    });
  }
};
</script>
<template>
  <div class="mm-page-subtitle--h2 mm-mb-7">
    Overview of all plans that include this legal document.
  </div>
  <m-m-alert :is-closable="false" class="mm-mb-12">
    <div class="mm-flex mm-flex-justify-between mm-flex-align-center mm-w-10">
      <div class="usage-message" data-cy="usage-documents-count">
        This legal document has been signed by
        {{ documentsSignedCount }} organizations.
      </div>
    </div>
  </m-m-alert>
  <m-m-expandable-card
    :title="`Plans (${licenses?.total ? licenses.total : 0})`"
    is-opened
  >
    <m-m-table
      class="mm-w-10"
      :headers="TABLE_HEADERS"
      :rows="licenses?.results"
      :total-rows="licenses?.total"
      cy="usage-table"
      empty-state="No plans"
      @update-params="handleUpdateParams"
    >
      <template #name="{ row }">
        <m-m-link
          :to="resolveRedirectUrl(row.id)"
          font-weigth="500"
          :cy="`name-${row?.id}`"
        >
          {{ row.name }}
        </m-m-link>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="tableDropdownItems(row)"
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
</template>
<style scoped lang="scss">
.usage {
  &-message {
    color: #6d7480;
  }
}
:deep(.mm-table) {
  padding: 0 24px 24px;
}
.mm-expandable-card--active {
  background-color: #f2f4f7;
}
:deep(.mm-expandable-card .mm-table .mm-table-body) {
  box-shadow: none;
  border: none;
  background: none;
}
:deep(.mm-expandable-card-container .mm-card) {
  border: none;
  width: 100%;
  padding-top: 15px;
}
:deep(.mm-table-body thead tr) {
  background-color: #fafbfc;
}
:deep(.mm-table-body) {
  background-color: #f2f4f7;
}
:deep(.mm-table-body tr) {
  background-color: #fff;
}
</style>
