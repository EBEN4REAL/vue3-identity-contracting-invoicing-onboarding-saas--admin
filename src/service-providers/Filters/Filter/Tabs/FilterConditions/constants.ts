import {
  TypeAttribute,
  TypeComparisonOperator,
} from "~/service-providers/filters.type";

export const selectBooleanItems = [
  {
    title: "Yes",
    value: "true",
  },
  {
    title: "No",
    value: "false",
  },
];

export const shortcutsForDatepickers = {
  date: [
    "Today",
    "Yesterday",
    "This week",
    "Last week",
    "This month",
    "Last month",
    "This year",
    "Last year",
    "All time",
  ],
  time: [],
  datetime: [
    "Today",
    "Yesterday",
    "This week",
    "Last week",
    "This month",
    "Last month",
    "This year",
    "Last year",
    "All time",
  ],
};

export const inputPlaceholderByAttribute: { [T in TypeAttribute]: string } = {
  ORGANIZATION_USER__email: "Enter email",
  ORGANIZATION_USER__account_verified: "Is account verified?",
  ORGANIZATION_USER__job_role: "Select job role",
  ORGANIZATION__name: "Enter organization name",
  ORGANIZATION__domain_name: "Enter organization domain name",
  ORGANIZATION__industry: "Select industry",
  ORGANIZATION__application_name: "Enter application name",
  SYSTEM__date: "Select date",
  SYSTEM__time: "Select time",
  SYSTEM__date_time: "Select date and time",
  STRING: "Enter value",
  INTEGER: "Enter value",
  DECIMAL: "Enter value",
  DATETIME: "Select date and time",
  DATE: "Select date",
  BOOLEAN: "Select yes or no",
  ENUM: "Select",
  ["RESOURCE__=OPERATION="]: "Select resource operation",
};

export const comparisonOperators: TypeComparisonOperator[] = [
  TypeComparisonOperator.AND,
  TypeComparisonOperator.OR,
];
