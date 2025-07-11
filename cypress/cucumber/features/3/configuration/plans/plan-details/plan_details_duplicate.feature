Feature: Service Provider - Plan Details - Duplicate

  Scenario: After redirect to the New Plan page plan all fields should have correct values
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001AndOptionalPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "license-dropdown-items button"
    When the User clicks on the Element with Cypress ID "license-dropdown-items-item-duplicate"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"
    And the intercepted requests have resolved
    Then the Input with Cypress ID "input-license-name" should have value as "Agreement Type 003"
    And the Input with Cypress ID "input-license-external-name" should have value as "Agreement Type 003 External"
    And the Textarea with Cypress ID "input-license-description" should have value as "Agreement Type 003 Description"
    And the Textarea with Cypress ID "input-license-external-description" should have value as "Agreement Type 003 Description External"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the Element with Cypress ID "table-default-policies row-0 name" contains the text as "Policy 1"
    And the Element with Cypress ID "table-default-policies row-0 description" contains the text as "Policy 1 description"
    And the Element with Cypress ID "table-optional-policies row-0 name" contains the text as "Policy 1"
    And the Element with Cypress ID "table-optional-policies row-0 description" contains the text as "Policy 1 description"
