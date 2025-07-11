Feature: Logs - Access - Details

  Background: Access Logs Enabled
    Given the feature flag "access_logs" is enabled

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/logs/e524b17c-2e34-4dcf-94cf-c201a4bd8945"
    Then the Element with Cypress ID "table-access-logs-details" should NOT exist
    And the Element with Cypress ID "page-not-found-title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/logs/e524b17c-2e34-4dcf-94cf-c201a4bd8945"
    Then the Element with Cypress ID "table-access-logs-details" should NOT exist
    And the Element with Cypress ID "page-not-found-title" should have the text as "404"

  Scenario Outline: Success from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the IAM Access Evaluations request has been intercepted to return Access Log Details "001" for Service Provider "001"
    When the User navigates to "/sp/logs/e524b17c-2e34-4dcf-94cf-c201a4bd8945"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-access-logs-details" should be visible

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success from App Navigation
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Events request has been intercepted to return the Events "001" for Service Provider "001"
    When the User navigates to "/sp/logs"
    And the intercepted requests have resolved
    And the IAM Access Evaluations request has been intercepted to return Access Logs "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-access-log"
    And the intercepted requests have resolved
    And the IAM Access Evaluations request has been intercepted to return Access Log Details "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "table-access-logs row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-e524b17c-2e34-4dcf-94cf-c201a4bd8945-item-view-access-log"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-access-logs-details" should be visible
    And the Element with Cypress ID "detail-value-Organization" contains the text as "Acme Inc."
    And the Element with Cypress ID "detail-value-Resource" contains the text as "-"
    And the Element with Cypress ID "detail-value-User" contains the text as "user@metricsmatter.com"
    And the Element with Cypress ID "detail-value-Date/Time" contains the text as "2 Aug 2024, 12:39"
    And the Element with Cypress ID "detail-value-Result" contains the text as "Allow"
    And the Element with Cypress ID "table-access-logs-details row-0 policy" contains the text as "Policy #1"
    And the Element with Cypress ID "table-access-logs-details row-0 agreement" contains the text as "-"
    And the Element with Cypress ID "table-access-logs-details row-0 outcome" contains the text as "Allow"
