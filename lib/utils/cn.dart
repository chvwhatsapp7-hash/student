// A utility function to combine multiple class-like strings
// (similar to clsx / tailwind-merge in React)
String cn(List<String?> classes) {
  // Remove null or empty strings and join with a space
  return classes.where((c) => c != null && c.isNotEmpty).join(' ');
}