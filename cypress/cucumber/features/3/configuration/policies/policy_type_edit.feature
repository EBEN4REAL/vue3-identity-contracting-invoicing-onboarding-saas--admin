Feature: Service Provider - Policy Type Edit

  Scenario: Policy type info should be displayed

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    Then the Element with Cypress ID "mm-data-iterator internal-name" contains the text as "Policy Type 001"
    And the Element with Cypress ID "mm-data-iterator description" contains the text as "Policy Type 001 Description"
    And the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "External Name"
    And the Element with Cypress ID "mm-data-iterator external-description mm-data-iterator-item-text" contains the text as "External Description"

  Scenario: Edit button opens the form

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
    Then the Element with Cypress ID "policy-type-edit-form" should be visible
    And the Element with Cypress ID "decision-radio-ALLOW" should have a class "mm-radio-card-active"

   Scenario: Should show Audit Level options when user select Audit decision and Info should be selected by default

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
    Then the Element with Cypress ID "policy-type-edit-form" should be visible
    And the User clicks on the Element with Cypress ID "decision-radio-AUDIT"
    And the Element with Cypress ID "audit-level-options-section" should exist
    And the Element with Cypress ID "audit-level-Info" should have a class "mm-radio-card-active"

  Scenario: Should show Role Name field when user select Roles decision

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
    Then the Element with Cypress ID "policy-type-edit-form" should be visible
    And the User clicks on the Element with Cypress ID "decision-radio-ROLE"
    And the Element with Cypress ID "role_name_input" should exist

  Scenario: Should prefill the Role name with the policy name initially when selecting Roles as decision and should not update when the policy name is updated

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
    Then the Element with Cypress ID "policy-type-edit-form" should be visible
    And the User types "External Name Test" in the Element with Cypress ID "policy_external_name_input"
    And the User types "Policy Test" in the Element with Cypress ID "policy_name_input"
    And the User clicks on the Element with Cypress ID "decision-radio-ROLE"

  Scenario: Save button is enabled by default

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
    Then the Element with Cypress ID "save-policy-type-button" should be NOT disabled
    And the User clicks on the Element with Cypress ID "policy-type-dropdown button"
    And the User clicks on the Element with Cypress ID "policy-type-dropdown-item-discard"
    And the Element with Cypress ID "confirm-discard-dialog" should exist
    And the User clicks on the Element with Cypress ID "button-confirm"
    Then the Element with Cypress ID "edit-policy-type-button" should be visible

  Scenario: The title is changed in create mode

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/new"
    Then the Element with Cypress ID "header-title" contains the text as "Add Policy"

  Scenario: The breadcrumbs are changed in create mode

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/new"
    Then the Element with Cypress ID "breadcrumbs" contains the text as "Add Policy"

  Scenario: Should update Policy Type
    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User types "Updated External Name" in Input inside Element with Cypress ID "policy_external_name_input"
    And the User types "Updated External Description" in Textarea inside Element with Cypress ID "policy_external_description_input"
    And the User clicks on the Element with Cypress ID "decision-radio-DENY"
    And the Update Policy request has been intercepted to return the Policy "001-updated" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001-updated" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "external-name" contains the text as "Updated External Name"
    And the Element with Cypress ID "external-description" contains the text as "Updated External Description"
    And the Element with Cypress ID "decision" contains the text as "Deny"

# I'm not sure about importance of this test so let's leave it and take care later
#  Scenario: Redirect to policies tab after saving
#
#    Given the User "005" is Signed In
#    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
#    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
#    And the Create Policy Types request has been intercepted to return the Policy Type "001" for Service Provider "001"
#    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
#    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
#    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
#    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/new"
#    And the User types "External Name Test" in the Element with Cypress ID "policy_external_name_input"
#    And the User types "Test" in the Element with Cypress ID "policy_name_input"
#    And the User types "Updated External Description" in Textarea inside Element with Cypress ID "policy_external_description_input"
#    And the User clicks on the Element with Cypress ID "decision-radio-ALLOW"
#    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
#    When the User clicks on the Element with Cypress ID "save-policy-type-button"
#    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
#    And the Element with Cypress ID "decision mm-data-iterator-item-text" should have the text as "Allow"
#    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
#    And the User clicks on the Element with Cypress ID "decision-radio-DENY"
#    And the Update Policy request has been intercepted to return the Policy "001" for Service Provider "001"
#    And the Policy request has been intercepted to return the PolicyType "001-updated" for Service Provider "001"
#    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
#    When the User clicks on the Element with Cypress ID "save-policy-type-button"
#    Then the Element with Cypress ID "decision mm-data-iterator-item-text" should have the text as "Deny"
#    When the User clicks on the Element with Cypress ID "edit-policy-type-button"
#    And the User clicks on the Element with Cypress ID "decision-radio-ROLE"
#    And the Update Policy request has been intercepted to return the Policy "001" for Service Provider "001"
#    And the Policy request has been intercepted to return the PolicyType "001-updated-roles" for Service Provider "001"
#    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
#    When the User clicks on the Element with Cypress ID "save-policy-type-button"
#    Then the Element with Cypress ID "decision mm-data-iterator-item-text" should have the text as "Roles"
#    And the Element with Cypress ID "mm-data-iterator external-name mm-data-iterator-item-text" contains the text as "Updated External Name"
#    And the Element with Cypress ID "mm-data-iterator external-description mm-data-iterator-item-text" contains the text as "Updated External Description"