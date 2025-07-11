import { AgreementMetricsRead } from "../../../src/events/events.types";

export const agreementMetricsFixtures: { [key: string]: AgreementMetricsRead } =
  {
    "001": {
      end_date_active_agreements_count: 11,
      start_date_active_agreements_count: 9,
      new_agreements_in_time_period: 2,
      new_agreements_in_previous_time_period: 5,
      cancelled_agreements_in_time_period: 2,
      cancelled_agreements_in_previous_time_period: 5,
      end_date_predicted_monthly_revenue: {
        EUR: 10,
      },
      start_date_predicted_monthly_revenue: {
        EUR: 20,
      },
      new_agreement_monthly_revenue: {
        EUR: 10,
      },
      cancelled_agreement_monthly_revenue: {
        EUR: 50,
      },
    },
  };
