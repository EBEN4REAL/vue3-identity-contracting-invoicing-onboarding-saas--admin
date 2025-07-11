import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { AgreementTypeCreate } from "~/policies/policies.types";
import { AgreementTypePoliciesRead } from "~/configuration/configuration.types";
import { Ref } from "vue";

export type TypeLicenseBasicInfo = Pick<
  AgreementTypeCreate,
  | "external_facing_name"
  | "name"
  | "description"
  | "external_facing_description"
>;

export type TypeCreateLicenseBasicInformationFormRules = {
  external_facing_name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  name: {
    maxLength: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
  external_facing_description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidatorLicenseBasicInformation = Validation<
  TypeCreateLicenseBasicInformationFormRules,
  TypeLicenseBasicInfo
>;

export type TypePricingDetails = Pick<
  AgreementTypePoliciesRead,
  | "billing_type"
  | "billing_period_unit"
  | "billing_period_length"
  | "price"
  | "prices"
>;

export type TypeCategoryData = {
  label: string;
  category: string;
  routeName: string;
  parent: {
    hash: string;
    label: string;
  };
  duplicateLabel: string;
};

export type SettingsTabComponent = {
  basicInformationEditRef: Ref<{
    v$: TypeValidatorLicenseBasicInformation;
    form: TypeLicenseBasicInfo;
  } | null>;
};

export enum EnumBillingPeriod {
  Day = "DAY",
  Week = "WEEK",
  Month = "MONTH",
  Year = "YEAR",
}

export type TypeBillingPeriod = {
  title: string;
  value: EnumBillingPeriod;
};
