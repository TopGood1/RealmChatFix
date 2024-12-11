String formatPhoneNumber(String number) {
  number = number.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)}-");
  if (number.endsWith('-')) {
    number = number.substring(0, number.length - 1); // Hilangkan dash terakhir jika ada
  }
  return number;
}