import { EnumBillingPeriod, TypeBillingPeriod } from "~/policies/License/types";

export const SELECT_BILLING_TYPE_OPTIONS = [
  { title: "Free", value: "FREE" },
  { title: "Flat-fee recurring", value: "FLAT_FEE_RECURRING" },
  { title: "Once-off", value: "ONCE_OFF" },
  { title: "Per user", value: "USER_BASED_RECURRING" },
];
export const SELECT_BILLING_PERIOD_OPTIONS: TypeBillingPeriod[] = [
  { title: "Daily", value: EnumBillingPeriod.Day },
  { title: "Weekly", value: EnumBillingPeriod.Week },
  { title: "Monthly", value: EnumBillingPeriod.Month },
  { title: "Yearly", value: EnumBillingPeriod.Year },
];
export const DEFAULT_PRICING = {
  currency: "EUR",
  amount: 0,
  description: null,
  billing_type: "FREE",
  billing_period_length: null,
  billing_period_unit: null,
};
