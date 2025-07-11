<script lang="ts" setup>
import { PropType, Ref, ref, onMounted } from "vue";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { PriceModelEnum, getPriceModel } from "../../billing-types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { ServiceProviderRead } from "~/iam/iam.types";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { computed } from "vue";
import { DESCRIPTION_MAX_CHARS } from "~/common/constants";
import { convertToMainUnit } from "~/mm_ui_kit/src/helpers/priceUnitConverter";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  licenses: {
    type: Object as PropType<AgreementTypePoliciesRead[]>,
    default: null,
  },
  serviceProviderId: {
    type: String,
    default: "",
  },
});
const response: Ref<ServiceProviderRead> = ref({});
const buttonColor = ref({});
const emit = defineEmits(["closeDialog"]);

const onDialogClose = () => {
  emit("closeDialog");
};

const getServiceProvider = async () => {
  try {
    response.value = await serviceProvidersService.getServiceProvider(
      props.serviceProviderId,
    );
    if (response.value)
      buttonColor.value = {
        backgroundColor: response.value.button_background_color,
        textColor: response.value.button_text_color,
      };
  } catch (err) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching service provider",
      status: "error",
    });
  }
};

const getFormattedAmount = (item: AgreementTypePoliciesRead) =>
  item?.price
    ? `${convertToMainUnit(item?.price?.amount, item?.price?.currency as string).formatted}`
    : item.billing_type != PriceModelEnum.FREE
      ? "-"
      : "Free";

const brandLogoUrl = computed(() => {
  return response.value?.logo_url;
});

const descriptionLong = (description: string) => {
  return description?.length > DESCRIPTION_MAX_CHARS;
};

const pricingType = (item: string) => {
  return item === "FLAT_FEE_RECURRING" ? "Month" : getPriceModel(item);
};

const dialogTitle = computed(() => `${response.value.name || "Veriam"}`);

onMounted(async () => {
  await getServiceProvider();
});
</script>
<template>
  <m-m-dialog
    :is-open="isOpen"
    size="extra-large"
    :title="`Select a ${dialogTitle} Plan`"
    icon-color="transparent"
    :is-large-modal="true"
    :scrollable="true"
    cy="preview-plan-dialog"
    @close="onDialogClose"
  >
    <template #icon>
      <img
        v-if="brandLogoUrl"
        :src="brandLogoUrl"
        alt="Logo"
        data-cy="brand-logo"
        class="preview-plan--logo"
      />
      <m-m-icon v-else icon="veriam-logo" width="100px" height="24px" />
    </template>
    <template #default>
      <div class="mm-flex mm-flex-gap-10 mm-flex-justify-center mm-flex-wrap">
        <div
          v-for="(item, index) in licenses"
          :key="index"
          :data-cy="`index-${index}`"
        >
          <m-m-pricing-card
            :product-name="item.name"
            :price="getFormattedAmount(item)"
            :pricing-type="pricingType(item.billing_type)"
            :button-color="buttonColor"
            button-text="Get Started"
          >
            <template #princing-card-message>
              <div ref="message">
                <m-m-tooltip v-if="descriptionLong(item.description)">{{
                  item.description
                }}</m-m-tooltip>
                {{ item.description }}
              </div>
            </template>
            <template v-if="item.marketing_features?.length" #included-products
              ><div class="mm-page-subtitle--h2 font-weight-700 mm-mb-6">
                What's Included
              </div>
              <ul class="pricing-card-list mm-page-subtitle--h2">
                <li
                  v-for="(feature, elem) in item.marketing_features"
                  :key="elem"
                  class="preview-plan--list"
                >
                  {{ feature }}
                </li>
              </ul></template
            >
          </m-m-pricing-card>
        </div>
      </div>
    </template>
  </m-m-dialog>
</template>
<style scoped lang="scss">
.preview-plan {
  &--list {
    list-style-type: disc;
    margin-left: 16px;
    color: #6d7480;
  }
  &--logo {
    max-width: 40px;
    max-height: 40px;
  }
}
:deep(.mm-dialog-scrollable) {
  max-height: 420px;
  overflow-y: scroll;
}
</style>
