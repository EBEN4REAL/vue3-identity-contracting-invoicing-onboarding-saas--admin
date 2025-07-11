/**
 * Escapes HTML-sensitive characters in the string values of an object.
 *
 * @param params - An object where all values are strings to be HTML-escaped.
 * @returns A new object with the same keys, but HTML-escaped string values.
 */
type ObjectWithStrings = Record<string, string>;

export default function escapeObjectValuesForHtml(
  params: ObjectWithStrings,
): ObjectWithStrings {
  return Object.keys(params).reduce((acc: ObjectWithStrings, key: string) => {
    acc[key] = params[key]
      .replace(/&/g, "&amp;") // Escape ampersands
      .replace(/</g, "&lt;") // Escape less-than
      .replace(/>/g, "&gt;") // Escape greater-than
      .replace(/"/g, "&quot;") // Escape double quotes
      .replace(/'/g, "&#39;") // Escape single quotes
      .replace(/`/g, "&#96;") // Escape backticks
      .replace(/\//g, "&#47;"); // Escape forward slashes
    return acc;
  }, {});
}
