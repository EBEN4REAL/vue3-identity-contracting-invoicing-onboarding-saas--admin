import { TableResponse } from "../../../../src/mm_ui_kit/src/types/table.types";
import { AttributeTypeRead } from "../../../../src/onboarding/onboarding.types";

export const attributeTypes: Record<
  string,
  TableResponse<AttributeTypeRead>
> = {
  "001": {
    offset: 0,
    limit: 10,
    results: [
      {
        id: "963ab010-545c-44d8-a204-bb3bdeae8f8c",
        attribute_of: "ORGANIZATION",
        data_type: "uuid",
        name: "#3 Organization",
        enabled: true,
        restrictions: null,
      },
      {
        id: "f4209d75-5f7f-49ce-a1a2-4a654bf33fcc",
        attribute_of: "ORGANIZATION",
        data_type: "string",
        name: "#4 Organization",
        enabled: true,
        restrictions: {},
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
        id: "834a49d7-00e8-430a-8cad-ccbb357903ce",
        attribute_of: "USER",
        data_type: "datetime",
        name: "#5 Organization",
        enabled: false,
        restrictions: null,
      },
      {
        id: "39028484-3fa7-48c9-9719-9735320fa388",
        attribute_of: "USER",
        data_type: "string",
        name: "#6 Organization",
        enabled: false,
        restrictions: {},
      },
    ],
    size: 2,
    total: 2,
  },
};

export const attributeType: Record<string, AttributeTypeRead> = {
  "001": {
    id: "963ab010-545c-44d8-a204-bb3bdeae8f8c",
    attribute_of: "ORGANIZATION",
    data_type: "uuid",
    name: "#3 Organization",
    enabled: true,
    restrictions: null,
  },
  "002": {
    id: "f4209d75-5f7f-49ce-a1a2-4a654bf33fcc",
    attribute_of: "ORGANIZATION",
    data_type: "string",
    name: "#4 Organization",
    enabled: true,
    restrictions: {},
  },
  "003": {
    id: "834a49d7-00e8-430a-8cad-ccbb357903ce",
    attribute_of: "USER",
    data_type: "datetime",
    name: "#5 Organization",
    enabled: false,
    restrictions: null,
  },
  "004": {
    id: "39028484-3fa7-48c9-9719-9735320fa388",
    attribute_of: "USER",
    data_type: "string",
    name: "#6 Organization",
    enabled: false,
    restrictions: {},
  },
};
