Feature: Service Provider - Customer Details

  Scenario: Verify that the Customer Details page display the correct info for all tables
    Given the User "003" is Signed In
    And the feature flag "invoices_overview" is enabled
    And the feature flag "legal_documents" is enabled
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers"
    And the Element with Cypress ID "customers-table" should be visible
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    Then the User clicks on the Element with Cypress ID "row-0 name table-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "001" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "licenses-expandable"
    And the Policies request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with org id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "policies-expandable"
    And the Contracting request has been intercepted to return the legal documents "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    Then the User clicks on the Element with Cypress ID "legal-docs-expandable"
    And the IAM Service Providers request has been intercepted to return the Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "users-expandable"
    And the Billing and Invoicing request has been intercepted to return the Invoices "001" for Service Consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "invoices-expandable"
    And the billing request has been intercepted to return the charges for Service Consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "payments-expandable"
    Then the Element with Cypress ID "licenses-table row-0 agreement_name" should have the text as "ABC Group"
    Then the Element with Cypress ID "invoices-table row-0 id" should have the text as "Invoice001"
    Then the Element with Cypress ID "legal-documents-table row-0 name" should have the text as "doc name"
    Then the Element with Cypress ID "customers-policies-table row-0 name" should have the text as "Policy 1"
    Then the Element with Cypress ID "users-details-table row-0 name" should have the text as "test test"
    Then the Element with Cypress ID "payment-id-column-3fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  
  Scenario: Back to customers button should redirect back to customers overview
    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with org id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "001" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Contracting request has been intercepted to return the legal documents "" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Billing and Invoicing request has been intercepted to return the Invoices "001" for Service Consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User navigates to "/sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the Element with Cypress ID "back-to-link" should have the text as " Back to Customers"
    When the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "back-to-link"
    Then the User should be redirected to "/sp/customers"
