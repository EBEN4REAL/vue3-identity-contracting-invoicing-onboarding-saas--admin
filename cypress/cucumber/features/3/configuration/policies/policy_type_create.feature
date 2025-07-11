Feature: Service Provider - Policy Type Create

  Scenario: Should create Policy Type
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/new"
    And the intercepted requests have resolved
    And the Element with Cypress ID "header-title" contains the text as "Add Policy"
    And the User types "Policy Type 001" in the Element with Cypress ID "policy_external_name_input"
    And the User types "Policy Type 001" in the Element with Cypress ID "policy_name_input"
    And the User types "Policy Type 001 Description" in Textarea inside Element with Cypress ID "policy_external_description_input"
    And the User clicks on the Element with Cypress ID "decision-radio-ALLOW"
    And the Configuration POST Policy Type request has been intercepted to create and return Policy Type "001" for Service Provider "001"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "external-name" contains the text as "External Name"
    And the Element with Cypress ID "internal-name" contains the text as "Policy Type 001"
    And the Element with Cypress ID "external-description" contains the text as "External Description"
    And the Element with Cypress ID "description" contains the text as "Policy Type 001 Description"
    And the Element with Cypress ID "decision" contains the text as "Allow"

  Scenario: Should show Unsaved Changes Dialog when leave page without saving
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/new"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "header-title" contains the text as "Add Policy"
    And the User types "External Name Test" in the Element with Cypress ID "policy_external_name_input"
    And the User types "Test" in the Element with Cypress ID "policy_name_input"
    And the User types "NEW External Description" in Textarea inside Element with Cypress ID "policy_external_description_input"
    And the User clicks on the Element with Cypress ID "decision-radio-ALLOW"
    When the User clicks on the Element with Cypress ID "breadcrumb-link"
    Then the Element with Cypress ID "dialog-unsaved-changes" should exist