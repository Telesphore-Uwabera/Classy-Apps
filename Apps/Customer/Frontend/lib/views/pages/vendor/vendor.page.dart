import 'package:flutter/material.dart';
import 'package:Classy/models/vendor_type.dart';
import 'package:Classy/view_models/vendor.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorPage extends StatefulWidget {
  const VendorPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage>
    with AutomaticKeepAliveClientMixin<VendorPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ViewModelBuilder<VendorViewModel>.reactive(
      viewModelBuilder: () => VendorViewModel(context, widget.vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          title: "${widget.vendorType.name}",
          appBarColor: context.theme.colorScheme.surface,
          appBarItemColor: Colors.black,
          showCart: true,
          body: VStack([
            "Welcome to ${widget.vendorType.name}".text.xl.bold.make().px20().py16(),
            "This service is coming soon!".text.make().px20().py8(),
          ]).scrollVertical(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
