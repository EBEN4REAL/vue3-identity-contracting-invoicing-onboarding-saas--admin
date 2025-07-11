Feature: Configuration - Plans - Create

  Scenario: External Name and external description should populate Internal Name and description on creation
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"
    And the intercepted requests have resolved
    And the Element with Cypress ID "button-save-license" should exist
    And the Element with text "Usage" should NOT exist
    And the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "Create Plan"
    And the Element with Cypress ID "header-title" contains the text as "Create Plan"
    When the User types "External Name" in Input inside Element with Cypress ID "input-license-external-name"
    And the User types "External Description" in Textarea inside Element with Cypress ID "input-license-external-description"
    And the User clicks on the Element with Cypress ID "input-license-description"
    Then the Input with Cypress ID "input-license-name" should have value as "External Name"
    And the Textarea with Cypress ID "input-license-description" should have value as "External Description"

  Scenario: Basic information and default Policies should be visible after creating a Plan
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"
    And the intercepted requests have resolved
    And the User types "Agreement Type 003 External" in Input inside Element with Cypress ID "input-license-external-name"
    And the User types "Agreement Type 003" in Input inside Element with Cypress ID "input-license-name"
    And the User types "Agreement Type 003 Description" in Textarea inside Element with Cypress ID "input-license-description"
    And the User types "Agreement Type 003 Description External" in Textarea inside Element with Cypress ID "input-license-external-description"
    And the User clicks on the Element with Cypress ID "button-add-feature"
    And the User types "feature 1" in Input inside Element with Cypress ID "input-feature-0"
    And the User clicks on the Element with Cypress ID "button-remove-feature-0"
    And the Element with Cypress ID "input-feature-0" should NOT exist
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-default-policies"
    And the User clicks on the Element with Cypress ID "autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    And the User clicks on the Element with Cypress ID "button-submit-add-default-policies"
    And the Configuration POST Agreement Types request has been intercepted to create Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Billing and Invoicing request has been intercepted to update and return the Agreement Type "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-data-iterator internal-name mm-data-iterator-item-text" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "mm-data-iterator internal-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description"
    And the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "Agreement Type 003 External"
    And the Element with Cypress ID "mm-data-iterator external-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description External"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the Element with Cypress ID "table-default-policies row-0 name" contains the text as "Policy 1"
    And the Element with Cypress ID "table-default-policies row-0 description" contains the text as "Policy 1 description"

  Scenario: Basic information and optional Policies should be visible after creating a Plan
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"
    And the intercepted requests have resolved
    And the User types "Agreement Type 003 External" in Input inside Element with Cypress ID "input-license-external-name"
    And the User types "Agreement Type 003" in Input inside Element with Cypress ID "input-license-name"
    And the User types "Agreement Type 003 Description" in Textarea inside Element with Cypress ID "input-license-description"
    And the User types "Agreement Type 003 Description External" in Textarea inside Element with Cypress ID "input-license-external-description"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-optional-policies"
    And the User clicks on the Element with Cypress ID "dialog-add-optional-policies autocomplete"
    And the User clicks on the Element with Cypress ID "dialog-add-optional-policies mm-autocomplete-option-001"
    And the User clicks on the Element with Cypress ID "button-submit-add-optional-policies"
    And the Configuration POST Agreement Types request has been intercepted to create Agreement Type "003_WithOptionalPolicy001" for Service Provider "001"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithOptionalPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Billing and Invoicing request has been intercepted to update and return the Agreement Type "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-data-iterator internal-name mm-data-iterator-item-text" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "mm-data-iterator internal-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description"
    And the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "Agreement Type 003 External"
    And the Element with Cypress ID "mm-data-iterator external-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description External"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the Element with Cypress ID "table-optional-policies row-0 name" contains the text as "Policy 1"
    And the Element with Cypress ID "table-optional-policies row-0 description" contains the text as "Policy 1 description"
