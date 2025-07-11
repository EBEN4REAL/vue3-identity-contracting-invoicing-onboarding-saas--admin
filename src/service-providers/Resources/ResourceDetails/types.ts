export type ResourceAttributeType = {
  id?: string;
  name: string;
  format_option: string;
  resource_attribute_type_id?: string;
};

export type ResourceTypeDetailsForm = {
  name: string;
  description?: string | null;
  resource_attribute_types: ResourceAttributeType[] | null;
};
