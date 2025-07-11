Feature: Attribute Set - Edit

  Scenario: Should edit Attribute Set with attributes
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET Attribute Set "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "001" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "002" request for Service Provider "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/2f482486-3588-409c-a4a7-357ecaf426be"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding get Attribute Types "001" request for Service Provider "001" for type "ORGANIZATION" and exclude Attribute Set "002" has been intercepted
    And the User clicks on the Element with Cypress ID "button-edit-attribute-set"
    And the intercepted requests have resolved
    And the User types "Name #2 UPDATED" in Input inside Element with Cypress ID "input-attribute-set-name"
    And the User types "Description #2 UPDATED" in Textarea inside Element with Cypress ID "input-attribute-set-description"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the user drags Element with Cypress ID "attribute-required-f4209d75-5f7f-49ce-a1a2-4a654bf33fcc" to Element with Cypress ID "attributes-optional"
    And the user drags Element with Cypress ID "attribute-optional-963ab010-545c-44d8-a204-bb3bdeae8f8c" to Element with Cypress ID "attributes-required"
    And the Configuration PATCH Attribute Set "002-UPDATED" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002-UPDATED" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "button-save-attribute-set"
    When the User clicks on the Element with Cypress ID "tab-item-basic-information"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-data-iterator name" contains the text as "Name #2 UPDATED"
    Then the Element with Cypress ID "mm-data-iterator description" contains the text as "Description #2 UPDATED"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the Element with Cypress ID "attribute-required-963ab010-545c-44d8-a204-bb3bdeae8f8c" should exist
    And the Element with Cypress ID "attribute-required-963ab010-545c-44d8-a204-bb3bdeae8f8c" contains the text as "#3 Organization"
    And the Element with Cypress ID "attribute-optional-f4209d75-5f7f-49ce-a1a2-4a654bf33fcc" should exist
    And the Element with Cypress ID "attribute-optional-f4209d75-5f7f-49ce-a1a2-4a654bf33fcc" contains the text as "#4 Organization"
