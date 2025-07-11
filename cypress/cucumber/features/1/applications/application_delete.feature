Feature: Application - Delete

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should delete existing Application from Application Details
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the Configuration DELETE OAuth Client request has been intercepted to delete the Oauth Client "001" for Service Provider "001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "application-details-header-dropdown button"
    And the User clicks on the Element with Cypress ID "application-details-header-dropdown-item-delete"
    And the Element with Cypress ID "dialog-confirm-delete-application dialog-title" contains the text as "Delete Auth Client 001"
    When the User clicks on the Element with Cypress ID "dialog-confirm-delete-application button-submit"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/configuration"

  Scenario: Should delete existing Application from Application Overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    And the User navigates to "/sp/applications"
    And the intercepted requests have resolved
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the User clicks on the Element with Cypress ID "actions-dropdown-edf44f93-2b8f-4255-b7ed-23558fc46bee-item-delete"
    And the Configuration DELETE OAuth Client request has been intercepted to delete the Oauth Client "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "dialog-confirm-delete-application button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "name-edf44f93-2b8f-4255-b7ed-23558fc46bee" should NOT exist
