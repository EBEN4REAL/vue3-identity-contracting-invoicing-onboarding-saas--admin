import { components } from "~/iam/iam.schemas";
import { Validation, ValidationRuleWithParams } from "@vuelidate/core";

export type PermissionRead = components["schemas"]["EntitlementRead"];

export type PermissionWithUsagesRead = PermissionRead & { usages: number };

export type TypePermissionToDelete = {
  id: string | null;
  name: string | null;
};

export type PermissionReadForSelect = PermissionRead & { disabled: boolean };

export type TypePermissionForm = {
  name: string;
  description?: string | null;
};

export type TypePermissionFormRules = {
  name: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
  description: {
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeValidationPermissionCreateEdit = Validation<
  TypePermissionFormRules,
  TypePermissionForm
>;
