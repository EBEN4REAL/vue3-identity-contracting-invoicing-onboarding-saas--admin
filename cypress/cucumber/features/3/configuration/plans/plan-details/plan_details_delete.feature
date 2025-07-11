Feature: Configuration - Plans - Delete

  Scenario: Delete Plan should be disabled if plan is allocated to a customer
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_IncludedInSelfService" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "license-dropdown-items"
    Then the Element with Cypress ID "license-dropdown-items-item-delete" should have a class "mm-dropdown-item--disabled"

  Scenario: Show Confirm Delete Plan dialog should exist after user clicks on Delete
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "license-dropdown-items button"
    And the User clicks on the Element with Cypress ID "license-dropdown-items-item-delete"
    And the Element with Cypress ID "confirm-delete-license" should exist
    When the User clicks on the Element with Cypress ID "button-cancel-delete-license"
    Then the Element with Cypress ID "confirm-delete-license" should NOT exist

  Scenario: Delete Plan successfully and redirect to Licenses page
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the Configuration DELETE Agreement Type request has been intercepted to delete Agreement Type "003" for Service Provider "001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    When the User clicks on the Element with Cypress ID "license-dropdown-items button"
    And the User clicks on the Element with Cypress ID "license-dropdown-items-item-delete"
    And the User clicks on the Element with Cypress ID "confirm-delete-license button-confirm-delete-license"
    Then the User should be redirected to "/sp/configuration#Plans"
    And the intercepted requests have resolved
