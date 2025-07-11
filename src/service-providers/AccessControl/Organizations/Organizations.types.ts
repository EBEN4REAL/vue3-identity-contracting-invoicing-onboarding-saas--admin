import { ValidationRuleWithParams } from "@vuelidate/core";
export type TypeCreateOrganizationForm = {
  name: string;
  admin_email: string;
  user_emails?: string[] | null;
};

export type CreateOrganizationFormRules = {
  name: {
    required: ValidationRuleWithParams;
  };
  admin_email: {
    required: ValidationRuleWithParams;
  };
};

export type AddUserToOrganizationFormRules = {
  emails: {
    required: ValidationRuleWithParams;
    emails: ValidationRuleWithParams;
  };
};

export type TypeAddUserToOrganizationForm = {
  emails: string[];
};
