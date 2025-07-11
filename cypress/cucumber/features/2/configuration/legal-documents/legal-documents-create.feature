Feature: Configuration - Legal Documents - Create

  Scenario: User should go to create legal document page
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-legal-documents"
    And the intercepted requests have resolved
    And the Configuration POST Legal Document Types request has been intercepted to create the Legal Document Type "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-create-legal-document"
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/new"
    And the intercepted requests have resolved
    And the Element with text "Usage" should NOT exist
    And the Element with Cypress ID "legal-document-type-dropdown button" should NOT exist
    And the Element with Cypress ID "save-legal-doc-button" should NOT have the attribute "disabled"
    And the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "Legal Document"
    And the Element with Cypress ID "breadcrumb" contains the text as "Create Legal Document"
    And the Element with Cypress ID "header-subtitle" should be empty
    And the Element with Cypress ID "save-legal-doc-button" should exist
    And the Element with Cypress ID "discard-legal-doc-button" should exist
    And the Element with Cypress ID "button-download-file" should NOT exist
    When the User clicks on the Element with Cypress ID "discard-legal-doc-button"
    And the Element with Cypress ID "confirm-discard-dialog" should exist
    And the User clicks on the Element with Cypress ID "button-confirm"
    Then the User should be redirected to "/sp/configuration"

  Scenario: Header Title and subtitle should have correct text when user fills doc name field and description
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration POST Legal Document Types request has been intercepted to create the Legal Document Type "001" for Service Provider "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/new"
    And the intercepted requests have resolved
    And the User types "External Name" in Input inside Element with Cypress ID "document-external-name-input"
    And the User types "Doc Description" in Textarea inside Element with Cypress ID "document_description_input"
    And the Input with Cypress ID "document_name_input" should have value as "External Name"
    And the Element with Cypress ID "header-title" contains the text as "External Name"
    And the Element with Cypress ID "header-subtitle" contains the text as "Doc Description"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "breadcrumb-link"
    And the User clicks on the Element with Cypress ID "button-switch-anyway"
    Then the User should be redirected to "/sp/configuration"
    And the intercepted requests have resolved

  Scenario: Should be possible to upload correctly a document and remove it and check that tooltip appears
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration POST Legal Document Types request has been intercepted to create the Legal Document Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/new"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tab-item-document"
    And the user uploads a file with path "cypress/cucumber/fixtures/acme.pdf" to input with Cypress ID "document-upload"
    Then the Element with Cypress ID "doc-name" should exist
    And the Element with Cypress ID "doc-name" should have the text as "acme.pdf"
    And the Element with Cypress ID "doc-size" should exist
    And the Element with Cypress ID "button-remove-file" should exist
    And the User clicks on the Element with Cypress ID "button-remove-file"
    And the Element with Cypress ID "doc-name" should NOT exist
    And the Element with Cypress ID "doc-size" should NOT exist
    And the Element with Cypress ID "checkbox-signing" gets mouseenter
    And the Element with Cypress ID "tooltip-content" should exist

  Scenario: Should be possible to create a legal document successfully
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration POST Legal Document Types request has been intercepted to create the Legal Document Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/new"
    And the intercepted requests have resolved
    And the User types "External Name" in Input inside Element with Cypress ID "document-external-name-input"
    And the User types "doc name" in Input inside Element with Cypress ID "document_name_input"
    And the User clicks on the Element with Cypress ID "tab-item-document"
    And the user uploads a file with path "cypress/cucumber/fixtures/acme.pdf" to input with Cypress ID "document-upload"
    And the Configuration PATCH Legal Document Type request has been intercepted to update the Legal Document Type "001" and return "001" for Service Provider "001"
    And the Configuration POST Legal Document Type PDF request has been intercepted to upload the Legal Document Type "001" PDF for Service Provider "001"
    And the Configuration GET Legal Document Type request has been intercepted to return Legal Document Type "001" for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-legal-doc-button"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/legal-documents/001"
    And the intercepted requests have resolved
    And the Element with Cypress ID "internal-name mm-data-iterator-item-text" should have the text as "doc name"
    And the Element with Cypress ID "external-name mm-data-iterator-item-text" should have the text as "External Name"
