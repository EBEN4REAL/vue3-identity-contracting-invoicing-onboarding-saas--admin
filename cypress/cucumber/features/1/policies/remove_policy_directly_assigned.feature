Feature: Service Provider - Remove Policy Directly Assigned

  Scenario: Remove Policy Directly Assigned with correct info

    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Policies request has been intercepted to return the All Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with ids "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User navigates to "/sp/access-control/policy-based#assigned_policies"
    Then the Element with Cypress ID "access-control-assigned-policies-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-remove-policy"
    Then the Element with Cypress ID "dialog-title" should have the text as "Remove Policy"
    Then the Element with Cypress ID "dialog-subtitle" should have the text as "Are you sure you want to remove this policy assigned to null from Org Organization?"
    Then the Element with Cypress ID "button-cancel" should have the text as "No"
    Then the Element with Cypress ID "button-submit" should have the text as " Yes, Delete "

  Scenario: Should be possible to close the Remove Policy Dialog

    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Policies request has been intercepted to return the All Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with ids "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User navigates to "/sp/access-control/policy-based#assigned_policies"
    Then the Element with Cypress ID "access-control-assigned-policies-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-remove-policy"
    When the User clicks on the Element with Cypress ID "button-cancel"
    Then the Element with Cypress ID "dialog-remove-policy" should NOT exist

  Scenario: Should be possible to Remove a Policy for Organization 

    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Policies request has been intercepted to return the All Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with ids "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User navigates to "/sp/access-control/policy-based#assigned_policies"
    Then the Element with Cypress ID "access-control-assigned-policies-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-remove-policy"
    And the Policies request has been intercepted to unassign Policy "001" from Organization for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the All Policies "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "dialog-remove-policy" should NOT exist

  Scenario: Should be possible to Remove a Policy for Organization User

    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Policies request has been intercepted to return the All Policies "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with ids "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User navigates to "/sp/access-control/policy-based#assigned_policies"
    Then the Element with Cypress ID "access-control-assigned-policies-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-remove-policy"
    And the Policies request has been intercepted to unassign Policy "002" from Org User for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies request has been intercepted to return the All Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "dialog-remove-policy" should NOT exist