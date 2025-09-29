import 'package:flutter/material.dart';
import 'package:Classy/constants/sizes.dart';
import 'package:Classy/services/order.service.dart';
import 'package:Classy/view_models/orders.vm.dart';
import 'package:Classy/widgets/base.page.dart';
import 'package:Classy/widgets/custom_list_view.dart';
import 'package:Classy/widgets/list_items/order.list_item.dart';
import 'package:Classy/widgets/list_items/taxi_order.list_item.dart';
import 'package:Classy/widgets/states/empty.state.dart';
import 'package:Classy/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm.fetchMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = OrdersViewModel(context);
    super.build(context);
    return BasePage(
      body: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => vm,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack([
            //
            12.heightBox,
            "My Orders".tr().text.xl3.semiBold.make().px(20),
            6.heightBox,
            //
            if (vm.isAuthenticated())
              CustomListView(
                canPullUp: true,
                canRefresh: true,
                refreshController: vm.refreshController,
                onRefresh: () => vm.fetchMyOrders(),
                onLoading: () => vm.fetchMyOrders(initialLoading: false),
                dataSet: vm.orders,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                emptyWidget: EmptyState(
                  title: 'No orders yet'.tr(),
                  description: 'When you place an order, it will appear here.'.tr(),
                  actionText: 'Start Browsing'.tr(),
                  actionPressed: () => Navigator.of(context).pop(),
                  showAction: true,
                ),
                separatorBuilder: (_, index) => 10.heightBox,
                isLoading: vm.isBusy,
                itemBuilder: (context, index) {
                  final order = vm.orders[index];
                  //for taxi tye of order
                  if (order.taxiOrder != null) {
                    return TaxiOrderListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                    );
                  }
                  return OrderListItem(
                    order: order,
                    orderPressed: () => vm.openOrderDetails(order),
                    onPayPressed:
                        () => OrderService.openOrderPayment(order, vm),
                  );
                },
                // listView:
                //     vm.orders.map((order) {
                //       //for taxi tye of order
                //       if (order.taxiOrder != null) {
                //         return TaxiOrderListItem(
                //           order: order,
                //           orderPressed: () => vm.openOrderDetails(order),
                //         );
                //       }
                //       return OrderListItem(
                //         order: order,
                //         orderPressed: () => vm.openOrderDetails(order),
                //         onPayPressed:
                //             () => OrderService.openOrderPayment(order, vm),
                //       );
                //     }).toList(),
              ).expand(),

            if (!vm.isAuthenticated())
              EmptyState(
                auth: true,
                showAction: true,
                actionPressed: vm.openLogin,
              ).py12().centered().expand(),

            /*
              vm.isAuthenticated()
                  ? CustomListView(
                      canRefresh: true,
                      canPullUp: true,
                      refreshController: vm.refreshController,
                      onRefresh: vm.fetchMyOrders,
                      onLoading: () =>
                          vm.fetchMyOrders(initialLoading: false),
                      isLoading: vm.isBusy,
                      dataSet: vm.orders,
                      hasError: vm.hasError,
                      errorWidget: LoadingError(
                        onrefresh: vm.fetchMyOrders,
                      ),
                      //
                      emptyWidget: EmptyOrder(),
                      itemBuilder: (context, index) {
                        //
                        final order = vm.orders[index];
                        //for taxi tye of order
                        if (order.taxiOrder != null) {
                          return TaxiOrderListItem(
                            order: order,
                            orderPressed: () => vm.openOrderDetails(order),
                          );
                        }
                        return OrderListItem(
                          order: order,
                          orderPressed: () => vm.openOrderDetails(order),
                          onPayPressed: () =>
                              OrderService.openOrderPayment(order, vm),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          UiSpacer.verticalSpace(space: 2),
                    ).expand()
                  : EmptyState(
                      auth: true,
                      showAction: true,
                      actionPressed: vm.openLogin,
                    ).py12().centered().expand(),
                    */
          ]);
        },
      ),
      // No bottomNavigationBar here; HomePage provides the global bar
    );
  }

  @override
  bool get wantKeepAlive => true;
}
