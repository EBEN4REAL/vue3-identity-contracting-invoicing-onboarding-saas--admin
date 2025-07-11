import { components } from "~/iam/iam.schemas";
import { Validation, ValidationRuleWithParams } from "@vuelidate/core";

export type RoleRead = components["schemas"]["RoleRead"];

export type RoleWithUsagesRead = RoleRead & { usages: number };

export type TypeRoleForm = {
  name: string;
  description?: string | null;
};

export type TypeRoleFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidationRoleCreateEdit = Validation<
  TypeRoleFormRules,
  TypeRoleForm
>;
