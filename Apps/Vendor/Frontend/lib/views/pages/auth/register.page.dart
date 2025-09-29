import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fuodz/services/custom_form_builder_validator.service.dart';
import 'package:fuodz/view_models/register.view_model.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:fuodz/widgets/country_picker.dart';
import 'package:fuodz/models/country.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:fuodz/extensions/context.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  Widget build(BuildContext context) {
    final inputDec = InputDecoration(
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
    );

    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          isLoading: vm.isBusy,
          showAppBar: false,
          elevation: 0,
          body: SafeArea(
            child: FormBuilder(
              key: vm.formBuilderKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Logo from assets
                    Container(
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Register as a service provider",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Service Type Display (Food Vendor Only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE91E63),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: const Color(0xFFE91E63),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Food Vendor',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE91E63),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        FormBuilderTextField(
                          name: "full_name",
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Full Name",
                            prefixIcon: Icon(Icons.person, color: const Color(0xFFE91E63)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone number with country picker
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              CountryPicker(
                                selectedCountry: Country.defaultCountry,
                                onCountryChanged: (country) {
                                  // TODO: Update selected country in view model
                                },
                                showFlag: true,
                                showName: false,
                                showPhoneCode: true,
                              ),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: "phone",
                                  validator: CustomFormBuilderValidator.required,
                                  decoration: const InputDecoration(
                                    hintText: "Phone Number",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        FormBuilderTextField(
                          name: "address",
                          validator: CustomFormBuilderValidator.required,
                          decoration: inputDec.copyWith(
                            labelText: "Location",
                            prefixIcon: Icon(Icons.location_on, color: const Color(0xFFE91E63)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        FormBuilderTextField(
                          name: "password",
                          validator: CustomFormBuilderValidator.required,
                          obscureText: true,
                          decoration: inputDec.copyWith(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, color: const Color(0xFFE91E63)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Terms and Privacy Policy
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "By creating an account, you agree to our:",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/terms');
                                    },
                                    child: Text(
                                      "Terms & Conditions",
                                      style: TextStyle(
                                        color: const Color(0xFFE91E63),
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    " and ",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/privacy');
                                    },
                                    child: Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                        color: const Color(0xFFE91E63),
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Register",
                            loading: vm.isBusy,
                            onPressed: vm.processLogin,
                            color: const Color(0xFFE91E63),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Login link
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(
                                color: const Color(0xFFE91E63),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


}
