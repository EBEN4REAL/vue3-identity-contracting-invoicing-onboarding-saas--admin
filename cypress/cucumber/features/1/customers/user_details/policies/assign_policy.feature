Feature: Access Management - User - Policies - Assign policy

 Scenario: Should be possible to Assign policy with SP Admin

    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
    When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "add-policy-button" should exist

Scenario: Should be possible to Assign policy with SP Editor

    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
    When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "add-policy-button" should exist

 Scenario: Should not be possible to Assign policy with SP Viewer

    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
    When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "add-policy-button" should NOT exist

 Scenario: Should be possible to close Assign policy modal correctly

    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
    When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    When the User clicks on the Element with Cypress ID "add-policy-button"
    When the User clicks on the Element with Cypress ID "button-cancel"
    Then the Element with Cypress ID "dialog-assign-policy" should NOT exist

 Scenario: Should be possible to Assign policy correctly

    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the Policies "001,002,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
    When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    When the User clicks on the Element with Cypress ID "add-policy-button"
    Then the Element with Cypress ID "dialog-assign-policy" should exist
    And the Policies request has been intercepted to return the Policies "001-updated" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
    And the User clicks on the Element with Cypress ID "assign-policy-select autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    And the Policies request has been intercepted to assign Policy "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    Then the User clicks on the Element with Cypress ID "button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "dialog-assign-policy" should NOT exist
    And the Element with Cypress ID "column-name-003" should exist
    And the Element with Cypress ID "column-name-003" should have the text as "Policy 3"

 