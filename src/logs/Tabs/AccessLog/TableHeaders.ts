import { TableHeader } from "~/mm_ui_kit/src/types/table.types";

export const headers: TableHeader[] = [
  {
    label: "Time",
    key: "evaluation_date",
  },
  {
    label: "User",
    key: "user",
  },
  {
    label: "User Org",
    key: "organization",
  },
  {
    label: "Application Name",
    key: "oauth_client",
  },
  {
    label: "Result",
    key: "outcome",
  },
  {
    label: "",
    key: "actions",
  },
];
