Feature: Configuration - Legal Documents - Edit

  Scenario: Should be correctly redirect to edit details view with info
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "001" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    When the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-edit"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"
    And the intercepted requests have resolved
    And the Element with Cypress ID "header-title" contains the text as "doc name"
    And the Element with Cypress ID "header-subtitle" contains the text as "doc desc"
    And the Element with Cypress ID "save-legal-doc-button" should exist
    And the User clicks on the Element with Cypress ID "tab-item-document"
    And the Element with Cypress ID "button-remove-file" should exist
    And the Element with Cypress ID "button-download-file" should exist
    And the Element with Cypress ID "doc-name" should exist

  Scenario: Basic information tab Name and description should be updated
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "001" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    When the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-edit"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"
    And the intercepted requests have resolved
    And the User types "External Name Updated" in Input inside Element with Cypress ID "document-external-name-input"
    And the User types "doc name Updated" in Input inside Element with Cypress ID "document_name_input"
    And the User types "doc description Updated" in Textarea inside Element with Cypress ID "document_description_input"
    And the Configuration PATCH Legal Document Type request has been intercepted to update the Legal Document Type "001" and return "001_Updated" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-legal-doc-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "External Name Updated"
    Then the Element with Cypress ID "mm-data-iterator internal-name mm-data-iterator-item-text" contains the text as "doc name Updated"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "doc description Updated"

  Scenario: Dialog to Delete an existing document should exist and should be possible to close it
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "001" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001?editMode=true"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "legal-document-type-dropdown button"
    And the User clicks on the Element with Cypress ID "legal-document-type-dropdown-item-delete"
    And the Element with Cypress ID "dialog-delete-document" should exist
    And the User clicks on the Element with Cypress ID "dialog-close-button"
    And the Element with Cypress ID "dialog-delete-document" should NOT exist
    And the Configuration Legal Document Types DELETE request has been intercepted to delete Legal Document Type "001" from Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider "001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "legal-document-type-dropdown button"
    And the User clicks on the Element with Cypress ID "legal-document-type-dropdown-item-delete"
    And the User clicks on the Element with Cypress ID "button-submit"
    Then the User should be redirected to "/sp/configuration#Legal-Documents"
    And the intercepted requests have resolved
    And the Element with Cypress ID "dialog-delete-document" should NOT exist
    And the Element with Cypress ID "empty-state-title" should be visible

  Scenario: Should go to Usage Tab correctly with no licenses
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "001" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-edit"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-document"
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    Then the Element with Cypress ID "expandable-card" should have the text as "Licenses (0)"

  Scenario: Delete document should be disabled when legal_document_count > 0
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "002" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "002" PDF URL for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/002?editMode=true"
    When the User clicks on the Element with Cypress ID "button"
    Then the Element with Cypress ID "legal-document-type-dropdown-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "legal-document-type-dropdown-item-hint" should have the text as "You cannot delete this document because it is currently being used."
