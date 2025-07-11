export type ServiceProvider = {
  id: string;
  name: string;
  logo_url?: string;
  button_background_color?: string;
  button_text_color?: string;
};

const serviceProviders: { [key: string]: ServiceProvider } = {
  "000": {
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Service Provider 001",
  },
  "001": {
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Service Provider 001",
    logo_url:
      "http://minio:9000/sp-content/00000000-0000-0000-0002-000000000001",
    button_background_color: "072e51",
    button_text_color: "white",
  },
  "002": {
    id: "3a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Service Provider 002",
    logo_url:
      "http://minio:9000/sp-content/00000000-0000-0000-0002-000000000001",
    button_background_color: "072e51",
    button_text_color: "white",
  },
  "003": {
    id: "4a6f01d0-f3c6-4923-ad98-112d6d97355b",
    name: "Service Provider 003",
    logo_url:
      "http://minio:9000/sp-content/00000000-0000-0000-0002-000000000001",
    button_background_color: "eb1405",
    button_text_color: "white",
  },
};

export default serviceProviders;
