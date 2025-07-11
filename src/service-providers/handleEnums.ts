//to be deleted after enums being handled
export const handleEnums = (item) => {
  switch (item.value) {
    case "MAR":
      item.value = "MARKETING";
      break;
    case "SAL":
      item.value = "SALES";
      break;
    case "DEV":
      item.value = "DEVELOPMENT";
      break;
    case "PRO":
      item.value = "PRODUCT";
      break;
    case "CUS":
      item.value = "CUSTOMER_SUPPORT";
      break;
    case "EXE":
      item.value = "EXECUTIVE_MANAGEMENT";
      break;
    case "FIN":
      if (item.value === "FIN" && item.attribute_type === "job_role") {
        item.value = "FINANCE";
      }
      if (item.value === "FIN" && item.attribute_type === "industry") {
        item.value = "FINANCIAL_SERVICES";
      }
      break;
    case "SAA":
      item.industry = "SAAS";
      break;
    case "COM":
      item.value = "COMMERCE";
      break;
    case "HEA":
      item.value = "HEALTHCARE";
      break;
    case "DIG":
      item.value = "DIGITAL_PRODUCTS";
      break;
    case "OTH":
      item.value = "OTHER";
      break;
    default:
      break;
  }
  switch (item.attribute_source) {
    case "S":
      item.attribute_source = "SYSTEM";
      break;
    case "C":
      item.attribute_source = "CONTEXT";
      break;
    case "R":
      item.attribute_source = "RESOURCE";
      break;
    case "O":
      item.attribute_source = "ORGANIZATION";
      break;
    case "OU":
      item.attribute_source = "ORGANIZATION_UNIT";
      break;
    case "UO":
      item.attribute_source = "ORGANIZATION_USER";
      break;
    case "OG":
      item.attribute_source = "ORGANIZATION_GROUP";
      break;
    case "SPU":
      item.attribute_source = "SERVICE_PROVIDER_USER";
      break;
    default:
      break;
  }
  switch (item.operator) {
    case "GT":
      item.operator = "GREATER_THAN";
      break;
    case "GTE":
      item.operator = "GREATER_THAN_OR_EQUAL";
      break;
    case "LT":
      item.operator = "LESS_THAN";
      break;
    case "LTE":
      item.operator = "LESS_THAN_OR_EQUAL";
      break;
    case "EQ":
      item.operator = "EQUAL";
      break;
    case "NEQ":
      item.operator = "NOT_EQUAL";
      break;
    case "EW":
      item.operator = "ENDS_WITH";
      break;
    case "NEW":
      item.operator = "NOT_ENDS_WITH";
      break;
    case "CON":
      item.operator = "CONTAINS";
      break;
    case "N_CON":
      item.operator = "NOT_CONTAINS";
      break;
    case "BEF":
      item.operator = "BEFORE";
      break;
    case "AFT":
      item.operator = "AFTER";
      break;
  }
};

export const handleResources = (item) => {
  switch (item.format_option) {
    case "S":
      item.format_option = "STRING";
      break;
    case "I":
      item.format_option = "INTEGER";
      break;
    case "D":
      item.format_option = "DATETIME";
      break;
    case "B":
      item.format_option = "BOOLEAN";
      break;
    default:
      break;
  }
};

export const handlePolicyRoles = (item) => {
  switch (item.outcome) {
    case "A":
      item.outcome = "ALLOW";
      break;
    case "D":
      item.outcome = "DENY";
      break;
    case "R":
      item.outcome = "ROLE";
      break;
    case "U":
      item.outcome = "AUDIT";
      break;
    case "I":
      item.outcome = "INCONCLUSIVE";
      break;
    default:
      break;
  }
};
