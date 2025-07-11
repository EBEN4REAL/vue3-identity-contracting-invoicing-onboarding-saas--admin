Feature: Service Provider - Filter Details - Delete

  Scenario: Show Confirm Delete Filter dialog should exist after user clicks on Delete
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the User clicks on the Element with Cypress ID "filter-header-dropdown button"
    When the User clicks on the Element with Cypress ID "filter-header-dropdown-item-delete"
    Then the Element with Cypress ID "confirm-delete-filter" should exist

  Scenario: Show Confirm Delete Filter dialog should NOT exist after user clicks on Cancel
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the User clicks on the Element with Cypress ID "filter-header-dropdown button"
    And the User clicks on the Element with Cypress ID "filter-header-dropdown-item-delete"
    When the User clicks on the Element with Cypress ID "button-cancel-delete-filter"
    Then the Element with Cypress ID "confirm-delete-filter" should NOT exist

  Scenario: Delete Filter successfully and redirect to Configuration page
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the User clicks on the Element with Cypress ID "filter-header-dropdown button"
    And the User clicks on the Element with Cypress ID "filter-header-dropdown-item-delete"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to delete the Filter item with id "001"
    When the User clicks on the Element with Cypress ID "confirm-delete-filter button-confirm-delete-filter"
    Then the User should be redirected to "/sp/configuration"
