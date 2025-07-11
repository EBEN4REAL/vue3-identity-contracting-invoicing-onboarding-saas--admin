import { components } from "~/onboarding/onboarding.schemas";

export type AttributeSetWithCountsRead =
  components["schemas"]["AttributeSetWithCountsRead"] & {
    usagesCount?: number;
  };

export type AttributeSetWithAttributeTypesRead =
  components["schemas"]["AttributeSetWithAttributeTypesRead"];

export type AttributeSetCreate = components["schemas"]["AttributeSetCreate"];

export type AttributeSetUpdate = components["schemas"]["AttributeSetUpdate"];

export type OAuthClientBaseRead = components["schemas"]["OAuthClientBaseRead"];

export type AttributeTypeRead = components["schemas"]["AttributeTypeRead"];

export type AttributeSetAttributesOf =
  components["schemas"]["AttributeSetAttributesOf"];

export type WelcomeComponentsRead =
  components["schemas"]["WelcomeComponentsRead"];

export type ComponentsRead = components["schemas"]["ComponentsRead"];

export type UserWelcomeComponentRead =
  components["schemas"]["UserWelcomeComponentRead"];

export enum WelcomeComponentAppEnum {
  SC = "sc",
  SP = "sp",
}

export type WelcomeComponentsReadParams = {
  app: WelcomeComponentAppEnum;
};

export type WelcomeComponentsCreateParams = {
  app: WelcomeComponentAppEnum;
  component: string;
};

export type AttributeSetRead = components["schemas"]["AttributeSetRead"];

export type OAuthClientGlobalRead =
  components["schemas"]["OAuthClientGlobalRead"];

export type OAuthClientGlobalSettingsRead =
  components["schemas"]["OAuthClientGlobalSettingsRead"];

export type OAuthClientRead = components["schemas"]["OAuthClientRead"];
