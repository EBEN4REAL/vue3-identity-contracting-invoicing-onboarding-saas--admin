import { ResourceAttributeTypeInUseRead } from "../../../../src/policies/policies.types";

const resourceAttributeTypes: {
  [key: string]: ResourceAttributeTypeInUseRead;
} = {
  "001": {
    id: "323ff1a0-50de-4235-b509-6c2afde5078d",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Resource Attribute 001",
    format_option: "STRING",
    in_use: false,
  },
  "002": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb842b",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Resource Attribute 002",
    format_option: "STRING",
    in_use: false,
  },
  Updated001: {
    id: "323ff1a0-50de-4235-b509-6c2afde5078d",
    name: "Resource Attribute 002",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    format_option: "STRING",
    in_use: false,
  },
  Updated002: {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb842b",
    name: "Resource Attribute 005",
    format_option: "INTEGER",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    in_use: false,
  },
  "003": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb842b",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Resource Attribute 003",
    format_option: "STRING",
    in_use: true,
  },
  "004": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb842c",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Resource Attribute 004",
    format_option: "STRING",
    in_use: true,
  },
  "005": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb8425",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Resource Attribute 005",
    format_option: "BOOLEAN",
    in_use: true,
  },
  "006": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb8426",
    service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Resource Attribute 006",
    format_option: "DATETIME",
    in_use: true,
  },
};

export default resourceAttributeTypes;

export { resourceAttributeTypes };
