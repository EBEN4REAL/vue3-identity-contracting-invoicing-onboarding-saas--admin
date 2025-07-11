Feature: Service Provider - Policy Type Manage Permissions

  Background: Prerequisites
    Given the User "005" is Signed In
    And the feature flag "roles_entitlements" is enabled
    And the IAM User @me request has been intercepted to return the User "005"
    And the Permissions "001" Service Provider "001" request has been intercepted
    And the Permission Usages "001" for Permission "001" for Service Provider "001" request has been intercepted
    And the Permission Usages "000" for Permission "002" for Service Provider "001" request has been intercepted
    And the Permission Usages "000" for Permission "003" for Service Provider "001" request has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/permissions"

  Scenario: Should show correct data in table
    When the intercepted requests have resolved
    Then the Element with Cypress ID "table-permissions row-0 name" contains the text as "permission1"
    And the Element with Cypress ID "table-permissions row-0 description" contains the text as "permission1 description"
    And the Element with Cypress ID "table-permissions row-1 name" contains the text as "permission2"
    And the Element with Cypress ID "table-permissions row-1 description" contains the text as "permission2 description"
    And the Element with Cypress ID "table-permissions row-2 name" contains the text as "permission3"
    And the Element with Cypress ID "table-permissions row-2 description" contains the text as "permission3 description"

  Scenario: Should add Permission
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-permission"
    And the User types "permission4" in Input inside Element with Cypress ID "dialog-add-permission input-name"
    And the User types "permission4 description" in Textarea inside Element with Cypress ID "dialog-add-permission input-description"
    And the Permission for Service provider "001" POST request has been intercepted
    And the Permissions "002" Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-add-permission button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-permissions row-3 name" contains the text as "permission4"
    And the Element with Cypress ID "table-permissions row-3 description" contains the text as "permission4 description"

  Scenario: Should edit Permission
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "table-permissions row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da-item-edit"
    And the Input inside Element with Cypress ID "dialog-edit-permission input-name" should have the value as "permission1"
    And the Textarea inside Element with Cypress ID "dialog-edit-permission input-description" should have the value as "permission1 description"
    And the User types "permission1updated" in Input inside Element with Cypress ID "dialog-edit-permission input-name"
    And the User types "permission1updated description" in Textarea inside Element with Cypress ID "dialog-edit-permission input-description"
    And the Permission "001" for Service provider "001" PATCH request has been intercepted
    And the Permissions "001-Updated" Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-edit-permission button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-permissions row-0 name" contains the text as "permission1updated"
    And the Element with Cypress ID "table-permissions row-0 description" contains the text as "permission1updated description"

  Scenario: Should delete Permission
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "table-permissions row-1 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-421bd333-2ea0-4ea6-99dd-f63aef432363-item-delete"
    And the Element with Cypress ID "dialog-delete-permission" contains the text as "Delete permission2"
    And the Permission "002" for Service provider "001" DELETE request has been intercepted
    And the Permissions "003" Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "dialog-delete-permission button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-permissions row-0 name" contains the text as "permission1"
    And the Element with Cypress ID "table-permissions row-0 description" contains the text as "permission1 description"
    And the Element with Cypress ID "table-permissions row-1 name" contains the text as "permission3"
    And the Element with Cypress ID "table-permissions row-1 description" contains the text as "permission3 description"

  Scenario: Should show hint on delete Permission button
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "table-permissions row-0 actions"
    Then the Element with Cypress ID "actions-dropdown-5cf7be11-35e0-4eee-9e12-7225182496da-item-hint" contains the text as "This permission is being used by 2 Policies. You can only delete this permission if there are no references."
