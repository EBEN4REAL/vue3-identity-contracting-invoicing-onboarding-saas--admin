export type TypeResourceType = {
  id: string;
  name: string;
  description: string | null;
  number_of_attributes: number;
  resource_attribute_types: string[];
};

const resourceTypes: { [key: string]: TypeResourceType } = {
  "001": {
    id: "323ff1a0-50de-4235-b509-6c2afde5078d",
    name: "ResourceType Name 001",
    description: "ResourceType Description 001",
    number_of_attributes: 1,
    resource_attribute_types: [
      "323ff1a0-50de-4235-b509-6c2afde5078d",
      "7a1f2c24-33f0-426e-8021-1a203ffb842b",
      "7a1f2c24-33f0-426e-8021-1a203ffb8426",
    ],
  },
  "002": {
    id: "7a1f2c24-33f0-426e-8021-1a203ffb842b",
    name: "Resource Type 002",
    description: "Description 002",
    number_of_attributes: 3,
    resource_attribute_types: ["323ff1a0-50de-4235-b509-6c2afde5078d"],
  },
  Updated001: {
    id: "323ff1a0-50de-4235-b509-6c2afde5078d",
    name: "ResourceType Name 003",
    description: "ResourceType Description 001",
    number_of_attributes: 1,
    resource_attribute_types: [
      "323ff1a0-50de-4235-b509-6c2afde5078d",
      "7a1f2c24-33f0-426e-8021-1a203ffb842b",
    ],
  },
  "001-Updated": {
    id: "323ff1a0-50de-4235-b509-6c2afde5078d",
    name: "ResourceType Name 001 Updated",
    description: "ResourceType Description 001 Updated",
    number_of_attributes: 1,
    resource_attribute_types: ["7a1f2c24-33f0-426e-8021-1a203ffb842c"],
  },
};

export default resourceTypes;

export { resourceTypes };
