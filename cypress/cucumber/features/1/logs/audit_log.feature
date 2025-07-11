Feature: Logs - Audit

  Scenario: Success from direct URL
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Events request has been intercepted to return the Events "001" for Service Provider "001"
    And the User navigates to "/sp/logs"
    And the intercepted requests have resolved
    And the IAM Audit Events request has been intercepted to return the Audit Events "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-audit-log"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "service-provider-audit-events-Log-table" should be visible
    And the Element with Cypress ID "row-0 payload" should exist
