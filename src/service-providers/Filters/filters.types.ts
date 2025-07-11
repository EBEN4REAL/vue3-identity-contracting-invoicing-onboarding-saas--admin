import { components } from "~/policies/policies.schemas";
import {
  TypeFilterBasicInformationForm,
  TypeValidationFilterBasicInformation,
  TypeValidatorFilterCondition,
} from "./Filter/Tabs/types";
import { TypeComparisonOperator } from "../filters.type";

export type FilterRead = components["schemas"]["FilterRead"];
export type FilterItem = components["schemas"]["FilterItem"];
export type FilterItemRead = components["schemas"]["FilterItemRead"];
export type NestedFilterRead = components["schemas"]["NestedFilterRead"];
export type FilterCreate = components["schemas"]["FilterCreate"];
export type FilterUpdate = components["schemas"]["FilterUpdate"];
export type PolicyTypePerFilterRead =
  components["schemas"]["PolicyTypePerFilterRead"];
export type ParentFilterPerFilterRead =
  components["schemas"]["ParentFilterPerFilterRead"];

export type TypeDialogFiltersDeleteData = {
  filterId: string;
  filterName: string;
};

export type TypeNestedFilter = {
  parent_filter_id?: string | null;
  child_filter_id?: string | null;
};

export type SettingsTabComponentType = {
  basicInformationEditRef: {
    form: TypeFilterBasicInformationForm;
    v$: TypeValidationFilterBasicInformation;
  };
  filterConditionsEditRef: {
    filter_items: FilterItemRead[];
    filters: FilterRead[];
    operator: TypeComparisonOperator;
    v$List: TypeValidatorFilterCondition[];
  };
};
