export enum TypeEnumAttributeSource {
  SYSTEM = "SYSTEM",
  CONTEXT = "CONTEXT",
  RESOURCE = "RESOURCE",
  ORGANIZATION = "ORGANIZATION",
  ORGANIZATION_UNIT = "ORGANIZATION_UNIT",
  ORGANIZATION_USER = "ORGANIZATION_USER",
  ORGANIZATION_GROUP = "ORGANIZATION_GROUP",
  SERVICE_PROVIDER_USER = "SERVICE_PROVIDER_USER",
}

export enum TypeEnumOperator {
  GREATER_THAN = "GREATER_THAN",
  GREATER_THAN_OR_EQUAL = "GREATER_THAN_OR_EQUAL",
  LESS_THAN = "LESS_THAN",
  LESS_THAN_OR_EQUAL = "LESS_THAN_OR_EQUAL",
  EQUAL = "EQUAL",
  NOT_EQUAL = "NOT_EQUAL",
  ENDS_WITH = "ENDS_WITH",
  NOT_ENDS_WITH = "NOT_ENDS_WITH",
  CONTAINS = "CONTAINS",
  NOT_CONTAINS = "NOT_CONTAINS",
  BEFORE = "BEFORE",
  AFTER = "AFTER",
}

export type TypeAttribute =
  | "ORGANIZATION_USER__email"
  | "ORGANIZATION_USER__account_verified"
  | "ORGANIZATION_USER__job_role"
  | "ORGANIZATION__name"
  | "ORGANIZATION__domain_name"
  | "ORGANIZATION__industry"
  | "ORGANIZATION__application_name"
  | "SYSTEM__date"
  | "SYSTEM__time"
  | "SYSTEM__date_time"
  | "STRING"
  | "INTEGER"
  | "DECIMAL"
  | "DATETIME"
  | "DATE"
  | "BOOLEAN"
  | "ENUM"
  | "RESOURCE__=OPERATION=";

export type TypeOperatorsMap = Record<TypeEnumOperator, string>;

export type TypeComponent =
  | "input"
  | "select-boolean"
  | "select-enum"
  | "datepicker-date"
  | "datepicker-time"
  | "datepicker-datetime";

export enum TypeComparisonOperator {
  AND = "AND",
  OR = "OR",
}

export type TypeDataPerAttribute = {
  [K in TypeAttribute]: {
    operators: TypeEnumOperator[];
    component: TypeComponent;
  };
};
