Feature: Configuration - Plans - Manage Legal Documents

  Scenario: On Plan view mode button remove on actions should not exist and should be correctly redirected
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "plans-table row-0 name" contains the text as "Agreement Type 003"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-view"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the Element with Cypress ID "row-0 name" contains the text as "doc name"
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "001" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-001"
    And the Element with Cypress ID "actions-dropdown-001-item-remove-from-" should NOT exist
    When the User clicks on the Element with Cypress ID "actions-dropdown-001-item-go-to-doc-name"
    Then the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"

  Scenario: On Plan edit mode button remove on actions should exist
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-edit"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7?editMode=true"
    And the intercepted requests have resolved
    And the Element with Cypress ID "button-save-license" should be visible
    When the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the User clicks on the Element with Cypress ID "actions-001"
    Then the Element with Cypress ID "actions-dropdown-001-item-remove-from-agreement-type-003" should exist
    And the Element with Cypress ID "button-add-legal-document" should exist

  Scenario: Add Legal Document Modal should exist and should be possible to close it
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the Element with Cypress ID "button-add-legal-document" should exist
    And the User clicks on the Element with Cypress ID "button-add-legal-document"
    And the Element with Cypress ID "add-legal-document-dialog" should exist
    And the Element with Cypress ID "dialog-title" should have the text as "Add Legal Document to Agreement Type 003"
    And the Element with Cypress ID "button-confirm-add-document" should have the attribute "disabled" as "disabled"
    And the User clicks on the Element with Cypress ID "add-documents-select autocomplete"
    And the Element with Cypress ID "mm-autocomplete-option-001" should have the text as "doc name doc desc"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    When the User clicks on the Element with Cypress ID "button-cancel-add-document"
    Then the Element with Cypress ID "add-legal-document-dialog" should NOT exist

  Scenario: After user adds a document dropdown item should have selected label and should be possible to remove it
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the User clicks on the Element with Cypress ID "button-add-legal-document"
    And the User clicks on the Element with Cypress ID "add-documents-select autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    And the Element with Cypress ID "button-confirm-add-document" should be NOT disabled
    And the User clicks on the Element with Cypress ID "button-confirm-add-document"
    And the Element with Cypress ID "row-0 name" should have the text as "doc name"
    And the User clicks on the Element with Cypress ID "button-add-legal-document"
    And the User clicks on the Element with Cypress ID "add-documents-select autocomplete"
    And the Element with Cypress ID "badge-added" should exist
    And the Element with Cypress ID "button-remove-legal-doc" should exist
    And the User clicks on the Element with Cypress ID "button-remove-legal-doc"
    And the Element with Cypress ID "badge-added" should NOT exist
    When the User clicks on the Element with Cypress ID "dialog-close-button"
    Then the Element with Cypress ID "empty-state-title" should exist

  Scenario: Should be possible to add a document correctly
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-default-policies"
    And the User clicks on the Element with Cypress ID "autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    And the User clicks on the Element with Cypress ID "button-submit-add-default-policies"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the User clicks on the Element with Cypress ID "button-add-legal-document"
    And the User clicks on the Element with Cypress ID "add-documents-select autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    And the Element with Cypress ID "button-confirm-add-document" should be NOT disabled
    And the User clicks on the Element with Cypress ID "button-confirm-add-document"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003" and return Agreement Type "003" for Service Provider "001"
    And the Configuration POST Legal Document Types request has been intercepted to return the Agreement Type to Legal Document Types "" for Agreement Type "003" for for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    Then the Element with Cypress ID "button-edit-license" should exist
    And the Element with Cypress ID "row-0 name" contains the text as "doc name"

  Scenario: Should be possible to close the delete document modal
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-edit"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7?editMode=true"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the User clicks on the Element with Cypress ID "actions-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-remove-from-agreement-type-003"
    And the Element with Cypress ID "delete-document-dialog" should exist
    When the User clicks on the Element with Cypress ID "button-cancel-remove-document"
    Then the Element with Cypress ID "delete-document-dialog" should NOT exist

  Scenario: Should be possible to delete a document
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-edit"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7?editMode=true"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the User clicks on the Element with Cypress ID "actions-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-remove-from-agreement-type-003"
    And the Element with Cypress ID "delete-document-dialog" should exist
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003_WithDefaultPolicy001" and return Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    And the Configuration DELETE Legal Document Type from Agreement Type request has been intercepted for Legal Document Type "001" and Agreement Type "003_WithDefaultPolicy001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-confirm-remove-document"
    And the User clicks on the Element with Cypress ID "button-save-license"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the Element with Cypress ID "empty-state-title" should exist

  Scenario: Add document button should be disabled if there is active instances of an agreement
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003_WithAgreementCount" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-edit"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7?editMode=true"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the Element with Cypress ID "button-add-legal-document" should have the attribute "disabled" as "disabled"
    When the User clicks on the Element with Cypress ID "actions-001"
    Then the Element with Cypress ID "actions-dropdown-001-item-remove-from-agreement-type-003" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "actions-dropdown-001-item-hint" should have the text as "Cannot edit legal documents as there are active instances of the plan"
