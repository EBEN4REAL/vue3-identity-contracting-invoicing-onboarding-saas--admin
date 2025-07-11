import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";

export type TypeApplicationBasicInformationForm = {
  name: string;
  description?: string;
  url?: string | null;
  grant_type: string;
  mfa_required: boolean;
};

export type TypeApplicationRoleBasedForm = {
  name: string;
  url: string;
};

export type TypeApplicationBasicInformationFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  url: {
    url: ValidationRuleWithParams;
  };
  grant_type: {
    required: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidationApplicationBasicInformation = Validation<
  TypeApplicationBasicInformationFormRules,
  TypeApplicationBasicInformationForm
>;

export type TypeApplicationConnectionConfigurationForm = {
  redirectUrl: string[];
};

export type TypeApplicationConnectionConfigurationFormRules = {
  redirectUrl: {
    required: ValidationRuleWithParams;
  };
};

export type TypeApplicationRoleBasedFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  url: {
    url: ValidationRuleWithParams;
  };
};

export type TypeValidationApplicationConnectionConfiguration = Validation<
  TypeApplicationConnectionConfigurationFormRules,
  TypeApplicationConnectionConfigurationForm
>;

export type TypeAssignTo = "user" | "organization";

export type SettingsTabComponent = {
  refBasicInformation: Ref<{
    form: TypeApplicationBasicInformationForm;
    v$: TypeValidationApplicationBasicInformation;
  } | null>;
  refConnectionConfiguration: Ref<{
    form: TypeApplicationConnectionConfigurationForm;
    v$: TypeValidationApplicationConnectionConfiguration;
  } | null>;
};
