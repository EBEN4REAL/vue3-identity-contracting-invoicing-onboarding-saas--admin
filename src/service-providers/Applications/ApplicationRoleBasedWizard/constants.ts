import { TableHeader } from "~/mm_ui_kit/src/types/table.types";

export const tableHeaders: TableHeader[] = [
  {
    label: "Name",
    key: "name",
  },
  {
    label: "Description",
    key: "description",
  },
  {
    label: "",
    key: "actions",
  },
];

export const ApplicationRoleBasedConfigWizard = {
  ApplicationVerification: 1,
  RolesAndPermissionsVerification: 2,
  ReviewChanges: 3,
};

export const ApplicationWizardStepTitles = {
  1: "Setup application",
  2: "Setup roles and permissions",
  3: "Review",
};
