import { components } from "../billing_and_invoicing/billing_and_invoicing.schemas";

export enum BillingPeriodUnit {
  DAY = "Daily",
  WEEK = "Weekly",
  MONTH = "Monthly",
  YEAR = "Yearly",
}

export enum PriceModelEnum {
  FREE = "Free",
  ONCE_OFF = "Once-Off",
  FLAT_FEE_RECURRING = "Flat-fee recurring",
  SEAT_BASED_RECURRING = "Seat-based recurring",
  USER_BASED_RECURRING = "Per user",
  TRANSACTION_BASED_RECURRING = "Transaction-based recurring",
}

export const getBillingPeriod = (billingPeriod: string) => {
  switch (billingPeriod) {
    case "MONTH":
      return BillingPeriodUnit.MONTH;
    case "YEAR":
      return BillingPeriodUnit.YEAR;
    case "WEEK":
      return BillingPeriodUnit.WEEK;
    case "DAY":
      return BillingPeriodUnit.DAY;
  }
};

export const getPriceModel = (priceModel: string) => {
  switch (priceModel) {
    case "FREE":
      return PriceModelEnum.FREE;
    case "ONCE_OFF":
      return PriceModelEnum.ONCE_OFF;
    case "FLAT_FEE_RECURRING":
      return PriceModelEnum.FLAT_FEE_RECURRING;
    case "SEAT_BASED_RECURRING":
      return PriceModelEnum.SEAT_BASED_RECURRING;
    case "USER_BASED_RECURRING":
      return PriceModelEnum.USER_BASED_RECURRING;
    case "TRANSACTION_BASED_RECURRING":
      return PriceModelEnum.TRANSACTION_BASED_RECURRING;
  }
};

export type AgreementExtendedRead =
  components["schemas"]["AgreementExtendedRead"];
