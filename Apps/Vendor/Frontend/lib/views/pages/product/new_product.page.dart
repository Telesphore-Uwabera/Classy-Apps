import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/utils/ui_spacer.dart';
import 'package:fuodz/view_models/new_products.vm.dart';
import 'package:fuodz/views/pages/product/widgets/product_variation.section.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/cards/multi_image_selector.dart';
import 'package:fuodz/widgets/html_text_view.dart';
import 'package:fuodz/widgets/states/loading_indicator.view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class NewProductPage extends StatelessWidget {
  const NewProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    final inputDecoration = InputDecoration(
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFE91E63)),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    //
    return ViewModelBuilder<NewProductViewModel>.reactive(
      viewModelBuilder: () => NewProductViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Add Product",
          body: SafeArea(
            top: true,
            bottom: false,
            child: FormBuilder(
              key: vm.formBuilderKey,
              child: VStack([
                // Image Upload Section
                Container(
                  width: double.infinity,
                  height: 200,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      "Tap to add".text.lg.color(Colors.grey.shade600).make(),
                    ],
                  ).onTap(() {
                    // TODO: Implement image picker
                  }),
                ),

                // Form Fields
                VStack([
                  // Product Name
                  _buildFormField(
                    'name',
                    'Product Name',
                    Icons.restaurant,
                    validator: CustomFormBuilderValidator.required,
                  ),

                  // Description
                  _buildFormField(
                    'description',
                    'Description',
                    Icons.description,
                    validator: CustomFormBuilderValidator.required,
                  ),

                  // Price
                  _buildFormField(
                    'price',
                    'Price (UGX)',
                    Icons.attach_money,
                    validator: (value) => CustomFormBuilderValidator.compose([
                      CustomFormBuilderValidator.required(value),
                      CustomFormBuilderValidator.numeric(value),
                    ]),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),

                  // Category
                  _buildFormField(
                    'category',
                    'Category',
                    Icons.category,
                    validator: CustomFormBuilderValidator.required,
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ]).px20(),

                const SizedBox(height: 40),

                // Add Product Button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomButton(
                    title: "Add Product",
                    onPressed: vm.processNewProduct,
                    color: const Color(0xFFE91E63),
                    loading: vm.isBusy,
                  ),
                ),

                const SizedBox(height: 20),
              ]).scrollVertical(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField(
    String name,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: FormBuilderTextField(
        name: name,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE91E63)),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
