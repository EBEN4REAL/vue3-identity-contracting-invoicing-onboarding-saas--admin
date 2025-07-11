Feature: Service Provider - Policies Directly Assigned

  Scenario: Success Org User with correct info displayed and sort by name

    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Policies request has been intercepted to return the All Policies "001,002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "limit=10&offset=0&sort=assigned_on:desc&exclude_category_id=a7a82589-c6ae-481d-b87c-16a7009b0d8f"
    And the IAM Service Providers request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with ids "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Organization request has been intercepted to return the Organization with id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" for filter "001" and with user id "1edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/policy-based#assigned_policies"
    Then the Element with Cypress ID "access-control-assigned-policies-table" should be visible
    Then the Element with Cypress ID "row-0 name" should have the text as "Policy name"
    Then the Element with Cypress ID "row-0 assigned_to" should have the text as "Organization "
