Feature: Attribute Sets - Create

  Scenario: Should create new Attribute Set with type Organization
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding get Attribute Types "001" request for Service Provider "001" for type "ORGANIZATION" has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/new#organization"
    And the intercepted requests have resolved
    And the User types "Name #2" in Input inside Element with Cypress ID "input-attribute-set-name"
    And the User types "Description #2" in Textarea inside Element with Cypress ID "input-attribute-set-description"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the user drags Element with Cypress ID "attribute-all-f4209d75-5f7f-49ce-a1a2-4a654bf33fcc" to Element with Cypress ID "attributes-required"
    And the user drags Element with Cypress ID "attribute-all-963ab010-545c-44d8-a204-bb3bdeae8f8c" to Element with Cypress ID "attributes-optional"
    And the Configuration POST Attribute Set "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "001" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-attribute-set"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/2f482486-3588-409c-a4a7-357ecaf426be"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-data-iterator name" contains the text as "Name #2"
    And the Element with Cypress ID "mm-data-iterator description" contains the text as "Description #2"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the Element with Cypress ID "attribute-required-f4209d75-5f7f-49ce-a1a2-4a654bf33fcc" should exist
    And the Element with Cypress ID "attribute-optional-963ab010-545c-44d8-a204-bb3bdeae8f8c" should exist

  Scenario: Should create new Attribute Set with type User
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding get Attribute Types "002" request for Service Provider "001" for type "USER" has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/new#user"
    And the intercepted requests have resolved
    And the User types "Name #2" in Input inside Element with Cypress ID "input-attribute-set-name"
    And the User types "Description #2" in Textarea inside Element with Cypress ID "input-attribute-set-description"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the user drags Element with Cypress ID "attribute-all-834a49d7-00e8-430a-8cad-ccbb357903ce" to Element with Cypress ID "attributes-required"
    And the user drags Element with Cypress ID "attribute-all-39028484-3fa7-48c9-9719-9735320fa388" to Element with Cypress ID "attributes-optional"
    And the Configuration POST Attribute Set "003" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "003" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "003" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "004" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "003" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-attribute-set"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/3f482486-3588-409c-a4a7-357ecaf426be"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-data-iterator name" contains the text as "Name #3"
    And the Element with Cypress ID "mm-data-iterator description" contains the text as "Description #3"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the Element with Cypress ID "attribute-required-834a49d7-00e8-430a-8cad-ccbb357903ce" should exist
    And the Element with Cypress ID "attribute-optional-39028484-3fa7-48c9-9719-9735320fa388" should exist
