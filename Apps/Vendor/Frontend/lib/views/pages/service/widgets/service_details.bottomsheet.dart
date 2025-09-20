import 'package:flutter/material.dart';
import 'utils/ui_spacer.dart';
import 'view_models/service_details.vm.dart';
import 'widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ServiceDetailsBottomSheet extends StatelessWidget {
  const ServiceDetailsBottomSheet(this.vm, {Key? key}) : super(key: key);
  final ServiceDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: HStack(
        [
          //
          CustomButton(
            title: "Edit".tr(),
            color: Colors.grey,
            loading: vm.isBusy,
            onPressed: vm.editService,
          ).expand(),
          UiSpacer.horizontalSpace(),
          //
          CustomButton(
            title: "Delete".tr(),
            color: Colors.red,
            loading: vm.isBusy,
            onPressed: vm.deleteService,
          ).expand(),
        ],
      ).p20(),
    )
        .box
        .shadowSm
        .color(context.theme.colorScheme.surface)
        .topRounded(value: 20)
        .make();
  }
}
