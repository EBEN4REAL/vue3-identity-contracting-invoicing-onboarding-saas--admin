Feature: Customers - Import

  Scenario: Correct file name after import via Click
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    When the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    Then the Element with Cypress ID "drag-n-drop-file" contains the text as "test.csv"

  Scenario: Correct file name after import via DragNDrop
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    When the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via DragNDrop
    Then the Element with Cypress ID "drag-n-drop-file" contains the text as "test.csv"

  Scenario: Correct number in You are about to import label
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    When the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    Then the Element with Cypress ID "about-to-import-customers" contains the text as "You are about to import 3 customers"

  Scenario: Correct deleting uploaded file
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    When the User clicks on the Element with Cypress ID "button-delete-uploaded-file"
    Then the Element with Cypress ID "drag-n-drop-file" should NOT exist
    And the Element with Cypress ID "about-to-import-customers" should NOT exist

  Scenario: Should handle error 409 File exists
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    And the IAM Service Providers Organization Imports has been intercepted to return error 409 for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "dialog-import-customers button-submit"
    Then the Element with Cypress ID "drag-n-drop-zone" contains the text as "This file has already been uploaded"
    And the Element with Cypress ID "drag-n-drop-zone" should have a class "mm-drag-n-drop--status-error"

  Scenario: Should handle error 400 Wrong format
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    And the IAM Service Providers Organization Imports has been intercepted to return error 400 for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "dialog-import-customers button-submit"
    Then the Element with Cypress ID "drag-n-drop-zone" contains the text as "The formatting of the file looks different than the sample template."
    And the Element with Cypress ID "drag-n-drop-zone" should have a class "mm-drag-n-drop--status-error"

  Scenario: Should show loading state while importing customers
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    And the IAM Service Providers Organization Imports has been intercepted to return Accepted for import "001" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers Organization Imports has been intercepted to return status for import "001-P" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "dialog-import-customers button-submit"
    Then the Element with Cypress ID "dialog-import-customers dialog-title" contains the text as "test.csv"
    And the Element with Cypress ID "dialog-import-customers dialog-subtitle" contains the text as "Import is in progress... Depending on the number of organizations, this might take a couple of minutes. You can safely close this dialog and continue working in the Veriam portal, your import will continue to run on the background. When the import is completed, you will find the customers on this page."

  Scenario: Should show success state after importing customers
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    And the IAM Service Providers Organization Imports has been intercepted to return Accepted for import "001" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers Organization Imports has been intercepted to return status for import "001-S" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "dialog-import-customers button-submit"
    Then the Element with Cypress ID "dialog-import-customers dialog-title" contains the text as "Import Successful"
    And the Element with Cypress ID "dialog-import-customers dialog-subtitle" contains the text as "You’ve successfully imported 3 customers into Veriam. The users from your customers have been invited to finalize setting up their account, but you can already assign policies and allocate licenses here."

  Scenario: Should show failure state after importing customers
    Given the User "004" is Signed In
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    And the IAM Service Providers Organization Imports has been intercepted to return Accepted for import "001" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers Organization Imports has been intercepted to return status for import "001-F" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "dialog-import-customers button-submit"
    Then the Element with Cypress ID "dialog-import-customers alert" contains the text as "Something went wrong while importing file"

  Scenario: Should update data in table after successful import
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers"
    And the User clicks on the Element with Cypress ID "button-import-customers"
    And the User clicks on the Element with Cypress ID "button-click-to-upload"
    And the User selects file "test.csv" inside DragNDrop with Cypress ID "drag-n-drop-zone" via Click
    And the IAM Service Providers Organization Imports has been intercepted to return Accepted for import "001" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers Organization Imports has been intercepted to return status for import "001-S" for Service provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organizations "002,004,005" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "dialog-import-customers button-submit"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "dialog-import-customers button-close"
    Then the Element with Cypress ID "customers-table row-0 name" contains the text as "Vibes, Inc"
    And the Element with Cypress ID "customers-table row-0 created_date" contains the text as "29 Jul 2024"
    And the Element with Cypress ID "customers-table row-0 is_active" contains the text as "Active"
    And the Element with Cypress ID "customers-table row-1 name" contains the text as "Vibes 007, Inc"
    And the Element with Cypress ID "customers-table row-1 created_date" contains the text as "29 Jul 2024"
    And the Element with Cypress ID "customers-table row-1 is_active" contains the text as "Active"
    And the Element with Cypress ID "customers-table row-2 name" contains the text as "Acme, Inc"
    And the Element with Cypress ID "customers-table row-2 created_date" contains the text as "29 Jul 2024"
    And the Element with Cypress ID "customers-table row-2 is_active" contains the text as "Active"
