import 'package:flutter/material.dart';
import 'package:Classy/services/validator.service.dart';
import 'package:Classy/widgets/buttons/custom_button.dart';
import 'package:Classy/widgets/custom_text_form_field.dart';
import 'package:Classy/services/payment_api.service.dart';
import 'package:Classy/models/api_response.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletAmountEntryBottomSheet extends StatefulWidget {
  WalletAmountEntryBottomSheet({
    required this.onSubmit,
    Key? key,
  }) : super(key: key);

  final Function(String amount, int? paymentMethodId) onSubmit;
  @override
  _WalletAmountEntryBottomSheetState createState() =>
      _WalletAmountEntryBottomSheetState();
}

class _WalletAmountEntryBottomSheetState
    extends State<WalletAmountEntryBottomSheet> {
  //
  final formKey = GlobalKey<FormState>();
  final amountTEC = TextEditingController();
  final PaymentApiService _paymentApiService = PaymentApiService();
  
  List<Map<String, dynamic>> _paymentMethods = [];
  int? _selectedPaymentMethodId;
  bool _isLoadingPaymentMethods = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final response = await _paymentApiService.getPaymentMethods();
      if (response.allGood && response.body != null && response.body!['data'] != null) {
        final methods = List<Map<String, dynamic>>.from(response.body!['data']);
        setState(() {
          _paymentMethods = methods;
          _isLoadingPaymentMethods = false;
          // Select first payment method by default
          if (methods.isNotEmpty) {
            _selectedPaymentMethodId = methods.first['id'];
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPaymentMethods = false;
      });
      print('Error loading payment methods: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
      child: VStack(
        [
          //
          20.heightBox,
          //
          "Top-Up Wallet".tr().text.xl2.semiBold.make(),
          "Enter amount to top-up wallet with".tr().text.make(),
          Form(
            key: formKey,
            child: VStack([
              CustomTextFormField(
                labelText: "Amount".tr(),
                textEditingController: amountTEC,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => FormValidator.validateEmpty(
                  value,
                  errorTitle: "Amount".tr(),
                ),
              ),
              
              // Payment Method Selection
              if (!_isLoadingPaymentMethods && _paymentMethods.isNotEmpty) ...[
                20.heightBox,
                "Payment Method".tr().text.bold.make(),
                10.heightBox,
                ...(_paymentMethods.map((method) => 
                  RadioListTile<int>(
                    title: Text(method['name'] ?? 'Unknown'),
                    subtitle: Text(method['instruction'] ?? ''),
                    value: method['id'],
                    groupValue: _selectedPaymentMethodId,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedPaymentMethodId = value;
                      });
                    },
                  ),
                ).toList()),
              ] else if (_isLoadingPaymentMethods) ...[
                20.heightBox,
                CircularProgressIndicator().centered(),
                "Loading payment methods...".text.make().centered(),
              ],
            ]),
          ).py12(),
          //
          CustomButton(
            title: "TOP-UP".tr(),
            onPressed: () {
              //
              if (formKey.currentState!.validate()) {
                widget.onSubmit(amountTEC.text, _selectedPaymentMethodId);
              }
            },
          ),
          //
          20.heightBox,
        ],
      )
          .p20()
          .scrollVertical()
          .hOneThird(context)
          .box
          .color(context.theme.colorScheme.surface)
          .topRounded(value: 10)
          .make(),
    );
  }
}
