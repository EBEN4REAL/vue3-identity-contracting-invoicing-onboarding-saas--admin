import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";

export const ConfigPublishStatusEnum = {
  DRAFT: {
    badge: BadgeTypes.Inactive,
    enum: "DRAFT",
    readable: "Draft",
  },
  FAILED: {
    badge: BadgeTypes.Cancelled,
    enum: "FAILED",
    readable: "Failed",
  },
  PUBLISHED: {
    badge: BadgeTypes.Active,
    enum: "PUBLISHED",
    readable: "Published",
  },
  PUBLISHING: {
    badge: BadgeTypes.Warning,
    enum: "PUBLISHING",
    readable: "Publishing",
  },
  DELETING: {
    badge: BadgeTypes.Invited,
    enum: "DELETING",
    readable: "Deleting",
  },
};
