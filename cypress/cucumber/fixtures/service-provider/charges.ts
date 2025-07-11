import { PaymentIntentRead } from "../../../../src/billing_and_invoicing/billing_and_invoicing.schemas.types";
export const charges: {
  [key: string]: PaymentIntentRead;
} = {
  "001": {
    id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    invoice_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    journal_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    service_provider_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    service_consumer_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    currency: "EUR",
    payment_method: "STRIPE",
    date: "2024-09-01T21:18:39.138Z",
    amount: 0,
    from_credit_balance: true,
    succeeded: true,
    failure_reason: null,
    stripe_payment_intent_id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  },
};
