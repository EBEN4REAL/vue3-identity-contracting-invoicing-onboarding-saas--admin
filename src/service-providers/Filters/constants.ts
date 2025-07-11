import {
  TypeAttribute,
  TypeDataPerAttribute,
  TypeEnumOperator,
  TypeOperatorsMap,
} from "~/service-providers/filters.type";

const operators: TypeOperatorsMap = {
  [TypeEnumOperator.EQUAL]: "Equal",
  [TypeEnumOperator.NOT_EQUAL]: "Not Equal",
  [TypeEnumOperator.ENDS_WITH]: "Ends with",
  [TypeEnumOperator.NOT_ENDS_WITH]: "Not Ends with",
  [TypeEnumOperator.GREATER_THAN]: "Greater Than",
  [TypeEnumOperator.GREATER_THAN_OR_EQUAL]: "Greater Than or Equal",
  [TypeEnumOperator.LESS_THAN]: "Less Than",
  [TypeEnumOperator.LESS_THAN_OR_EQUAL]: "Less Than or Equal",
  [TypeEnumOperator.CONTAINS]: "Contains",
  [TypeEnumOperator.NOT_CONTAINS]: "Not Contains",
  [TypeEnumOperator.BEFORE]: "Before",
  [TypeEnumOperator.AFTER]: "After",
};

export const operatorsMappedForSelect = Object.entries(operators).map(
  ([key, value]) => ({
    title: value,
    value: key,
  }),
);

export const CRUD = {
  create: "Create",
  read: "Read",
  update: "Update",
  delete: "Delete",
};

export const dataMappedForSelect = (data: Record<string, unknown>) =>
  Object.entries(data).map(([key, value]) => ({
    title: value,
    value: key,
  }));

export const attributes = {
  ORGANIZATION_USER__email: "User Email", // string
  ORGANIZATION_USER__account_verified: "Is User Account verified", // boolean
  ORGANIZATION_USER__job_role: "Organization User Job Role", // enum
  ORGANIZATION__name: "Organization Name", // string
  ORGANIZATION__domain_name: "Organization Domain Name", // string
  ORGANIZATION__industry: "Organization Industry", // enum
  ORGANIZATION__application_name: "Application Name", // enum
  SYSTEM__date: "System Date", // date
  SYSTEM__time: "System Time", // date
  SYSTEM__date_time: "System DateTime", // datetime
  ["RESOURCE__=OPERATION="]: "Resource operation", // enum
};

export const attributesMappedForSelect = Object.keys(attributes).map(
  (key: string) => ({
    title: attributes[key as TypeAttribute],
    value: key,
  }),
);

const dataPerAttribute: TypeDataPerAttribute = {
  ORGANIZATION_USER__email: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.CONTAINS,
      TypeEnumOperator.NOT_CONTAINS,
    ],
    component: "input",
  },
  ORGANIZATION_USER__account_verified: {
    operators: [TypeEnumOperator.EQUAL],
    component: "select-boolean",
  },
  ORGANIZATION_USER__job_role: {
    operators: [TypeEnumOperator.EQUAL, TypeEnumOperator.NOT_EQUAL],
    component: "select-enum",
  },
  ORGANIZATION__name: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.CONTAINS,
      TypeEnumOperator.NOT_CONTAINS,
    ],
    component: "input",
  },
  ORGANIZATION__domain_name: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.CONTAINS,
      TypeEnumOperator.NOT_CONTAINS,
    ],
    component: "input",
  },
  ORGANIZATION__industry: {
    operators: [TypeEnumOperator.EQUAL, TypeEnumOperator.NOT_EQUAL],
    component: "select-enum",
  },
  ORGANIZATION__application_name: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.CONTAINS,
      TypeEnumOperator.NOT_CONTAINS,
    ],
    component: "input",
  },
  SYSTEM__date: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.BEFORE,
      TypeEnumOperator.AFTER,
    ],
    component: "datepicker-date",
  },
  SYSTEM__time: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.BEFORE,
      TypeEnumOperator.AFTER,
    ],
    component: "datepicker-time",
  },
  SYSTEM__date_time: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.BEFORE,
      TypeEnumOperator.AFTER,
    ],
    component: "datepicker-datetime",
  },
  STRING: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.CONTAINS,
      TypeEnumOperator.NOT_CONTAINS,
    ],
    component: "input",
  },
  INTEGER: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.GREATER_THAN,
      TypeEnumOperator.GREATER_THAN_OR_EQUAL,
      TypeEnumOperator.LESS_THAN,
      TypeEnumOperator.LESS_THAN_OR_EQUAL,
    ],
    component: "input",
  },
  DECIMAL: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.NOT_EQUAL,
      TypeEnumOperator.GREATER_THAN,
      TypeEnumOperator.GREATER_THAN_OR_EQUAL,
      TypeEnumOperator.LESS_THAN,
      TypeEnumOperator.LESS_THAN_OR_EQUAL,
    ],
    component: "input",
  },
  DATETIME: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.BEFORE,
      TypeEnumOperator.AFTER,
    ],
    component: "datepicker-datetime",
  },
  DATE: {
    operators: [
      TypeEnumOperator.EQUAL,
      TypeEnumOperator.BEFORE,
      TypeEnumOperator.AFTER,
    ],
    component: "datepicker-date",
  },
  BOOLEAN: {
    operators: [TypeEnumOperator.EQUAL],
    component: "select-boolean",
  },
  ENUM: {
    operators: [TypeEnumOperator.EQUAL, TypeEnumOperator.NOT_EQUAL],
    component: "select-enum",
  },
  ["RESOURCE__=OPERATION="]: {
    operators: [TypeEnumOperator.EQUAL, TypeEnumOperator.NOT_EQUAL],
    component: "select-enum",
  },
};

export { operators, dataPerAttribute };
