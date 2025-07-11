Feature: Service Provider - Policy Type Roles and Permissions

  Background: Prerequisites
    Given the User "005" is Signed In
    And the feature flag "roles_entitlements" is enabled
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"

  Scenario: Should show correct empty state for table Roles and table Permissions
    When the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    Then the Element with Cypress ID "table-roles" contains the text as "You have no Roles added to this policy"
    And the Element with Cypress ID "button-add-roles" should NOT exist
    And the Element with Cypress ID "table-permissions" contains the text as "You have no Permissions added to this policy"
    And the Element with Cypress ID "button-add-permissions" should NOT exist

  Scenario: Should show correct data for table Roles and table Permissions
    And the Roles "001" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Roles "001" Service Provider "001" request has been intercepted
    And the Role "001" for Service Provider "001" request has been intercepted
    And the Role "002" for Service Provider "001" request has been intercepted
    And the Permissions "001" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Permissions "001" Service Provider "001" request has been intercepted
    And the Permission "001" for Service Provider "001" request has been intercepted
    And the Permission "002" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-roles row-0 name" contains the text as "role1"
    And the Element with Cypress ID "table-roles row-0 description" contains the text as "role1 description"
    And the Element with Cypress ID "table-roles row-1 name" contains the text as "role2"
    And the Element with Cypress ID "table-roles row-1 description" contains the text as "role2 description"
    And the Element with Cypress ID "table-permissions row-0 name" contains the text as "permission1"
    And the Element with Cypress ID "table-permissions row-0 description" contains the text as "permission1 description"
    And the Element with Cypress ID "table-permissions row-1 name" contains the text as "permission2"
    And the Element with Cypress ID "table-permissions row-1 description" contains the text as "permission2 description"

  Scenario: Should add roles if roles already exist in table
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the Roles "001" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Roles "001" Service Provider "001" request has been intercepted
    And the Role "001" for Service Provider "001" request has been intercepted
    And the Role "002" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-add-roles"
    And the User clicks on the Element with Cypress ID "dialog-roles-add autocomplete-roles-add autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-121bd333-2ea0-4ea6-99dd-f63aef432363"
    And the add Roles for Policy Type "001" for Service Provider "001" POST request has been intercepted
    And the Roles "002" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Role "003" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-roles-add button-submit"
    Then the Element with Cypress ID "table-roles row-2 name" contains the text as "role3"
    And the Element with Cypress ID "table-roles row-2 description" contains the text as "role3 description"

  Scenario: Should add roles if roles do not exist
    And the Roles "001" Service Provider "001" request has been intercepted
    And the Roles "000" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "empty-state-button-add-roles"
    And the User clicks on the Element with Cypress ID "dialog-roles-add autocomplete-roles-add autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-121bd333-2ea0-4ea6-99dd-f63aef432363"
    And the User clicks on the Element with Cypress ID "dialog-roles-add button-submit"
    And the Element with Cypress ID "table-roles row-0 name" contains the text as "role3"
    And the Element with Cypress ID "table-roles row-0 description" contains the text as "role3 description"
    And the Roles "002" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Role "003" for Service Provider "001" request has been intercepted
    And the Update Policy request has been intercepted to return the Policy "001" for Service Provider "001"
    And the add Roles for Policy Type "001" for Service Provider "001" POST request has been intercepted
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-roles row-2 name" contains the text as "role3"
    And the Element with Cypress ID "table-roles row-2 description" contains the text as "role3 description"

  Scenario: Should add permissions if permissions already exist in table
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the Permissions "001" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Permissions "001" Service Provider "001" request has been intercepted
    And the Permission "001" for Service Provider "001" request has been intercepted
    And the Permission "002" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-add-permissions"
    And the User clicks on the Element with Cypress ID "dialog-permissions-add autocomplete-permissions-add autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-121bd333-2ea0-4ea6-99dd-f63aef432363"
    And the add Permissions for Policy Type "001" for Service Provider "001" POST request has been intercepted
    And the Permissions "002" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Permission "003" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-permissions-add button-submit"
    Then the Element with Cypress ID "table-permissions row-2 name" contains the text as "permission3"
    And the Element with Cypress ID "table-permissions row-2 description" contains the text as "permission3 description"

  Scenario: Should add permissions if permissions do not exist
    And the Permissions "001" Service Provider "001" request has been intercepted
    And the Permissions "000" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "empty-state-button-add-permissions"
    And the User clicks on the Element with Cypress ID "dialog-permissions-add autocomplete-permissions-add autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-121bd333-2ea0-4ea6-99dd-f63aef432363"
    And the User clicks on the Element with Cypress ID "dialog-permissions-add button-submit"
    And the Element with Cypress ID "table-permissions row-0 name" contains the text as "permission3"
    And the Element with Cypress ID "table-permissions row-0 description" contains the text as "permission3 description"
    And the Permissions "002" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Permission "003" for Service Provider "001" request has been intercepted
    And the Update Policy request has been intercepted to return the Policy "001" for Service Provider "001"
    And the add Permissions for Policy Type "001" for Service Provider "001" POST request has been intercepted
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-permissions row-2 name" contains the text as "permission3"
    And the Element with Cypress ID "table-permissions row-2 description" contains the text as "permission3 description"

  Scenario: Should delete Role
    And the Roles "001" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Roles "001" Service Provider "001" request has been intercepted
    And the Role "001" for Service Provider "001" request has been intercepted
    And the Role "002" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "table-roles row-0 actions actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da"
    And the User clicks on the Element with Cypress ID "actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da-item-delete"
    And the Element with Cypress ID "dialog-role-delete dialog-title" contains the text as "Delete role1"
    And the Role "001" for Policy Type "001" for Service Provider "001" DELETE request has been intercepted
    And the Roles "003" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Role "002" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-role-delete button-submit"
    Then the Element with Cypress ID "table-roles row-0 name" contains the text as "role2"
    And the Element with Cypress ID "table-roles row-0 description" contains the text as "role2 description"

  Scenario: Should delete Permission
    And the Permissions "001" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Permissions "001" Service Provider "001" request has been intercepted
    And the Permission "001" for Service Provider "001" request has been intercepted
    And the Permission "002" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "tab-item-roles-and-permissions"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "table-permissions row-0 actions actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da"
    And the User clicks on the Element with Cypress ID "actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da-item-delete"
    And the Element with Cypress ID "dialog-permission-delete dialog-title" contains the text as "Delete permission1"
    And the Permission "001" for Policy Type "001" for Service Provider "001" DELETE request has been intercepted
    And the Permissions "003" for Policy Type "001" for Service Provider "001" request has been intercepted
    And the Permission "002" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-permission-delete button-submit"
    Then the Element with Cypress ID "table-permissions row-0 name" contains the text as "permission2"
    And the Element with Cypress ID "table-permissions row-0 description" contains the text as "permission2 description"
