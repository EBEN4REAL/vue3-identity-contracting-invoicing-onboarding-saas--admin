import { UserProfile } from "oidc-client-ts";
import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";

export enum ScreenHint {
  SIGNUP = "signup",
}

export interface UserProfileMM extends UserProfile {
  sp?: string;
  org?: string;
  sp_org?: string;
  org_name?: string;
  roles?: string[];
  groups?: string[];
  onboarding_completed?: boolean;
}

export type TypeSignupForm = {
  email: string;
};

export type TypeSignupFormRules = {
  email: {
    required: ValidationRuleWithParams;
    email: ValidationRuleWithParams;
  };
};

export type ValidatorType = Ref<
  Validation<TypeSignupFormRules, TypeSignupForm>
>;

export type TypeForgottenPasswordForm = {
  email: string;
};

export type TypeForgottenPasswordFormRules = {
  email: {
    required: ValidationRuleWithParams;
    email: ValidationRuleWithParams;
  };
};

export type TypeValidatorForgottenPassword = Ref<
  Validation<TypeForgottenPasswordFormRules, TypeForgottenPasswordForm>
>;

export type TypeResetPasswordForm = {
  password: string;
};

export type TypeResetPasswordFormRules = {
  password: {
    [key: string]: ValidationRuleWithParams;
  };
};

export type TypeValidatorResetPassword = Ref<
  Validation<TypeResetPasswordFormRules, TypeResetPasswordForm>
>;

export type TypeSignupConfirmationForm = {
  password: string;
};

export type TypeSignupConfirmationFormRules = {
  password: {
    [key: string]: ValidationRuleWithParams;
  };
};

export type TypeValidatorSignupConfirmation = Ref<
  Validation<TypeSignupConfirmationFormRules, TypeSignupConfirmationForm>
>;
