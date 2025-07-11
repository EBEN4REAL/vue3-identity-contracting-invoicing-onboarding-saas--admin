import { AttributeSetAttributesOf } from "~/onboarding/onboarding.types";

export type AttributeSetAttributeOfItems = {
  [K in AttributeSetAttributesOf]: string;
};

export const attributeSetAttributeOfItems: AttributeSetAttributeOfItems = {
  ORGANIZATION: "Organization",
  USER: "User",
};

export const transformStringToAttributeOf = (
  attributeOfAsString: string,
): AttributeSetAttributesOf => {
  switch (attributeOfAsString) {
    case "organization":
      return "ORGANIZATION";
    case "user":
      return "USER";
    default:
      return "ORGANIZATION";
  }
};
