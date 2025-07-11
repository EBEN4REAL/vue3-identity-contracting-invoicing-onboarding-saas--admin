Feature: Service Provider - Policy Types - Usage

  Scenario: Alert shows the right number of organizations and users

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Policies Usage request has been intercepted to return the Usage "001" for Policy "003" and Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    Then the Element with Cypress ID "alert" contains the text as "This policy is assigned to 13 organizations and 12 users"
    And the Element with Cypress ID "policies-card title" contains the text as "Parent Policies (1)"
    And the Element with Cypress ID "agreements-card title" contains the text as "Licenses (1)"

  Scenario: Alert shows the right number of organizations and users when 0 results

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Policies Usage request has been intercepted to return the Usage "empty" for Policy "003" and Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    Then the Element with Cypress ID "alert" contains the text as "This policy is assigned to 0 organizations and 0 users"
    And the Element with Cypress ID "policies-card title" contains the text as "Parent Policies (0)"
    And the Element with Cypress ID "agreements-card title" contains the text as "Licenses (0)"

  Scenario: Alert shows the right number of organizations and users when 1 result

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Policies Usage request has been intercepted to return the Usage "003" for Policy "003" and Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    Then the Element with Cypress ID "alert" contains the text as "This policy is assigned to 1 organization and 1 user"
    And the Element with Cypress ID "policies-card title" contains the text as "Parent Policies (1)"
    And the Element with Cypress ID "agreements-card title" contains the text as "Licenses (1)"

  Scenario: View button redirects to the policies page

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Policies Usage request has been intercepted to return the Usage "001" for Policy "003" and Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-usage"
    When the User clicks on the Element with Cypress ID "view-policies-button"
    Then the User should be redirected to "/sp/access-control/policy-based#assigned_policies"

  Scenario: Expandable card shows content when clicked

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Policies Usage request has been intercepted to return the Usage "001" for Policy "003" and Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-usage"
    When the User clicks on the Element with Cypress ID "policies-card"
    Then the Element with Cypress ID "child-policy-types" should be visible
    And the Element with Cypress ID "child-policy-types" contains the text as "Policy 001"

