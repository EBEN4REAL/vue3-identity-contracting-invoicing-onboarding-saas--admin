Feature: Applications

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/applications"
    Then the Element with Cypress ID "applications-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/applications"
    Then the Element with Cypress ID "applications-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    When the User navigates to "/sp/applications"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "applications-table" should be visible

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success from App Navigation
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001,002" for Service Provider "001"
    When the User clicks on the Element with selector "#app-navigation-applications"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "Auth Client 001"
