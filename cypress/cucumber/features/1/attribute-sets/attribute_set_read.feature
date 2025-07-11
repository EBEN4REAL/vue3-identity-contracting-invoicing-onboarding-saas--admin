Feature: Attribute Set - Read

  Scenario: Should read Attribute Set with attributes
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET Attribute Set "002" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "001" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/2f482486-3588-409c-a4a7-357ecaf426be"
    When the intercepted requests have resolved
    Then the Element with Cypress ID "mm-data-iterator name" contains the text as "Name #2"
    And the Element with Cypress ID "mm-data-iterator description" contains the text as "Description #2"
    And the User clicks on the Element with Cypress ID "tab-item-attributes"
    And the Element with Cypress ID "attribute-required-f4209d75-5f7f-49ce-a1a2-4a654bf33fcc" contains the text as "#4 Organization"
    And the Element with Cypress ID "attribute-optional-963ab010-545c-44d8-a204-bb3bdeae8f8c" contains the text as "#3 Organization"
    And the User clicks on the Element with Cypress ID "tab-item-usage"
    And the Element with Cypress ID "expandable-card-usages title" contains the text as "Applications (2)"
    And the Element with Cypress ID "table-applications row-0 name" contains the text as "Auth Client 001"
    And the Element with Cypress ID "table-applications row-0 description" contains the text as "Client 001"
    And the Element with Cypress ID "table-applications row-1 name" contains the text as "Auth Client 002"
    And the Element with Cypress ID "table-applications row-1 description" contains the text as "Client 002"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should navigate to Application Details page from Attribute Set tab Usage
    Given the User "005" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET Attribute Set "002" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "001" request for Service Provider "001" has been intercepted
    And the Onboarding get Attribute Type "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "002" usage "001" request for Service Provider "001" has been intercepted
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "002" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/attribute-sets/2f482486-3588-409c-a4a7-357ecaf426be"
    And the intercepted requests have resolved
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "003" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "004" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-usage"
    And the User clicks on the Element with Cypress ID "table-applications row-0 actions"
    When the User clicks on the Element with Cypress ID "actions-dropdown-edf44f93-2b8f-4255-b7ed-23558fc46bee-item-view-application"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
