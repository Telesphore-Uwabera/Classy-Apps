import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:Classy/constants/app_colors.dart';
import 'package:Classy/constants/app_routes.dart';
import 'package:Classy/services/app.service.dart';
import 'package:Classy/services/cart.service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({Key? key, this.currentIndex}) : super(key: key);

  final int? currentIndex;

  void _goTab(BuildContext context, int index) {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != AppRoutes.homeRoute) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.homeRoute,
        (route) => false,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppService().homePageIndex.add(index);
      });
    } else {
      AppService().homePageIndex.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = currentIndex ?? 0;
    final titles = [
      "Home".tr(),
      "Orders".tr(),
      "Search".tr(),
      "Cart".tr(),
      "Menu".tr(),
    ];
    final icons = [
      HugeIcons.strokeRoundedHome03,
      HugeIcons.strokeRoundedInboxUnread,
      HugeIcons.strokeRoundedSearch01,
      HugeIcons.strokeRoundedShoppingBasket01,
      HugeIcons.strokeRoundedMenu08,
    ];
    final filledIcons = [
      HugeIcons.strokeRoundedHome02,
      HugeIcons.strokeRoundedInbox,
      HugeIcons.strokeRoundedSearch02,
      HugeIcons.strokeRoundedShoppingBasket02,
      HugeIcons.strokeRoundedMenu03,
    ];

    return AnimatedBottomNavigationBar.builder(
      itemCount: 5,
      backgroundColor: Theme.of(context).colorScheme.surface,
      blurEffect: true,
      shadow: BoxShadow(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        blurRadius: 10,
      ),
      activeIndex: idx,
      onTap: (i) => _goTab(context, i),
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.defaultEdge,
      leftCornerRadius: 0,
      rightCornerRadius: 0,
      splashSpeedInMilliseconds: 10,
      tabBuilder: (int index, bool isActive) {
        final color = isActive
            ? AppColor.primaryColor
            : Theme.of(context).textTheme.bodyLarge?.color;
        
        // Special handling for cart tab with badge
        if (index == 3) { // Cart tab index
          return StreamBuilder<int>(
            stream: CartServices.cartItemsCountStream.stream,
            initialData: CartServices.productsInCart.length,
            builder: (context, snapshot) {
              final cartCount = snapshot.data ?? 0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Icon(
                        isActive ? filledIcons[index] : icons[index],
                        size: 22,
                        color: color,
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartCount > 99 ? '99+' : cartCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: Text(
                      titles[index],
                      style: TextStyle(
                        color: color,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
        
        // Default tab builder for other tabs
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? filledIcons[index] : icons[index],
              size: 22,
              color: color,
            ),
            Padding(
              padding: const EdgeInsets.all(0.5),
              child: Text(
                titles[index],
                style: TextStyle(
                  color: color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


