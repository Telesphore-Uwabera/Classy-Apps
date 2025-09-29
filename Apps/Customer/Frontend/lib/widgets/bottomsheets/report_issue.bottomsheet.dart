import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ReportIssueBottomSheet extends StatefulWidget {
  const ReportIssueBottomSheet({super.key, this.onSubmit});
  final void Function({required String type, String? rideId, required String description})? onSubmit;

  @override
  State<ReportIssueBottomSheet> createState() => _ReportIssueBottomSheetState();
}

class _ReportIssueBottomSheetState extends State<ReportIssueBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _type = '';
  final _rideIdTEC = TextEditingController();
  final _descTEC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: VStack([
          HStack([
            'Report an Issue'.text.xl.semiBold.make().expand(),
            const CloseButton(),
          ]),
          12.heightBox,
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Issue Type'),
            items: const [
              DropdownMenuItem(value: 'payment', child: Text('Payment')),
              DropdownMenuItem(value: 'driver', child: Text('Driver')),
              DropdownMenuItem(value: 'app', child: Text('App')),
            ],
            onChanged: (v) => setState(() => _type = v ?? ''),
            validator: (v) => (v == null || v.isEmpty) ? 'Select issue type' : null,
          ),
          TextFormField(controller: _rideIdTEC, decoration: const InputDecoration(labelText: 'Ride ID (optional)')),
          TextFormField(
            controller: _descTEC,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 4,
            validator: (v) => (v == null || v.isEmpty) ? 'Enter description' : null,
          ),
          16.heightBox,
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                widget.onSubmit?.call(type: _type, rideId: _rideIdTEC.text.trim().isEmpty ? null : _rideIdTEC.text.trim(), description: _descTEC.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ).h(48),
        ]).p20(),
      ),
    );
  }
}


