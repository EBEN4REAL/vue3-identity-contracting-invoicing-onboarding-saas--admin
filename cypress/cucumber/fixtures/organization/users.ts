import { OrganizationUserRead } from "../../../../src/iam/iam.types";

const organizationUsers: { [key: string]: OrganizationUserRead } = {
  "001": {
    user_id: "2e80ddf8-3563-467d-9413-f336640ff591",
    status: "P",
  },
  "002": {
    user_id: "9f8c5b13-e6a2-4d87-ae3f-71b4d2f8c492",
    status: "A",
  },
  "003": {
    user_id: "ded35af8-c60c-4f98-b35b-64db59deb4a7",
    status: "R",
  },
};

export default organizationUsers;
