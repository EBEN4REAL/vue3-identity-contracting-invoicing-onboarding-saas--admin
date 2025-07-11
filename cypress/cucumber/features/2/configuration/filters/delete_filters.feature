Feature: Service Provider - Delete Filters

  Scenario: Should see the Delete Filters Dialog with correct info

    Given the User "003" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/configuration"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    Then the Element with Cypress ID "filters-table" should be visible
    Then the Element with Cypress ID "create-filter" should be visible
    When the User clicks on the Element with Cypress ID "actions-001"
    When the User clicks on the Element with Cypress ID "actions-dropdown-001-item-delete"
    Then the Element with Cypress ID "dialog-filter-delete" should be visible
    Then the Element with Cypress ID "dialog-title" should have the text as "Delete Office Hours"
    Then the Element with Cypress ID "dialog-subtitle" should have the text as "Are you sure you want to delete this filter?"
    Then the Element with Cypress ID "button-cancel" should have the text as "No"
    Then the Element with Cypress ID "button-submit" should have the text as " Yes, Delete "

  Scenario: Should be possible to close the Delete Filters Dialog

    Given the User "003" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/configuration"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    When the User clicks on the Element with Cypress ID "actions-001"
    When the User clicks on the Element with Cypress ID "actions-dropdown-001-item-delete"
    When the User clicks on the Element with Cypress ID "button-cancel"
    Then the Element with Cypress ID "dialog-title" should NOT exist


  Scenario: Delete a Filter

    Given the User "003" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/configuration"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    When the User clicks on the Element with Cypress ID "actions-001"
    When the User clicks on the Element with Cypress ID "actions-dropdown-001-item-delete"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to delete the Filter with id "001"
    And the Filters request has been intercepted to return the Filters "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "actions-dropdown-001-item-delete" should NOT exist

    