import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { Ref } from "vue";

export type UserActiveStatus = {
  title: string;
  value: boolean;
};

export const UserActiveStatuses: UserActiveStatus[] = [
  { title: "Active", value: true },
  { title: "Disabled", value: false },
];

export enum OrganizationUserStatus {
  PENDING = "P",
  ACCEPTED = "A",
  REJECTED = "R",
  CANCELLED = "C",
}

export type TypeOrganizationUsersTabAdditionalQueryParams = {
  status: OrganizationUserStatus;
};

export type TypeInviteUsersForm = {
  emails: string[];
  groups?: string[];
  organizationalUnit?: string | null;
};

export type TypeInviteUsersFormRules = {
  emails: {
    required: ValidationRuleWithParams;
    emails: ValidationRuleWithParams;
  };
};

export type TypeValidatorInviteUsersForm = Ref<
  Validation<TypeInviteUsersFormRules, TypeInviteUsersForm>
>;

export type TypeChangePasswordForm = {
  old: string;
  new: string;
};

export type TypePasswordRules = {
  [key: string]: ValidationRuleWithParams;
};

export type TypeChangePasswordFormRules = {
  old: TypePasswordRules;
  new: TypePasswordRules;
};

export type TypeValidatorChangePassword = Ref<
  Validation<TypeChangePasswordFormRules, TypeChangePasswordForm>
>;
