import { TableResponse } from "../../../../src/mm_ui_kit/src/types/table.types";
import {
  AttributeSetWithAttributeTypesRead,
  AttributeSetWithCountsRead,
  OAuthClientBaseRead,
} from "../../../../src/onboarding/onboarding.types";

export const attributeSets: Record<
  string,
  TableResponse<AttributeSetWithCountsRead>
> = {
  "001": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "1f482486-3588-409c-a4a7-357ecaf426be",
        name: "Name #1",
        type: "ORGANIZATION",
        description: "Description #1",
        required_attribute_types_count: 0,
        optional_attribute_types_count: 0,
      },
      {
        id: "2f482486-3588-409c-a4a7-357ecaf426be",
        name: "Name #2",
        type: "USER",
        description: "Description #2",
        required_attribute_types_count: 1,
        optional_attribute_types_count: 2,
      },
    ],
    size: 2,
    total: 2,
  },
  "002": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "2f482486-3588-409c-a4a7-357ecaf426be",
        name: "Name #2",
        type: "USER",
        description: "Description #2",
        required_attribute_types_count: 1,
        optional_attribute_types_count: 2,
      },
    ],
    size: 2,
    total: 2,
  },
  "003": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "1f482486-3588-409c-a4a7-357ecaf426be",
        name: "Name #1",
        type: "ORGANIZATION",
        description: "Description #1",
        required_attribute_types_count: 0,
        optional_attribute_types_count: 0,
      },
      {
        id: "2f482486-3588-409c-a4a7-357ecaf426be",
        name: "Name #2",
        type: "USER",
        description: "Description #2",
        required_attribute_types_count: 1,
        optional_attribute_types_count: 2,
      },
      {
        id: "3f482486-3588-409c-a4a7-357ecaf426be",
        name: "Name #3",
        type: "ORGANIZATION",
        description: "Description #3",
        required_attribute_types: ["834a49d7-00e8-430a-8cad-ccbb357903ce"],
        optional_attribute_types: ["39028484-3fa7-48c9-9719-9735320fa388"],
      },
      {
        id: "9895eefc-6deb-4d5c-8421-b51af2945990",
        name: "Name #4",
        type: "USER",
        description: "Description #4",
        required_attribute_types: ["834a49d7-00e8-430a-8cad-ccbb357903ce"],
        optional_attribute_types: ["39028484-3fa7-48c9-9719-9735320fa388"],
      },
      {
        id: "9895eefc-6deb-4d5c-8421-b51af2945991",
        name: "Name #5",
        type: "USER",
        description: "Description #5",
        required_attribute_types: ["834a49d7-00e8-430a-8cad-ccbb357903ce"],
        optional_attribute_types: ["39028484-3fa7-48c9-9719-9735320fa388"],
      },
    ],
    size: 4,
    total: 4,
  },
};

export const attributeSet: Record<string, AttributeSetWithAttributeTypesRead> =
  {
    "001": {
      id: "1f482486-3588-409c-a4a7-357ecaf426be",
      name: "Name #1",
      type: "ORGANIZATION",
      description: "Description #1",
      required_attribute_types: [],
      optional_attribute_types: [],
    },
    "002": {
      id: "2f482486-3588-409c-a4a7-357ecaf426be",
      name: "Name #2",
      type: "ORGANIZATION",
      description: "Description #2",
      required_attribute_types: ["f4209d75-5f7f-49ce-a1a2-4a654bf33fcc"],
      optional_attribute_types: ["963ab010-545c-44d8-a204-bb3bdeae8f8c"],
    },
    "002-UPDATED": {
      id: "2f482486-3588-409c-a4a7-357ecaf426be",
      name: "Name #2 UPDATED",
      type: "ORGANIZATION",
      description: "Description #2 UPDATED",
      required_attribute_types: ["963ab010-545c-44d8-a204-bb3bdeae8f8c"],
      optional_attribute_types: ["f4209d75-5f7f-49ce-a1a2-4a654bf33fcc"],
    },
    "003": {
      id: "3f482486-3588-409c-a4a7-357ecaf426be",
      name: "Name #3",
      type: "ORGANIZATION",
      description: "Description #3",
      required_attribute_types: ["834a49d7-00e8-430a-8cad-ccbb357903ce"],
      optional_attribute_types: ["39028484-3fa7-48c9-9719-9735320fa388"],
    },
    "004": {
      id: "9895eefc-6deb-4d5c-8421-b51af2945990",
      name: "Name #4",
      type: "USER",
      description: "Description #4",
      required_attribute_types: ["834a49d7-00e8-430a-8cad-ccbb357903ce"],
      optional_attribute_types: ["39028484-3fa7-48c9-9719-9735320fa388"],
    },
    "005": {
      id: "9895eefc-6deb-4d5c-8421-b51af2945991",
      name: "Name #5",
      type: "USER",
      description: "Description #5",
      required_attribute_types: ["834a49d7-00e8-430a-8cad-ccbb357903ce"],
      optional_attribute_types: ["39028484-3fa7-48c9-9719-9735320fa388"],
    },
  };

export const attributeSetUsage: Record<
  string,
  TableResponse<OAuthClientBaseRead>
> = {
  "000": {
    offset: 0,
    limit: 10,
    results: [],
    size: 0,
    total: 0,
  },
  "001": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "edf44f93-2b8f-4255-b7ed-23558fc46bee",
        service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      },
      {
        id: "7a1f2c24-33f0-426e-8021-1a203ffb842b",
        service_provider_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      },
    ],
    size: 2,
    total: 2,
  },
};
