Feature: Login to Organization

  Scenario: Should Show login organizations on Appbar and successfully login to Organization
    Given the User "003With3Orgs" is Signed In
    And the IAM User @me request has been intercepted to return the User "003With3Orgs"
    And the IAM Organization request has been intercepted to return the Organization "001"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to create customer "Org 001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers/4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Element with Cypress ID "organizations-dropdown-items" should be visible
    And the User clicks on the Element with Cypress ID "organizations-dropdown-items org-selection-dropdown-down-icon"
    And the Element with Cypress ID "organizations-dropdown-items-item-org-002" should be visible
    And the POST request for login to organization has been intercepted with id "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591"
    When the User clicks on the Element with Cypress ID "organizations-dropdown-items-item-org-002"
    Then verify that the user is currently in the organization dashboard with the id "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591"

  Scenario: Dropdown icon and clickable area for organization selection should toggle popup successfully
    Given the User "003With3Orgs" is Signed In
    And the IAM User @me request has been intercepted to return the User "003With3Orgs"
    And the IAM Organization request has been intercepted to return the Organization "001"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to create customer "Org 001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers/4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Element with Cypress ID "organizations-dropdown-items" should be visible
    When the User clicks on the Element with Cypress ID "org-selection-dropdown-down-icon"
    Then the Element with Cypress ID "organizations-dropdown-items-item-org-002" should be visible
    And the User clicks on the Element with Cypress ID "org-selection-dropdown-up-icon"
    And the Element with Cypress ID "organizations-dropdown-items-item-org-002" should NOT be visible

  Scenario: Not SP Organization Should Be Disabled in Organization Selector on Appbar
    Given the User "003With3Orgs" is Signed In
    And the IAM User @me request has been intercepted to return the User "003With3Orgs"
    And the IAM Organization request has been intercepted to return the Organization "001"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to create customer "Org 001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers/4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Element with Cypress ID "organizations-dropdown-items" should be visible
    When the User clicks on the Element with Cypress ID "organizations-dropdown-items org-selection-dropdown-down-icon"
    And the Element with Cypress ID "organizations-dropdown-items-item-org-004" should be visible
    Then the Element with Cypress ID "organizations-dropdown-items-item-org-004" should have a class "mm-dropdown-item--disabled"

  Scenario: Successful Login as Support Partner
    Given the User "MMAdmin001" is Signed In
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to create customer "Org 001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM GET Service Provider Organization request has been intercepted to return the Organization "001" for Service Provider with ID "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers/4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Element with Cypress ID "provide-support-nav-link" should be visible
    And the IAM Service Providers request has been intercepted to return All Service Providers
    When the User clicks on the Element with Cypress ID "provide-support-nav-link"
    Then the User should be redirected to "/login/support"
    And the Element with Cypress ID "select-support-organization" should be visible
    When the User clicks on the Element with Cypress ID "select-support-organization"
    And the Element with Cypress ID "mm-autocomplete-option-3a6f01d0-f3c6-4923-ad98-112d6d97355b" should be visible
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the POST request for login to organization has been intercepted with id "3a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User "MMAdmin001-with-aao" is Signed In
    And the IAM User @me request has been intercepted to return the User "MMAdmin001-with-aao"
    And the IAM Organization request has been intercepted to return the Organization "002"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "3a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM GET Service Provider Organization request has been intercepted to return the Organization "002" for Service Provider with ID "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591"
    And the User clicks on the Element with Cypress ID "continue"
    Then verify that the user is currently in the organization dashboard with the id "3a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Element with Cypress ID "support-banner" should be visible
