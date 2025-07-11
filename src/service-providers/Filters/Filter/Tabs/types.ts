import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";
import { FilterItem } from "~/service-providers/Filters/filters.types";
import { WizardItemRead } from "~/configuration/configuration.types";

export type TypeFilterBasicInformationData = {
  name: string;
  description: string | null;
};

export type TypeFilterBasicInformationForm = {
  name: string;
  description?: string | null;
};

export type TypeCreateFilterBasicInformationFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidationFilterBasicInformation = Validation<
  TypeCreateFilterBasicInformationFormRules,
  TypeFilterBasicInformationForm
>;

export type TypeValidateFilterBasicInformation =
  Ref<TypeValidationFilterBasicInformation>;

export type TypeFilterConditionFormRules = {
  attribute_type: {
    required: ValidationRuleWithParams;
  };
  operator: {
    required: ValidationRuleWithParams;
  };
  value: {
    required: ValidationRuleWithParams;
    minLength?: ValidationRuleWithParams;
    maxLength?: ValidationRuleWithParams;
    email?: ValidationRuleWithParams;
    uuid?: ValidationRuleWithParams;
  };
};

export type TypeValidatorFilterCondition = Ref<
  Validation<TypeFilterConditionFormRules, FilterItem>
>;

export type TypeNestedFilterForSelect = {
  title: string;
  value: string;
  wizard: WizardItemRead;
  $isDisabled?: boolean;
};
