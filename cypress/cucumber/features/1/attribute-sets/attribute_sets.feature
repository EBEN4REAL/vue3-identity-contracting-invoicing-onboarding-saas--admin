Feature: Attribute Sets - Overview

  Scenario: Should show Attribute Sets in Overview and redirect to Attribute Set View
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Attribute Sets "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "001" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    When the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-attribute-sets row-0 name" contains the text as "Name #1"
    And the Element with Cypress ID "table-attribute-sets row-0 required_attribute_types_count" contains the text as "0"
    And the Element with Cypress ID "table-attribute-sets row-0 optional_attribute_types_count" contains the text as "0"
    And the Element with Cypress ID "table-attribute-sets row-0 type" contains the text as "Organization"
    And the Element with Cypress ID "table-attribute-sets row-0 description" contains the text as "Description #1"
    And the Element with Cypress ID "table-attribute-sets row-1 name" contains the text as "Name #2"
    And the Element with Cypress ID "table-attribute-sets row-1 required_attribute_types_count" contains the text as "1"
    And the Element with Cypress ID "table-attribute-sets row-1 optional_attribute_types_count" contains the text as "2"
    And the Element with Cypress ID "table-attribute-sets row-1 type" contains the text as "User"
    And the Element with Cypress ID "table-attribute-sets row-1 description" contains the text as "Description #2"
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "table-attribute-sets row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-1f482486-3588-409c-a4a7-357ecaf426be-item-view-details"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/1f482486-3588-409c-a4a7-357ecaf426be"
    And the intercepted requests have resolved

  Scenario: Should redirect to Edit Attribute Set from Attribute Sets Overview
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Attribute Sets "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "001" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Types "001" request for Service Provider "001" for type "ORGANIZATION" and exclude Attribute Set "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "table-attribute-sets row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-1f482486-3588-409c-a4a7-357ecaf426be-item-edit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "input-attribute-set-name" should exist

  Scenario: Should delete Attribute Set from Attribute Sets Overview
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Attribute Sets "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "001" usage "000" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "table-attribute-sets row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-1f482486-3588-409c-a4a7-357ecaf426be-item-delete"
    And the Element with Cypress ID "dialog-attribute-set-delete dialog-title" contains the text as "Delete Name #1"
    And the Configuration DELETE Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Sets "002" request for Service Provider "001" has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-attribute-set-delete button-submit"
    Then the Element with Cypress ID "table-attribute-sets row-0 name" contains the text as "Name #2"
    And the Element with Cypress ID "table-attribute-sets row-0 required_attribute_types_count" contains the text as "1"
    And the Element with Cypress ID "table-attribute-sets row-0 optional_attribute_types_count" contains the text as "2"
    And the Element with Cypress ID "table-attribute-sets row-0 type" contains the text as "User"
    And the Element with Cypress ID "table-attribute-sets row-0 description" contains the text as "Description #2"
    And the User clicks on the Element with Cypress ID "table-attribute-sets row-0 actions"
    And the Element with Cypress ID "actions-dropdown-2f482486-3588-409c-a4a7-357ecaf426be-item-hint" contains the text as "This attribute set is being used by 2 Applications. You can only delete this attribute set if there are no references."

  Scenario: Should redirect user to Create Organization Attribute Set
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Attribute Sets "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "001" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding get Attribute Types "001" request for Service Provider "001" for type "ORGANIZATION" has been intercepted
    And the User clicks on the Element with Cypress ID "button-create-attribute-set"
    When the User clicks on the Element with Cypress ID "dropdown-create-attribute-set-item-organization"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/new#organization"
    And the intercepted requests have resolved

  Scenario: Should redirect user to Create User Attribute Set
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Attribute Sets "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "001" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding get Attribute Types "001" request for Service Provider "001" for type "USER" has been intercepted
    And the User clicks on the Element with Cypress ID "button-create-attribute-set"
    When the User clicks on the Element with Cypress ID "dropdown-create-attribute-set-item-user"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/new#user"
    And the intercepted requests have resolved
