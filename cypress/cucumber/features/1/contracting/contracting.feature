Feature: Contracting

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/contracting"
    Then the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "002" for Service Provider "001"
    When the User navigates to "/sp/contracting"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "doc name"

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success with SP Admin from App Navigation
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "002" for Service Provider "001"
    When the User clicks on the Element with selector "#app-navigation-contracting"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "doc name"
