Feature: Service Provider - Policy Type Manage Roles

  Background: Prerequisites
    Given the User "005" is Signed In
    And the feature flag "roles_entitlements" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Roles "001" Service Provider "001" request has been intercepted
    And the Role Usages "001" for Role "001" for Service Provider "001" request has been intercepted
    And the Role Usages "000" for Role "002" for Service Provider "001" request has been intercepted
    And the Role Usages "000" for Role "003" for Service Provider "001" request has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/roles"

  Scenario: Should show correct data in table
    When the intercepted requests have resolved
    Then the Element with Cypress ID "table-roles row-0 name" contains the text as "role1"
    And the Element with Cypress ID "table-roles row-0 description" contains the text as "role1 description"
    And the Element with Cypress ID "table-roles row-1 name" contains the text as "role2"
    And the Element with Cypress ID "table-roles row-1 description" contains the text as "role2 description"
    And the Element with Cypress ID "table-roles row-2 name" contains the text as "role3"
    And the Element with Cypress ID "table-roles row-2 description" contains the text as "role3 description"

  Scenario: Should add Role
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-role"
    And the User types "role4" in Input inside Element with Cypress ID "dialog-add-role input-name"
    And the User types "role4 description" in Textarea inside Element with Cypress ID "dialog-add-role input-description"
    And the Role for Service provider "001" POST request has been intercepted
    And the Roles "002" Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-add-role button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-roles row-3 name" contains the text as "role4"
    And the Element with Cypress ID "table-roles row-3 description" contains the text as "role4 description"

  Scenario: Should edit Role
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "table-roles row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da-item-edit"
    And the Input inside Element with Cypress ID "dialog-edit-role input-name" should have the value as "role1"
    And the Textarea inside Element with Cypress ID "dialog-edit-role input-description" should have the value as "role1 description"
    And the User types "role1updated" in Input inside Element with Cypress ID "dialog-edit-role input-name"
    And the User types "role1updated description" in Textarea inside Element with Cypress ID "dialog-edit-role input-description"
    And the Role "001" for Service provider "001" PATCH request has been intercepted
    And the Roles "001-Updated" Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-edit-role button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-roles row-0 name" contains the text as "role1updated"
    And the Element with Cypress ID "table-roles row-0 description" contains the text as "role1updated description"

  Scenario: Should delete Role
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "table-roles row-1 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-421bd333-2ea0-4ea6-99dd-f63aef432363-item-delete"
    And the Element with Cypress ID "dialog-delete-role" contains the text as "Delete role2"
    And the Role "002" for Service provider "001" DELETE request has been intercepted
    And the Roles "003" Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-delete-role button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-roles row-0 name" contains the text as "role1"
    And the Element with Cypress ID "table-roles row-0 description" contains the text as "role1 description"
    And the Element with Cypress ID "table-roles row-1 name" contains the text as "role3"
    And the Element with Cypress ID "table-roles row-1 description" contains the text as "role3 description"

  Scenario: Should show hint on delete Role button
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "table-roles row-0 actions"
    Then the Element with Cypress ID "actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da-item-hint" contains the text as "This role is being used by 2 Policies. You can only delete this role if there are no references."
