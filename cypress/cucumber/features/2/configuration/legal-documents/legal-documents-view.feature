Feature: Configuration - Legal Documents - View

  Scenario: Should be correctly redirect to view with info
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
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-view"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"
    And the Element with Cypress ID "button-edit-document" should exist
    And the Element with Cypress ID "button-download-file" should exist
    And the Element with Cypress ID "legal-document-type-dropdown button" should NOT exist
    And the User clicks on the Element with Cypress ID "tab-item-document"
    And the Element with Cypress ID "button-remove-file" should NOT exist
    And the Element with Cypress ID "doc-name" should have the text as "acme.pdf"
    And the Element with Cypress ID "doc-size" should have the text as "Size: 6KB"
    And the User clicks on the Element with Cypress ID "button-edit-document"
    And the Element with Cypress ID "save-legal-doc-button" should exist
    And the User clicks on the Element with Cypress ID "tab-item-document"
    And the Element with Cypress ID "button-remove-file" should exist
    And the Element with Cypress ID "doc-name" should exist

  Scenario: Should be possible to edit doc name and description and should stay on the same page
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
    And the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-view"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit-document"
    And the User types "External Name Updated" in Input inside Element with Cypress ID "document-external-name-input"
    And the User types "doc name Updated" in Input inside Element with Cypress ID "document_name_input"
    And the User types "doc description Updated" in Textarea inside Element with Cypress ID "document_description_input"
    And the Configuration PATCH Legal Document Type request has been intercepted to update the Legal Document Type "001" and return "001_Updated" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-legal-doc-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "External Name Updated"
    And the Element with Cypress ID "mm-data-iterator internal-name mm-data-iterator-item-text" contains the text as "doc name Updated"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "doc description Updated"
