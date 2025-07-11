import { Given } from "cypress-cucumber-preprocessor/steps";
import serviceProviders from "../../fixtures/service_providers";
import config from "../../../../src/mm.config.json";
import { AttributeSetAttributesOf } from "../../../../src/onboarding/onboarding.types";
import {
  attributeType,
  attributeTypes,
} from "../../fixtures/onboarding/attributeTypes";
import { context } from "../app";
import { attributeSet } from "../../fixtures/onboarding/attributeSets";

Given(
  `the Onboarding get Attribute Types {string} request for Service Provider {string} for type {string} has been intercepted`,
  (
    attributeTypesFixtureId: string,
    serviceProviderFixtureId: string,
    type: AttributeSetAttributesOf,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/attribute-types?attribute_of=${type}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeTypes[attributeTypesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding get Attribute Types {string} request for Service Provider {string} for type {string} and exclude Attribute Set {string} has been intercepted",
  (
    attributeTypesFixtureId: string,
    serviceProviderFixtureId: string,
    type: AttributeSetAttributesOf,
    excludeInAttributeSetFixtureId: string,
  ): void => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const exclude_in_attribute_set_id =
      attributeSet[excludeInAttributeSetFixtureId].id;
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/attribute-types?attribute_of=${type}&exclude_in_attribute_set_id=${exclude_in_attribute_set_id}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeTypes[attributeTypesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);

Given(
  "the Onboarding get Attribute Type {string} request for Service Provider {string} has been intercepted",
  (attributeTypesFixtureId: string, serviceProviderFixtureId: string) => {
    const serviceProviderId: string =
      serviceProviders[serviceProviderFixtureId].id;
    const attributeTypeId = attributeType[attributeTypesFixtureId].id;
    const url: string = `${config.onboarding.url}/service-providers/${serviceProviderId}/attribute-types/${attributeTypeId}`;
    cy.intercept("GET", url, {
      statusCode: 200,
      body: attributeType[attributeTypesFixtureId],
    }).as(url);
    context.aliases.push(url);
  },
);
