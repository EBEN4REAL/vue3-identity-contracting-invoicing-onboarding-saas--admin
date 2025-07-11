import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { components } from "../../policies/policies.schemas";
import { Ref } from "vue";
import { BillingPeriodUnit, PriceModelEnum } from "../billing-types";

export type AgreementTypeRead = components["schemas"]["AgreementTypeRead"][];

export type AgreementTypeCreate =
  components["schemas"]["AgreementTypeCreate"][];

export type PaginationSchema_AgreementTypePoliciesCountAllocatedRead_ =
  components["schemas"]["PaginationSchema_AgreementTypePoliciesCountAllocatedRead_"];

export type AgreementTypePoliciesCountAllocatedRead =
  components["schemas"]["AgreementTypePoliciesCountAllocatedRead"];

export type AgreementCreate = components["schemas"]["AgreementCreate"][];

export type SPAgreementRead = components["schemas"]["SPAgreementRead"];

export type TypeAllocateLicenseForm = {
  customer: string;
  license: string;
};

export type TypeAllocateLicenseFormRules = {
  customer: {
    required: ValidationRuleWithParams;
  };
  license: {
    required: ValidationRuleWithParams;
  };
};

export type TypeValidatorAllocateLicenseForm = Ref<
  Validation<TypeAllocateLicenseFormRules, TypeAllocateLicenseForm>
>;

export type TypeAllocateLicenseToGroupForm = {
  agreement_id: string;
  optional_policy_ids: string[];
};

export type TypeAllocateLicenseToGroupFormRules = {
  agreement_id: {
    required: ValidationRuleWithParams;
  };
};

export type TypeValidatorAllocateLicenseToGroupForm = Ref<
  Validation<
    TypeAllocateLicenseToGroupFormRules,
    TypeAllocateLicenseToGroupForm
  >
>;

export type TypeMarketingFeature = {
  name: string;
}[];

export type AgreementTypeFormatted = AgreementTypePoliciesCountAllocatedRead & {
  amount: number | undefined;
  billing_period_unit: BillingPeriodUnit | null;
  billing_type: PriceModelEnum | null;
  currency: string | undefined;
};
