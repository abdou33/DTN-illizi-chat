import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsService {
  static Future<List<String>> getPhoneNumbers() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.readWrite,
    );

    if (status != PermissionStatus.granted) {
      return [];
    }

    final contacts = await FlutterContacts.getAll(
      properties: ContactProperties.all,
    );

    final numbers = <String>{};

    for (final contact in contacts) {
      for (final phone in contact.phones) {
        final number = normalizePhone(phone.number);

        if (number.isNotEmpty) {
          numbers.add(number);
        }
      }
    }

    return numbers.toList();
  }

  static String normalizePhone(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= 9) {
      return '0${digits.substring(digits.length - 9)}';
    }

    return digits;
  }
}
