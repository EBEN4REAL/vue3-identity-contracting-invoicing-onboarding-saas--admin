Feature: Logs - Access

  Background: Access Logs Enabled
    Given the feature flag "access_logs" is enabled

  Scenario: Success from direct URL
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Events request has been intercepted to return the Events "001" for Service Provider "001"
    And the User navigates to "/sp/logs"
    And the intercepted requests have resolved
    And the IAM Access Evaluations request has been intercepted to return Access Logs "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-access-log"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-access-logs" should be visible
    And the Element with Cypress ID "table-access-logs row-0 evaluation_date" contains the text as "2 Aug 2024, 12:39"
    And the Element with Cypress ID "table-access-logs row-0 user" contains the text as "FirstNameCOM LastNameCOM"
    And the Element with Cypress ID "table-access-logs row-0 organization" contains the text as "Acme Inc. 123"
    And the Element with Cypress ID "table-access-logs row-0 oauth_client" contains the text as "Acme Inc. SP App"
    And the Element with Cypress ID "table-access-logs row-0 outcome" contains the text as "Deny"
