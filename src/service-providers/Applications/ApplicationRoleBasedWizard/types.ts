import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { TypeApplicationBasicInformationFormRules } from "~/service-providers/ApplicationDetails/types";
import { DefineComponent, Ref } from "vue";
import { helpers } from "@vuelidate/validators";

export type TypeApplicationVerificationComponent = {
  v$: Validation<TypeApplicationBasicInformationFormRules>;
  isApplicationNameValid: boolean;
  validateApplication: () => Promise<void>;
};

export type TypeRolesAndPermissionsVerificationComponent = {
  isRolesAndPermissionsValid: boolean;
  isDuplicateRoleOrPermission: boolean;
};

export type TypeApplicationConfigWizardStep = {
  component: DefineComponent<object, object>;
  ref: Ref<
    | TypeApplicationVerificationComponent
    | TypeRolesAndPermissionsVerificationComponent
    | null
  >;
};

export type TypeComponentRef = Ref<
  | TypeApplicationVerificationComponent
  | TypeRolesAndPermissionsVerificationComponent
  | null
>;

export type TypeApplicationRoleBasedConfigWizardFormRules = {
  roleName: {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
};

export type TypeApplicationRoleBasedConfigWizardForm = {
  roleName: string;
};

export type Role = {
  id: string;
  name: string;
  searchQuery: string;
  permissions: Permission[];
};

export type Permission = {
  id: string;
  name: string;
  searchQuery: string;
};

export type PermissionValidationRules = {
  name: {
    required: ReturnType<typeof helpers.withMessage>;
    permission: ReturnType<typeof helpers.withMessage>;
  };
};

export type RoleValidationRules = {
  name: {
    required: ReturnType<typeof helpers.withMessage>;
    maxLength: ReturnType<typeof helpers.withMessage>;
    role: ReturnType<typeof helpers.withMessage>;
  };
  permissions: PermissionValidationRules[];
};
