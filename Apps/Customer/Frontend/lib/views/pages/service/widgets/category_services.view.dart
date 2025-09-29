import 'package:flutter/material.dart';
import 'package:Classy/models/category.dart';
import 'package:Classy/models/service.dart';
import 'package:Classy/services/navigation.service.dart';
import 'package:Classy/views/pages/service/service_details.page.dart';
import 'package:Classy/widgets/buttons/custom_text_button.dart';
import 'package:Classy/widgets/list_items/service.gridview_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoryServicesView extends StatelessWidget {
  const CategoryServicesView(
    this.category, {
    this.loading = false,
    this.hideEmpty = true,
    this.showTitle = true,
    super.key,
  });

  final Category category;
  final bool loading;
  final bool hideEmpty;
  final bool showTitle;

  //
  @override
  Widget build(BuildContext context) {
    if (hideEmpty && category.services.isEmpty) {
      return SizedBox.shrink();
    }
    return VStack(
      [
        Visibility(
          visible: showTitle,
          child: VStack(
            [
              HStack(
                [
                  "${category.name}".text.xl.bold.make().expand(),
                  //view more
                  CustomTextButton(
                    title: "See all".tr(),
                    onPressed: () => openSearch(context, category),
                  ),
                ],
              ).px20(),
              12.heightBox,
            ],
          ),
        ),
        //row of services
        Builder(
          builder: (context) {
            double spacing = 20;
            double eachWidth = (context.screenWidth - (spacing * 2)) / 2;
            List<Widget> children = category.services.map((service) {
              return ServiceGridViewItem(
                service: service,
                onPressed: (service) => serviceSelected(context, service),
              ).w(eachWidth);
            }).toList();
            //append 12px
            children.insert(0, 0.widthBox);
            children.add(0.widthBox);
            //
            return Scrollbar(
              thumbVisibility: false,
              trackVisibility: false,
              interactive: true,
              child: HStack(
                children,
                spacing: spacing,
                axisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.start,
                crossAlignment: CrossAxisAlignment.start,
              ).scrollHorizontal(
                physics: BouncingScrollPhysics(),
              ),
            );
          },
        ),
      ],
    );
  }

  serviceSelected(BuildContext context, Service service) {
    //
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailsPage(service),
      ),
    );
  }

  openSearch(BuildContext context, Category category) {
    //
    NavigationService.openServiceSearch(
      context,
      category: category,
      showVendors: false,
    );
  }
}
