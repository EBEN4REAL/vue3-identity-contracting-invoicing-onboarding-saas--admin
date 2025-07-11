import { OrganizationUnitRead } from "../../../../src/iam/iam.types";

const organizationUnits: { [organization: string]: OrganizationUnitRead[] } = {
  "000": [],
  "001": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [
        {
          id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
          user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
          name: "User",
        },
      ],
    },
    {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 2",
      description: "unit 2 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [
        {
          id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
          name: "User",
        },
      ],
    },
  ],
  "001-no-users": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [],
    },
  ],
  "011": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "Unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [
        {
          id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
          name: "User",
        },
      ],
    },
    {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 11",
      description: "Unit 11 Description",
      parent_organization_unit_id: "01234567-89ab-cdef-0123-456789abcdef",
      users: [],
    },
  ],
  "011-no-users": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "Unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [],
    },
    {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 11",
      description: "Unit 11 Description",
      parent_organization_unit_id: "01234567-89ab-cdef-0123-456789abcdef",
      users: [],
    },
  ],
  "011-no-parent": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "Unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [],
    },
    {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 2",
      description: "Unit 2 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [],
    },
  ],
  "111": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "Unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: [
        {
          id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
          name: "User",
        },
      ],
    },
    {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 11",
      description: "Unit 11 Description",
      parent_organization_unit_id: "01234567-89ab-cdef-0123-456789abcdef",
      users: [],
    },
    {
      id: "21234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 111",
      description: "Unit 111 Description",
      parent_organization_unit_id: "11234567-89ab-cdef-0123-456789abcdef",
      users: [],
    },
  ],
  "004": [
    {
      id: "01234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 1",
      description: "unit 1 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: null,
    },
    {
      id: "11234567-89ab-cdef-0123-456789abcdef",
      name: "Unit 2",
      description: "unit 2 Description",
      parent_organization_unit_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
      users: null,
    },
  ],
};

export default organizationUnits;
