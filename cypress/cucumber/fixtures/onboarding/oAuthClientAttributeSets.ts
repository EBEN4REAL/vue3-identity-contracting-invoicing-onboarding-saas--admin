import { OAuthClientRead } from "../../../../src/onboarding/onboarding.types";

const OAuthClientAttributeSets: { [key: string]: OAuthClientRead } = {
  "000": {
    user_attribute_set_id: null,
    organization_attribute_set_id: null,
  },
  "001": {
    user_attribute_set_id: null,
    organization_attribute_set_id: "1f482486-3588-409c-a4a7-357ecaf426be",
  },
  "002": {
    user_attribute_set_id: "9895eefc-6deb-4d5c-8421-b51af2945990",
    organization_attribute_set_id: null,
  },
  "003": {
    user_attribute_set_id: "9895eefc-6deb-4d5c-8421-b51af2945990",
    organization_attribute_set_id: "1f482486-3588-409c-a4a7-357ecaf426be",
  },
  "004": {
    user_attribute_set_id: "9895eefc-6deb-4d5c-8421-b51af2945991",
    organization_attribute_set_id: "2f482486-3588-409c-a4a7-357ecaf426be",
  },
  "005": {
    user_attribute_set_id: null,
    organization_attribute_set_id: "2f482486-3588-409c-a4a7-357ecaf426be",
  },
};

export default OAuthClientAttributeSets;
