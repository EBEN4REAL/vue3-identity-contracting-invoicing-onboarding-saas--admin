export default [
  {
    label: "Date (CEST)",
    key: "timestamp",
    sortable: true,
    order: "desc",
    sortLabel: "Newest first",
    sortName: "timestamp",
    sortIcon: true,
  },
  {
    label: "Event name",
    key: "type",
    sortable: true,
    sortLabel: "Type",
    sortName: "type",
    order: "asc",
    sortIcon: true,
  },
  {
    label: "Organization",
    key: "organization_name",
  },
  {
    label: "Resource",
    key: "payload",
  },
];
