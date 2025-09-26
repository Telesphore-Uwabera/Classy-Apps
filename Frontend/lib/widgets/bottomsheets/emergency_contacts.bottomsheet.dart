import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher_string.dart';

class EmergencyContactsBottomSheet extends StatelessWidget {
  const EmergencyContactsBottomSheet({
    super.key,
    this.policeNumber = '999',
    this.ambulanceNumber = '997',
    this.supportNumber,
  });

  final String policeNumber;
  final String ambulanceNumber;
  final String? supportNumber;

  void _call(String number) {
    final tel = 'tel:$number';
    launchUrlString(tel);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: VStack([
        'Emergency Contact'.text.semiBold.xl.make().centered().py8(),
        _RowTile(icon: Icons.local_police_outlined, title: 'Police', value: policeNumber, onCall: _call),
        _RowTile(icon: Icons.local_hospital_outlined, title: 'Ambulance', value: ambulanceNumber, onCall: _call),
        if (supportNumber != null)
          _RowTile(icon: Icons.support_agent_outlined, title: 'Customer Support', value: supportNumber!, onCall: _call),
        12.heightBox,
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')).centered(),
      ]).p20().scrollVertical(),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.icon, required this.title, required this.value, required this.onCall});
  final IconData icon;
  final String title;
  final String value;
  final void Function(String) onCall;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: title.text.make(),
      subtitle: value.text.make(),
      trailing: IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => onCall(value)),
    );
  }
}


