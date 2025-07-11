Feature: Subscriptions - Invoices

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/invoices"
    Then the Element with Cypress ID "invoices-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/invoices"
    Then the Element with Cypress ID "invoices-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success with from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Billing and Invoicing request has been intercepted to return the Invoices "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/invoices"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "invoices-table" should be visible

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
    And the Billing and Invoicing request has been intercepted to return the Invoices "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Organization request has been intercepted to return the Organization "001"
    When the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-invoices"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "invoices-table" should be visible
    And the Element with Cypress ID "row-0 quaderno_invoice_number" should have the text as "#Invoice001"
    And the Element with Cypress ID "row-0 total_amount" should have the text as "€0.5"
