import { BillingAddressRead } from "../../../../src/billing_and_invoicing/billing_and_invoicing.schemas.types";

const billing_addresses: { [key: string]: BillingAddressRead } = {
  "001": {
    address_line_1: "Simsekstraat 2z",
    address_line_2: "de Gruijlstraat 9",
    town_city: "Bosch en Duin",
    postal_code: "1674PG",
    country: "Netherlands",
    default: true,
    service_consumer_id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
  },
};

export default billing_addresses;
