import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";

export type TypeResourceBasicInformationForm = {
  name: string;
  description?: string | null;
};

export type TypeCreateResourceBasicInformationFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidationResourceBasicInformation = Validation<
  TypeCreateResourceBasicInformationFormRules,
  TypeResourceBasicInformationForm
>;

export type TypeValidateResourceBasicInformation =
  Ref<TypeValidationResourceBasicInformation>;

export type SettingsTabComponent = {
  basicInformationEditRef: Ref<{
    form: TypeResourceBasicInformationForm;
    v$: TypeValidationResourceBasicInformation;
  } | null>;
  resourceAttributesEditRef: Ref<{
    form: string[];
  } | null>;
};
