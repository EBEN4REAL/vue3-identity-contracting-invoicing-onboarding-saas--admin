Feature: Configuration - Legal Documents

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "table-legal-document-types" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "table-legal-document-types" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success with SP User from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-legal-document-types" should be visible

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success with SP Admin from App Navigation
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/"
    And the intercepted requests have resolved
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User clicks on the Element with selector "#app-navigation-configuration"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-legal-document-types" should be visible
    And the Element with Cypress ID "table-legal-document-types row-0 name" should have the text as "doc name"
    And the Element with Cypress ID "table-legal-document-types row-0 description" should have the text as "doc desc"

  Scenario: Should show correct data in empty table
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-legal-document-types empty-state-title" contains the text as "No legal documents"
    And the Element with Cypress ID "table-legal-document-types button-create-legal-document-type" should exist

  Scenario: Should Delete Legal Document Type
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-delete"
    And the Configuration Legal Document Types DELETE request has been intercepted to delete Legal Document Type "001" from Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "dialog-delete-document button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "dialog-delete-document" should NOT exist
    And the Element with Cypress ID "table-legal-document-types empty-state-title" contains the text as "No legal documents"
    And the Element with Cypress ID "table-legal-document-types button-create-legal-document-type" should exist

  Scenario: Button Delete in dropdown should be disabled if legal document count not 0
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "actions-dropdown-002"
    Then the Element with Cypress ID "actions-dropdown-002-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "actions-dropdown-002-item-hint" should have the text as "You cannot delete this document because it is currently being used."
