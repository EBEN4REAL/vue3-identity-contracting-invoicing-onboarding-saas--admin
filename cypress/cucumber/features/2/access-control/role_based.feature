Feature: Access Control - Role Based

  Background: Prerequisites
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories

  Scenario: Success with correct info displayed in Roles tab
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User navigates to "/sp/access-control/role-based"
    Then the Element with Cypress ID "tab-item-roles" should have a class "mm-tabs-item--active"
    Then the Element with Cypress ID "access-control-roles-table" should be visible
    Then the Element with Cypress ID "create-role-button" should be visible
    Then the Element with Cypress ID "sort-icon-name" should have a class "mm-table-header-cell--icon-focused"
    Then the Element with Cypress ID "column-name-001" should have the text as "Policy 1"
    Then the Element with Cypress ID "column-description-001" should have the text as "Policy 1 description"
    When the User clicks on the Element with Cypress ID "actions-001"
    Then the Element with Cypress ID "actions-dropdown-001-item-delete" should NOT have a class "mm-dropdown-item--disabled"
    And the Policies request has been intercepted to return the Policies "001-inverted" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "sort-icon-name"
    Then the Element with Cypress ID "row-0 name" should have the text as "Policy 2"
    And the Element with Cypress ID "sort-icon-name" should NOT have a class "mm-table-header-cell--icon-focused"

  Scenario: Success with correct info displayed in Assigned Roles tab
    And the Policies request has been intercepted to return the All Policies "001,002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "limit=10&offset=0&sort=assigned_on:desc&category_id=a7a82589-c6ae-481d-b87c-16a7009b0d8f"
    And the IAM Service Providers request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with ids "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Organization request has been intercepted to return the Organization with id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" for filter "001" and with user id "1edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/role-based"
    And the User clicks on the Element with Cypress ID "tab-item-assigned-roles"
    Then the Element with Cypress ID "tab-item-assigned-roles" should have a class "mm-tabs-item--active"
    Then the Element with Cypress ID "access-control-assigned-roles-table" should be visible
    Then the Element with Cypress ID "row-0 name" should have the text as "Policy name"
    Then the Element with Cypress ID "row-0 owner_id" should have the text as "Acme Inc. SP"
    Then the Element with Cypress ID "row-0 assigned_to" should have the text as "Organization "
    And the Element with Cypress ID "sort-icon-assigned_on" should NOT have a class "mm-table-header-cell--icon-focused"
    And the Element with Cypress ID "sort-icon-name" should have a class "mm-table-header-cell--icon-focused"
    When the User clicks on the Element with Cypress ID "sort-icon-name"
    And the Policies request has been intercepted to return the All Policies "002,001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "limit=10&offset=0&sort=name:desc&category_id=a7a82589-c6ae-481d-b87c-16a7009b0d8f"
    Then the Element with Cypress ID "row-0 name" should have the text as "Policy name 2"