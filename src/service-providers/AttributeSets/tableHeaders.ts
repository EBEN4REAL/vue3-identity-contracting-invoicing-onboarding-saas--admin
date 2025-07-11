import { TableHeader } from "~/mm_ui_kit/src/types/table.types";

export const tableHeaders: TableHeader[] = [
  {
    key: "name",
    label: "Name",
    order: "desc",
    sortable: true,
    sortIcon: true,
  },
  {
    key: "required_attribute_types_count",
    label: "Required attributes",
  },
  {
    key: "optional_attribute_types_count",
    label: "Optional attributes",
  },
  {
    key: "type",
    label: "Type",
  },
  {
    key: "description",
    label: "Description",
  },
  {
    label: "Created date",
    key: "created_date",
    sortIcon: true,
    order: "desc",
    sortable: true,
    defaultSortItem: true,
  },
  {
    key: "actions",
    label: "",
  },
];
