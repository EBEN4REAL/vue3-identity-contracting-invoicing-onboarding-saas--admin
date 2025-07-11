import { OAuthClientGlobalSettingsRead } from "../../../../src/onboarding/onboarding.types";

const OAuthClientSettings: { [key: string]: OAuthClientGlobalSettingsRead } = {
  "001": {
    self_service: false,
    self_service_redirect_url: null,
  },
  "002": {
    self_service: true,
    self_service_redirect_url: null,
  },
};

export default OAuthClientSettings;
