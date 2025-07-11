Feature: Configuration - Plans - Read

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/66e7a10b-227a-490c-a1c5-f46a6955050e"
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/66e7a10b-227a-490c-a1c5-f46a6955050e"
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Should have correct data in all Tabs
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "header-title" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "header-subtitle" contains the text as "Agreement Type 003 Description"
    And the Element with Cypress ID "mm-data-iterator internal-name mm-data-iterator-item-text" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "Agreement Type 003 External"
    And the Element with Cypress ID "mm-data-iterator external-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description External"
    And the Element with Cypress ID "mm-data-iterator internal-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the Element with Cypress ID "table-default-policies row-0 name" contains the text as "Policy 1"
    And the Element with Cypress ID "table-default-policies row-0 description" contains the text as "Policy 1 description"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the Element with Cypress ID "legal-documents row-0 name" should have the text as "doc name"
    And the Element with Cypress ID "legal-documents row-0 description" should have the text as "doc desc"
    And the User clicks on the Element with Cypress ID "tabs tab-item-usage"
    And the Element with Cypress ID "license-usage-customers-count" contains the text as "0 customers"

  Scenario: Usage tab should contain correct text in customers count if agreement_count is 12
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003_WithAgreementCount" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tabs tab-item-usage"
    Then the Element with Cypress ID "license-usage-customers-count" contains the text as "12 customers"
