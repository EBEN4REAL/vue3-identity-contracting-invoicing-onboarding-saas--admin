Feature: Access Management - User - Policies - Remove policy

Scenario: Should be possible to Remove policy with SP Admin

  Given the User "003" is Signed In
  And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
  And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
  And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
  Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
  When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
  And the intercepted requests have resolved
  Then the Element with Cypress ID "actions" should exist

Scenario: Should be possible to Remove policy with SP Editor

  Given the User "004" is Signed In
  And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
  And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
  And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
  Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
  When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
  And the intercepted requests have resolved
  Then the Element with Cypress ID "actions" should exist

Scenario: Should not be possible to Remove policy with SP Viewer

  Given the User "005" is Signed In
  And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
  And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
  And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
  And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
  Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
  When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
  And the intercepted requests have resolved
  Then the Element with selector ".mm-table-actions-cell" should have the text as ""

Scenario: Show Remove policy Dialog with correct info

  Given the User "004" is Signed In
  And the IAM Service Providers request has been intercepted to return the SP Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
  And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
  And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
  Then the User navigates to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d/user_details/8f970a74-4a32-4690-b1cf-20286505fed0"
  When the User clicks on the Element with Cypress ID "tabs tab-item-policies"
  And the intercepted requests have resolved
  When the User clicks on the Element with Cypress ID "actions-dropdown-001"
  When the User clicks on the Element with Cypress ID "actions-dropdown-001-item-remove-policy"
  Then the Element with Cypress ID "dialog-remove-policy" should exist
  Then the Element with Cypress ID "dialog-title" should have the text as "Remove Policy"
  Then the Element with Cypress ID "dialog-subtitle" should have the text as "Are you sure you want to remove this policy assigned to test test from Acme Inc. SP?"
  Then the Element with Cypress ID "button-cancel" should have the text as "No"
  And the Policies request has been intercepted to unassign Policy "001" from Org User for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
  And the Policies request has been intercepted to return the Policies "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization User "001"
  When the User clicks on the Element with Cypress ID "button-submit"
  And the intercepted requests have resolved
  Then the Element with Cypress ID "actions-dropdown-001-item-delete" should NOT exist
  Then the Element with Cypress ID "dialog-remove-policy" should NOT exist
  Then the Element with Cypress ID "column-name-001" should NOT exist
   