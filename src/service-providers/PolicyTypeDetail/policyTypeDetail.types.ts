import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";

export type PolicyTypeDetailMode = "create" | "edit" | "view";

export type PolicyTypeDetailForm = {
  external_facing_name: string;
  name: string;
  description: string;
  external_facing_description: string;
  outcome?: string;
  audit_level?: string;
  troubleshoot?: boolean;
  troubleshoot_end?: string | null;
  return_value: string | null;
};

export type TypeChildPolicyTypeAddForm = {
  policyTypeIds: string[];
};

export type TypeChildPolicyTypeAddRules = {
  policyTypeIds: {
    required: ValidationRuleWithParams;
  };
};

export type TypeValidatorChildPolicyTypeAdd = Ref<
  Validation<TypeChildPolicyTypeAddRules, TypeChildPolicyTypeAddForm>
>;

export type TypeFilterAddForm = {
  filterIds: string[];
};

export type TypeFilterAddRules = {
  filterIds: {
    required: ValidationRuleWithParams;
  };
};

export type TypeValidatorFilterAdd = Ref<
  Validation<TypeFilterAddRules, TypeFilterAddForm>
>;
