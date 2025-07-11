Feature: Logs - Event

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/logs"
    Then the Element with Cypress ID "service-provider-event-Log-table" should NOT exist
    And the Element with Cypress ID "page-not-found-title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/logs"
    Then the Element with Cypress ID "service-provider-event-Log-table" should NOT exist
    And the Element with Cypress ID "page-not-found-title" should have the text as "404"

  Scenario Outline: Success from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Events request has been intercepted to return the Events "001" for Service Provider "001"
    When the User navigates to "/sp/logs"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "service-provider-event-Log-table" should be visible
    And the Element with Cypress ID "navigation-drawer-service-provider-events" should be visible

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success from App Navigation with Search
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Events request has been intercepted to return the Events "001" for Service Provider "001"
    When the User clicks on the Element with selector "#navigation-drawer-service-provider-events"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "service-provider-event-Log-table" should be visible
    And the Element with Cypress ID "navigation-drawer-service-provider-events" should be visible
    And the Element with Cypress ID "header-title" contains the text as "Logs"
    And the Element with Cypress ID "tab-item-event-log" contains the text as "Event Log"
    And the Element with Cypress ID "page-subtitle" contains the text as "Events represent important actions made by your users on Veriam"
    And the Events request has been intercepted to return the Events "001" for Service Provider "001"
    And the User types "ip_address" in the Element with Cypress ID "filter"
    And the intercepted requests have resolved
    And the Element with Cypress ID "row-0 payload" should exist

  Scenario: Sorting and Payload Dialog
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Events request has been intercepted to return the Events "001,002" for Service Provider "001"
    And the User navigates to "/sp/logs"
    And the intercepted requests have resolved
    And the Events request has been intercepted to return the Events "002,001" for Service Provider "001" with query params "&limit=10&offset=0&sort=type:desc"
    When the User clicks on the Element with Cypress ID "sort-icon-type"
    And the intercepted requests have resolved
    And the Events request has been intercepted to return the Events "002,001" for Service Provider "001" with query params "&limit=10&offset=0&sort=timestamp:asc"
    And the User clicks on the Element with Cypress ID "sort-icon-timestamp"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 type" should have the text as "LOGOUT"
    And the User clicks on the Element with Cypress ID "event-log-table-eye-btn-4ee1382c-9fd8-42ab-9847-92b34ec33fa8"
    And the Element with Cypress ID "events-payload-dialog" should be visible
    And the User clicks on the Element with Cypress ID "button"
    And the Element with Cypress ID "events-payload-dialog" should NOT exist
