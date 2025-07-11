import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";

export type TypeAttributeSetBasicInformationForm = {
  name: string;
  description?: string | null;
};

export type TypeCreateAttributeSetBasicInformationFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidationAttributeSetBasicInformation = Validation<
  TypeCreateAttributeSetBasicInformationFormRules,
  TypeAttributeSetBasicInformationForm
>;

export type TypeValidateAttributeSetBasicInformation =
  Ref<TypeValidationAttributeSetBasicInformation>;

export type TypeAttributesRead = {
  required_attribute_types: string[] | null;
  optional_attribute_types: string[] | null;
};
export type SettingsTabComponentType = {
  basicInformation: {
    form: TypeAttributeSetBasicInformationForm;
    v$: TypeValidationAttributeSetBasicInformation;
  } | null;
  attributes: TypeAttributesRead;
};
