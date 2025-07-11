import { defineStore } from "pinia";
import { Role } from "../service-providers/Applications/ApplicationRoleBasedWizard/types";

type TypeApplicationRoleBasedConfigState = {
  roles: Role[];
  applicationForm: {
    name: string;
    url: string;
    redirectUrls: string[];
    mfa_required: boolean;
    type: "Website" | "API";
  };
};

export const useApplicationRoleBasedConfigStore = defineStore(
  "applicationRoleBasedConfig",
  {
    state: (): TypeApplicationRoleBasedConfigState => ({
      roles: [
        {
          id: crypto.randomUUID(),
          name: "",
          permissions: [],
          searchQuery: "",
        },
      ],
      applicationForm: {
        name: "",
        url: "",
        redirectUrls: [""],
        type: "Website",
        mfa_required: false,
      },
    }),
    getters: {
      getRoleById: (state) => (roleId: string) =>
        state.roles.find((role) => role.id === roleId),
    },
    actions: {
      reset() {
        this.$reset();
      },
    },
  },
);
