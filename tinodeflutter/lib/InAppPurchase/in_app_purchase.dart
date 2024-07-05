// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/Store.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:tinodeflutter/utils/write_log.dart';
// import 'package:rb_flutter/firebase_cloudmessaging.dart';
import '../../../helpers/common_util.dart';
import 'consumable_store.dart';
import 'purchaseScreen.dart';

// Auto-consume must be true on iOS.
// To try without auto-consume on another platform, change `true` to `false` here.
final bool _kAutoConsume = Platform.isIOS || true;

List<String> _kProductIds = <String>[];

class PurchaseManager {
  static PurchaseManager? _instance;

  static PurchaseManager get instance => _getOrCreateInstance();
  static PurchaseManager _getOrCreateInstance() {
    if (_instance != null) {
      return _instance!;
    }
    _instance = PurchaseManager();
    return _instance!;
  }

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  bool _isInit = false;
  String? _queryProductError;

  Future<void> initListener() async {
    // showToast("initListener");

    print('initListener in_app_purchase');
    if (_isInit) return;
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    print("purchase stream  :  $purchaseUpdated");
    if (!_isInit) {
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
      });
    }
    _isInit = true;
  }

  Future<void> getPendingPurchases() async {
    await InAppPurchase.instance.restorePurchases();
    //List<PurchaseDetails> purchases = await InAppPurchase.instance.queryPendingPurchases();
  }

  Future<List<ProductDetails>> getProduct(List<String> products) async {
    _kProductIds = products;
    final bool isAvailable = await _inAppPurchase.isAvailable();

    print('getProduct isAvailable : $isAvailable');

    if (!isAvailable) {
      _isAvailable = isAvailable;
      _products = <ProductDetails>[];
      _purchases = <PurchaseDetails>[];
      _notFoundIds = <String>[];
      _consumables = <String>[];
      _purchasePending = false;
      _loading = false;
      return _products;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      print('iosPlatformAddition');

      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      print('setDelegate');
    }
    print('productDetailResponse _inAppPurchase.queryProductDetails bef  ');

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());

    if (productDetailResponse.error != null) {
      print('productDetailResponse.error exist');

      _queryProductError = productDetailResponse.error!.message;
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = <PurchaseDetails>[];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = <String>[];
      _purchasePending = false;
      _loading = false;

      return _products;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      print('productDetailResponse.productDetails.isEmpty == true ');

      _queryProductError = null;
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _purchases = <PurchaseDetails>[];
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = <String>[];
      _purchasePending = false;
      _loading = false;

      return _products;
    }
    final List<String> consumables = await ConsumableStore.load();

    _isAvailable = isAvailable;
    _products = productDetailResponse.productDetails;
    _notFoundIds = productDetailResponse.notFoundIDs;
    _consumables = consumables;
    _purchasePending = false;
    _loading = false;

    print('consumables2  : ');

    return _products;
  }

  Future<bool> buyConsumable(String consumeId) async {
    final detail = _products.singleWhere((element) => element.id == consumeId);
    print('buyConsumable detail : $detail');

//     for (var _purchaseDetails in purchaseDetailsList) {
//     if (_purchaseDetails.pendingCompletePurchase) {
//       await _inAppPurchase.completePurchase(_purchaseDetails);
//    }
// }
    PurchaseParam param = PurchaseParam(productDetails: detail);
    print(
        'PurchaseParam  user name : ${param.applicationUserName} \n productDetails:  ${param.productDetails}');

    var result = await _inAppPurchase.buyConsumable(
        purchaseParam: param, autoConsume: false);
    print('PurchaseParam _inAppPurchase.buyConsumable result : $result');

    return result;
  }

  Future<bool> buyNonConsumable(String consumeId) async {
    final detail = _products.singleWhere((element) => element.id == consumeId);
    PurchaseParam param = PurchaseParam(productDetails: detail);
    var result = await _inAppPurchase.buyNonConsumable(purchaseParam: param);
    return result;
  }

  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();

    _consumables = consumables;
  }

  void showPendingUI() {
    _purchasePending = true;
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == "") {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      final List<String> consumables = await ConsumableStore.load();

      _purchasePending = false;
      _consumables = consumables;
    } else {
      _purchases.add(purchaseDetails);
      _purchasePending = false;
    }
  }

  void handleError(IAPError error) {
    _purchasePending = false;
    showToast("Purchase Fail");
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void requestProductPurchase(PurchaseDetails? productItem) async {
    // Map<String, dynamic> jsonData = {
    //   'format': 'flutter',
    //   'platfrom': Platform.operatingSystem,
    //   'productItem': {productItem.toString()},
    // };
    _purchases.add(productItem!);
    print('requestProductPurchase _purchases $_purchases ');

    // Map<String, dynamic> jsonData = {
    //   "purchaseID": productItem.purchaseID,
    //   "productID": productItem.productID,
    //   "verificationData": productItem.verificationData,
    //   "localVerificationData":
    //       productItem.verificationData.localVerificationData,
    //   "serverVerificationData":
    //       productItem.verificationData.serverVerificationData,
    //   "source": productItem.verificationData.source,
    //   "transactionDate": productItem.transactionDate,
    //   "status": productItem.status,
    // };
    // print(jsonData.toString()m.txt");

    Map<String, dynamic> receipt = <String, dynamic>{
      'Payload': productItem.verificationData.localVerificationData,
      'TransactionID': productItem.purchaseID,
      'Store': storeToString(getStore(productItem.verificationData.source)),
    };
    // try {
    //   receipt['Payload'] = productItem.verificationData.localVerificationData;
    //   receipt['TransactionID'] = productItem.purchaseID;
    //   receipt['Store'] = getStore(productItem.verificationData.source);
    // } catch (e) {
    //   print(e.toString().txt");
    // }
    print("request product purchase  receipt ${receipt.toString()}");

    Map<String, dynamic> jsonDataReceipt = {
      'receipt': json.encode(receipt),
      //'receipt': receipt,
      'product_id': productItem.productID,
      'subscription': false,
    };

    PurchaseScreen.instance.purchasingProcess(jsonDataReceipt);

    // if (Platform.isIOS) showLoadingDialog(tempContext, false);

    print('purchase-updated: $productItem');
  }

  Store getStore(String store) {
    if (Platform.isIOS) {
      return Store.appStore;
    }
    if (Platform.isAndroid) {
      if (store == "google_play") return Store.playStore;
      if (store == "amazon") return Store.amazon;
      return Store.none;
    }
    return Store.none;
  }

  String storeToString(Store store) {
    switch (store) {
      case Store.none:
        {
          return 'none';
        }
      case Store.playStore:
        {
          return 'GooglePlay';
        }
      case Store.amazon:
        {
          return 'Amazon';
        }
      case Store.appStore:
        {
          return 'AppleAppStore';
        }
    }
  }

  Future<void> consumeItem(PurchaseDetails item) async {
    final InAppPurchaseAndroidPlatformAddition androidAddition = _inAppPurchase
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

    var result = await androidAddition.consumePurchase(item);
    _purchases.remove(item);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
   // showToast("listen to purhcase come  & $purchaseDetailsList");

    WriteLog.write("listen to purchase update listen",
        fileName: "listentoPurchase.txt");
    // print("listen to purchase ");
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print('PurchaseStatus pending ');

     //   showToast(" pending   & ${purchaseDetails.productID}");
        //show Loading
        showPendingUI();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('err : PurchaseStatus.error');
        showToast('purchasestatus.error ');
        await consumeItem(purchaseDetails);
        // showToast(" status err  & ${purchaseDetails.productID}");

        //await InAppPurchase.instance.completePurchase(purchaseDetails);
        handleError(purchaseDetails.error!);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        print('PurchaseStatus.purchased || restored ');
        // showToast(
        //     " PurchaseStatus.purchased || restored  & ${purchaseDetails.productID}");

        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          requestProductPurchase(purchaseDetails);
        } else {
          _handleInvalidPurchase(purchaseDetails);
          return;
        }
      } else {
        print('else purchase');
        // showToast(" else purchase & ${purchaseDetails.productID}");

        // if (Platform.isIOS) showLoadingDialog(tempContext, false);
      }
      // if (Platform.isAndroid) {
      //   if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
      //     final InAppPurchaseAndroidPlatformAddition androidAddition =
      //         _inAppPurchase
      //             .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      //     await androidAddition.consumePurchase(purchaseDetails);
      //   }
      // }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
        // showToast("listen pending complete purchase");

        print("(purchaseDetails.pendingCompletePurchase");
      }
    }
  }

  Future<bool> conSumePurchase(
      Map<String, dynamic> receiptJson, eReceiptErrorState errorState) async {
    print("consumePurchase ${receiptJson.toString()}");
    // print(_purchases.toString());

    // WriteLog.write("receipt ${receiptJson.toString()}", fileName: "receipt.txt");
    print(" purchases id : ${_purchases[0].purchaseID}");

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Map<String, dynamic> receipt = receipt['receipt'];
        print("is come? android");
        String orderId = "";

        var receiptPayload = jsonDecode(receiptJson['Payload']);
        // print("receipt payload 1 ${receiptPayload.orderId}");
        print("receipt payload 2 ${receiptPayload['orderId']}");

        orderId = receiptPayload['orderId'];

        // if (receiptJson.containsKey('Payload')) {
        //   orderId = receiptJson['Payload']['orderId'];
        // } else {
        //   orderId = receiptJson['orderId'];
        // }

        print(" purchases id : ${_purchases[0].purchaseID}");
        PurchaseDetails item =
            _purchases.firstWhere((element) => element.purchaseID == orderId);

        // 현 위치까지 receipt 3종류 동일 처리  (normal / abnormal / pending)

        // normal :소비처리 / abnormal : 리스트에서 제거위해(펜딩 막을려고) 소비처리
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

        var result = await androidAddition.consumePurchase(item);
        print(result.toString());

        switch (errorState) {
          case eReceiptErrorState.PendingReceipt:
            {
              if (result.responseCode == BillingResponse.ok) {
                requestProductPurchase(item);
                _purchases.remove(item);
              }
              return false; // consume 처리 아직 안됨
            }
          case eReceiptErrorState.AbnormalReceipt:
          case eReceiptErrorState.OK:
            _inAppPurchase.completePurchase(item);
            _purchases.remove(item);
          case eReceiptErrorState.BadReceipt:
            _purchases.remove(item);
          default:
            break;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        //Map<String, dynamic> receipt = receiptJson['receipt'];
        //print(receiptJson.toString());
        List<dynamic> inApp = receiptJson['in_app'];
        print(inApp.toString());
        for (var item in inApp) {
          var transactionId = item['transaction_id'];
          print(transactionId);
          _inAppPurchase.completePurchase(item);
        }
      }
    } catch (e) {
      print(e.toString());
    }
    _purchasePending = false;
    return true; // 소비 처리 true
  }
  // Future<bool> conSumePurchase(Map<String, dynamic> jsonData) async {
  //   print(jsonData.toString());
  //   try {
  //     if (defaultTargetPlatform == TargetPlatform.android) {
  //       Map<String, dynamic> receipt = jsonData['receipt'];
  //       String orderId = "";
  //       if (receipt.containsKey(receipt)) {
  //         orderId = receipt['receipt']['orderId'];
  //       } else {
  //         orderId = receipt['orderId'];
  //       }

  //       print(_purchases.toString());
  //       PurchaseDetails item =
  //           _purchases.firstWhere((element) => element.purchaseID == orderId);

  //       String message = receipt['message'];

  //       // 현 위치까지 receipt 3종류 동일 처리  (normal / abnormal / pending)

  //       // normal :소비처리 / abnormal : 리스트에서 제거위해(펜딩 막을려고) 소비처리

  //       if (message == "Pending") {  // Pending 상태일 때 따로 처리
  //         final InAppPurchaseAndroidPlatformAddition androidAddition =
  //             _inAppPurchase
  //                 .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

  //         var result = await androidAddition.consumePurchase(item);
  //         print(result.toString());
  //         if (result.responseCode == BillingResponse.ok) {
  //           requestProductPurchase(item);
  //           _purchases.remove(item);
  //         }
  //         return false;  // consume 처리 아직 안됨
  //       }
  //     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
  //       Map<String, dynamic> receipt = jsonData['receipt']['receipt'];
  //       print(receipt.toString());
  //       List<dynamic> inApp = receipt['receipt']['in_app'];
  //       print(inApp.toString());
  //       for (var item in inApp) {
  //         var transactionId = item['transaction_id'];
  //         print(transactionId);
  //         _inAppPurchase.completePurchase(item);
  //       }
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   _purchasePending = false;
  //   return true;  // 소비 처리 true
  // }

  Future<void> confirmPriceChange(BuildContext context) async {
    // Price changes for Android are not handled by the application, but are
    // instead handled by the Play Store. See
    // https://developer.android.com/google/play/billing/price-changes for more
    // information on price changes on Android.
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    GooglePlayPurchaseDetails? oldSubscription;

    return oldSubscription;
  }
}

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
