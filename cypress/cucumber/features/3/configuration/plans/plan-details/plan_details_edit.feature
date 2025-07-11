Feature: Configuration - Plans - Edit

  Scenario: Should successfully update Marketing Feature Element
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "button-add-feature"
    And the User types "Feature 0" in Input inside Element with Cypress ID "input-feature-0"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003" and return Agreement Type "003_WithMarketingFeature0" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    Then the Input with Cypress ID "input-feature-0" should have value as "Feature 0"

  Scenario: Should successfully drag Marketing Feature Element
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithMarketingFeatures0And1" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "button-add-feature"
    When the user drags Element with Cypress ID "input-feature-0" to Element with Cypress ID "input-feature-1"
    Then the Input with Cypress ID "input-feature-0" should have value as "Feature 1"
    And the Input with Cypress ID "input-feature-1" should have value as "Feature 0"

  Scenario: Should successfully delete Marketing Feature Element
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithMarketingFeatures0And1" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "button-remove-feature-1"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003_WithMarketingFeatures0And1" and return Agreement Type "003_WithMarketingFeature0" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "input-feature-1" should NOT exist

  Scenario: Should successfully update Basic Information
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User types "Agreement Type 003 External Updated" in Input inside Element with Cypress ID "input-license-external-name"
    And the User types "Agreement Type 003 Updated" in Input inside Element with Cypress ID "input-license-name"
    And the User types "Agreement Type 003 Description Updated" in Textarea inside Element with Cypress ID "input-license-description"
    And the User types "Agreement Type 003 Description External Updated" in Textarea inside Element with Cypress ID "input-license-external-description"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003_WithDefaultPolicy001" and return Agreement Type "003_WithDefaultPolicy001Updated" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-data-iterator internal-name mm-data-iterator-item-text" contains the text as "Agreement Type 003 Updated"
    And the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "Agreement Type 003 External Updated"
    And the Element with Cypress ID "external-description mm-data-iterator-item-text" should have the text as "Agreement Type 003 Description External Updated"
    And the Element with Cypress ID "mm-data-iterator internal-description mm-data-iterator-item-text" contains the text as "Agreement Type 003 Description Updated"

  Scenario: Should successfully remove Default and Optional Policy Types
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicies001And002AndOptionalPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa5"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa5-item-delete-policy"
    And the User clicks on the Element with Cypress ID "button-confirm-delete-policy"
    And the User clicks on the Element with Cypress ID "table-optional-policies actions-2005ebf0-012e-460c-9670-846aab8fbb41"
    And the User clicks on the Element with Cypress ID "actions-dropdown-2005ebf0-012e-460c-9670-846aab8fbb41-item-delete-policy"
    And the User clicks on the Element with Cypress ID "button-confirm-delete-policy"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003_WithDefaultPolicies001And002AndOptionalPolicy001" and return Agreement Type "003_WithDefaultPolicy001Updated" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-default-policies row-1" should NOT exist
    And the Element with Cypress ID "table-optional-policies row-0" should NOT exist

  Scenario: Should successfully add Policy Types
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-default-policies"
    And the User clicks on the Element with Cypress ID "dialog-add-default-policies autocomplete"
    And the User clicks on the Element with Cypress ID "dialog-add-default-policies mm-autocomplete-option-002"
    And the User clicks on the Element with Cypress ID "button-submit-add-default-policies"
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-optional-policies"
    And the User clicks on the Element with Cypress ID "dialog-add-optional-policies autocomplete"
    And the User clicks on the Element with Cypress ID "dialog-add-optional-policies mm-autocomplete-option-001"
    And the User clicks on the Element with Cypress ID "button-submit-add-optional-policies"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003_WithDefaultPolicy001" and return Agreement Type "003_WithDefaultPolicies001And002AndOptionalPolicy001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-default-policies row-1" should exist
    And the Element with Cypress ID "table-optional-policies row-0" should exist
