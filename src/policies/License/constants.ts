import { TypeCategoryData } from "~/policies/License/types";

export const ACCESS_LICENSE: TypeCategoryData = {
  label: "License",
  category: "ACCESS",
  routeName: "accessLicenseDetails",
  parent: {
    hash: "Access-licenses",
    label: "Access licenses",
  },
  duplicateLabel: "licenses",
};

export const PLAN: TypeCategoryData = {
  label: "Plan",
  category: "SUBSCRIPTION",
  routeName: "PlanDetails",
  parent: {
    hash: "Plans",
    label: "Plans",
  },
  duplicateLabel: "plans",
};
