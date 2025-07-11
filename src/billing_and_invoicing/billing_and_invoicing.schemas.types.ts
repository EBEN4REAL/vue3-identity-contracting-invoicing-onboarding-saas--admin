import { Validation, ValidationRuleWithParams } from "@vuelidate/core";
import { components } from "./billing_and_invoicing.schemas";

export type PriceRead = components["schemas"]["PriceRead"];
export type PriceUpdate = components["schemas"]["PriceUpdate"];
export type BillingPeriodUnitEnum =
  components["schemas"]["BillingPeriodUnitEnum"];
export type BillingTypeEnum = components["schemas"]["BillingTypeEnum"];
export type Currency = components["schemas"]["CurrenciesEnum"];
export type PaymentIntentRead = components["schemas"]["PaymentIntentRead"];
export type AgreementTypeExtendedRead =
  components["schemas"]["AgreementTypeExtendedRead"];

export type TypeEditPrice = Pick<PriceUpdate, "amount" | "description">;

export type TypeValidatorEditPrice = Validation<
  TypeEditPriceFormRules,
  TypeEditPrice
>;

export type TypeEditPriceFormRules = {
  "price.amount": {
    required: ValidationRuleWithParams;
    numeric: ValidationRuleWithParams;
  };
  "price.description": {
    required: ValidationRuleWithParams;
    maxLength: ValidationRuleWithParams;
  };
};
export type AgreementTypeUpdate = components["schemas"]["AgreementTypeUpdate"];
export type AgreementTypeRead = components["schemas"]["AgreementTypeRead"];
export type PaginationSchema_InvoiceRead_ =
  components["schemas"]["PaginationSchema_InvoiceRead_"];
export type InvoiceRead = components["schemas"]["InvoiceRead"];
export type BillingAddressRead = components["schemas"]["BillingAddressRead"];
export type PaginationSchema_BillingAddressRead_ =
  components["schemas"]["PaginationSchema_BillingAddressRead_"];
export type ServiceConsumerRead = components["schemas"]["ServiceConsumerRead"];
export type AgreementCancelPreviewRead =
  components["schemas"]["AgreementCancelPreviewRead"];
