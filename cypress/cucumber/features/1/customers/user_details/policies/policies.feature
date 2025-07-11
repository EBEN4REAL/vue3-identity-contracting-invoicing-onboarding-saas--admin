Feature: Service Provider - User - Policies Page

  Scenario: Policies table should exist with correct data

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
    When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "users-policies-table" should be visible
