import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tinodeflutter/Constants/ColorConstants.dart';
import 'package:tinodeflutter/Constants/Constants.dart';
import 'package:tinodeflutter/Constants/utils.dart';
import 'package:tinodeflutter/app_text.dart';
import 'package:tinodeflutter/components/widget/app_button.dart';
import 'package:tinodeflutter/global/DioClient.dart';
import 'package:tinodeflutter/global/global.dart';
import 'package:tinodeflutter/helpers/common_util.dart';
import 'package:tinodeflutter/page/base/base_state.dart';
import 'package:tinodeflutter/tinode/src/models/get-query.dart';
import 'package:tinodeflutter/tinode/src/topic.dart';


import 'PurchaseManager.dart';

enum eStoreType {
  None,
  Play,
  App,
}

enum eReceiptErrorState {
  None,
  OK,
  AbnormalReceipt,
  PendingReceipt,
  BadReceipt
}

List<dynamic> itemListRes = [];
eReceiptErrorState errorState = eReceiptErrorState.None;

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => purchaseScreen();

  //purchaseScreen._();

  static purchaseScreen? _instance; // 싱글톤

  static purchaseScreen get instance => getInstance();
  static purchaseScreen getInstance() {
    if (_instance != null) {
      return _instance!;
    }
    _instance = purchaseScreen();
    return _instance!;
  }
}

class purchaseScreen extends BaseState<PurchaseScreen>  {
// 웹 프론트 + flutter
   dynamic membership ;

  Future<void> initPurchaseState() async {
    await PurchaseManager.instance.initListener(); // 리스너 등록 1)
    await getItemList(); // 아이템 초기화 2)
    await PurchaseManager.instance.getPendingPurchases();
  }

  Future<void> getItemList() async {
    eStoreType storeType =
        Platform.isAndroid ? eStoreType.Play : eStoreType.App;
    print("storetype : ${storeType.index}");
    try{
         var itemListResponse = await DioClient.getItemList(storeType.index);
    // print("item list ")
    print("getitemlist");
    itemListRes = itemListResponse.data["ctrl"]['params']["shopitems"] ?? [];
    await initPurchaseItem(itemListRes);
 
    }
    catch(err)
    {
      print("err getitemList");
    }
  }

// 상품초기화 flutter
  Future<String> initPurchaseItem(List<dynamic> itemListResult) async {
    try {
      print("init purchase${jsonEncode(itemListResult)}");
      List<String> products = itemListResult.map((item) {
        if (item is Map) {
          return item['store_code'] as String;
        } else {
          return item as String;
        }
      }).toList();
      for (var item in products) {
        print(' initPurchase products forEach : $item');
      }

      var result = await PurchaseManager.instance.getProduct(products);
      //var result = await initPurchase(products);

      print('result : ${(result)}');
      return (result).toString();
    } catch (e) {
      print('initPurchase Error \n${e.toString()}\n$itemListResult');
      rethrow;
    }
  }

// purchase Item 클릭 시  flutter
  Future<dynamic> clickPurchaseItem(String storeCode) async {
    Utils.showDialogWidget(context);
    print("purchase item");
    // if (Platform.isIOS) showLoadingDialog(context, true); // 로딩 다이얼로그를 표시합니다.
    var result = await PurchaseManager.instance.buyConsumable(storeCode);
    //var result  = await purchaseItem(productId);
    print('clickpurchaseItem complete : $result');
    if (result == true) {
      print('성공');
    } else {
      //  showFailDialog('결제');
      print('실패');
    }
    return result;
  }

// 구매 성공 후 처리  웹
  Future<void> purchasingProcess(String receipt, String product_id, bool subscription) async {
    // var response = await DioClient.sendIapReceipt(receipt);

    print("purchasingProcess receipt ${receipt.toString()}");

    // Map<String, dynamic> receipt = {
    //   //'receipt': json.encode(receipt),
    //   'receipt': receipt,
    //   'product_id': productItem.productID,
    //   'subscription': false,
    // };

    // Map<String, dynamic> body = {
    //   "receipt": receipt,
    //   "product_id" : receipt.Payload.product_id,
    // };
   // Map<String, dynamic> receiptMap = receipt;
    try {
      var response = await DioClient.postIapReceipt(receipt, product_id, subscription);
      print("response : $response");
      print("response  data : ${response.data}");
      print("response  data  result: ${response.data['result']}");

      if (response.data['ctrl']['text'] == 'ok') {
        errorState = eReceiptErrorState.OK;
      } else if (response.data['result']['data']['state'] == ' ') {
        errorState = eReceiptErrorState.PendingReceipt;
      } else if (response.data['result']['data']['state'] ==
          'AbnormalReceipt') {
        errorState = eReceiptErrorState.AbnormalReceipt;
      } else if (response.data['result']['data']['state'] == 'BadReceipt') {
        errorState = eReceiptErrorState.BadReceipt;
      }
    } catch (err) {
      errorState = eReceiptErrorState.BadReceipt;
    }

    // await apiP
    //     .sendIap(
    //         "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
    //         body)
    //     .then((value) async {
    //   print("value : $value");
    //   errorState = eReceiptErrorState.OK;
    //   print(" errorState ");
    // }).catchError((error) {
    //   if (error is DioException) {
    //     print("Flutter Exception catch err  IAP : ${(error.toString())}");
    //     //  print("Flutter Exception catch err  IAP : ${(jsonDecode(error))}");

    //     // DioError 객체에서 오류 응답 데이터에 접근

    //     //  print("err response data : ${jsonDecode(error.response)['message']["error"]["message"]}");
    //     // print("err response data : ${error.response?.data["error"]["message"]}");

    //     print("error type  ${error.type}");
    //     print("error message  ${error.message}");
    //     print("error run type  ${error.response?.runtimeType}");
    //     print("error message  ${error.response?.statusMessage}");

    //     if (error.response != null) {
    //       // 오류 응답이 있는 경우
    //       var errorJson = error.response?.data;
    //       print("catch err  IAP 1 : $errorJson");

    //       dynamic res = jsonEncode(errorJson);
    //       // print("catch err  IAP 2: $res");

    //       if (res.error.message == 'PendingReceipt') {
    //         errorState = eReceiptErrorState.PendingReceipt;
    //       } else if (res.message == 'AbnormalReceipt') {
    //         errorState = eReceiptErrorState.AbnormalReceipt;
    //       } else if (res.message == 'BadReceipt') {
    //         errorState = eReceiptErrorState.BadReceipt;
    //       }
    //     } else {
    //       // 오류 응답이 없는 경우 (네트워크 오류 등)
    //       print('Error else : ${error.message}');
    //     }
    //   } else {
    //     // DioError가 아닌 경우 (예: 인터셉터에서 throw한 경우)
    //     print('Non-Dio error: $error');
    //   }
    // });
    // late dynamic response;
    // try {
    //   response = await apiP.sendIap(
    //       "Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}",
    //       jsonEncode(body));
    // } catch (error) {
    //   print("why error? : $error");

    // }

    // if (response.statusCode == 200) {
    //   print("value : $response");
    //   errorState = eReceiptErrorState.NormalReceipt;
    //   print(" errorState ");
    // } else if (response.statusCode == 400) {
    //   var res = response.data;
    //   print("catch err  IAP: $res");

    //   if (res.error.message == 'PendingReceipt') {
    //     errorState = eReceiptErrorState.PendingReceipt;
    //   } else if (res.error.message == 'AbnormalReceipt') {
    //     errorState = eReceiptErrorState.AbnormalReceipt;
    //   } else if (res.error.message == 'BadReceipt') {
    //     errorState = eReceiptErrorState.BadReceipt;
    //   }
    // }
    // AbnormalReceipt consume
    // Pending consume and reauthorization
    // Badreceipt X   해킹되었을가능성 /  무시 처리

    Map<String, dynamic> jsonDataReceipt = {
      // 'receipt': json.encode(receipt),
      'receipt': receipt,
      'product_id':product_id,
      'subscription': false,
    };

    print("errorState : ${errorState.toString()}");
    print("jsonDataReceipt : ${jsonDataReceipt['receipt'].toString()}");
    try {
      bool consumeResult = false;

      switch (errorState) {
        case eReceiptErrorState.OK: // 소비처리해서 소비했다고 알려줘야함 및 구매목록 제거
        case eReceiptErrorState.PendingReceipt: // 소비처리해서 소비했다고 알려줘야함 및 구매목록 제거
        case eReceiptErrorState.AbnormalReceipt: // 소비처리해서 구매목록에서 제거해줘야함
        case eReceiptErrorState.BadReceipt:

          consumeResult = await PurchaseManager.instance.conSumePurchase(
              jsonDecode(jsonDataReceipt['receipt']), errorState); // 구매 소비 처리

        case eReceiptErrorState.None:
        default:
          break;
      }

      if (consumeResult) {
        // loading  끝
   //     await getMembershipData();
   //     startMembershipPolling();
        showToast("구매 성공");
        print("complete");
        Get.back(); // hideloading
        Get.back(); // 나갔다가
        Get.to(const PurchaseScreen());//입장
      }
     // Navigator.pop(context);

    } catch (err) {
      print("err: $err");
     
      //alert(err)
    }
  }

  late Topic me;


  Future<void> getMembershipData() async {
    me = tinode_global.getMeTopic();

     GetQuery getMembershipQuery = GetQuery(
      what: 'membership',
    );
    var membershipMeta = await me.getMeta(getMembershipQuery);
    if(membershipMeta.membership!=null) Constants.user.membership = membershipMeta.membership;

   print("before api getMebershipData");

   setState(() {
    if(membershipMeta.membership !=null) membership = membershipMeta.membership;

   });
    // var mem = await DioClient.getMembershipData();
    // print("mem end at : ${mem!.data['result']['end_at']}");
    // membership= mem;
    // print("mounted: ${mounted.toString()}");
    // if(mounted)
    // { 
    // setState(() {
    //   membership = mem;
    // });
    // }
  }

  @override
  void didChangeDependencies() {
  super.didChangeDependencies();

    setState(() {
      
    });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    return super.didChangeAppLifecycleState(state);
  }

  // Timer? membershipTimer;
  // void startMembershipPolling() {
  //   //Not related to the answer but you should consider resetting the timer when it starts
  //   membershipTimer?.cancel();
  //   membershipTimer =
  //       Timer.periodic(const Duration(seconds: 1), (_) => getMembershipData());
  // }
  
 



  
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state)
  // {
  
  //  switch (state) {
  //      case AppLifecycleState.resumed:	// (8)
  //     getMembershipData();
  //   if(mounted)
  //    {
  //     setState(() {
  //       membership = membership;
  //   });
  //   }
  //       break;
  //     default:
  //       break;
  //   }
  // }
 

  var price = 9900;
  final List<bool> _isSelected = List.generate(2, (_) => false);
  int nowSelected = -1;
  @override
  void initState() {
    super.initState();
    //if (Constants.user.idVerified) {}
    //print("mem : ${membership.data['result']['end_at']}");
    getMembershipData();
  }



 

  @override
  void dispose() {
    super.dispose();
//    membershipTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: Colors.grey,
        resizeToAvoidBottomInset: true,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          SizedBox(height: Get.height * 0.07),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: const Icon(Icons.arrow_back_ios,
                            color: Colors.white)),
                    AppText(
                      text: "서비스 이용권 구매", // purchase
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 41,
          ),
          Container(
              alignment: Alignment.center,
              child: AppText(
                text: "원하시는 서비스를 선택해 주세요",
                fontSize: 14,
              )),
          const SizedBox(height: 16),
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.halfWhite, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(4))),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.5),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              AppText(
                text: "서비스 이용기간",
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ColorConstants.white,
              ),
              const SizedBox(
                width: 10,
              ),
              
              if (membership != null &&  membership!['level'] != 0)
                AppText(
                  text: "${membership!['endat']}",
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: ColorConstants.colorMain,
                )
            ]),
          ),

          ListView.builder(
            shrinkWrap: true,
            itemCount: _isSelected.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      if (index == i) {
                        _isSelected[i] = true;
                        nowSelected = i;
                      } else {
                        _isSelected[i] = false;
                      }
                      //_isSelected[i] = i == index;
                    }
                  });
                },
                child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: _isSelected[index]
                              ? ColorConstants.colorMain
                              : ColorConstants.halfWhite,
                          width: _isSelected[index] ? 3.0 : 2.0,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4))),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            //text: "${itemListRes[index].price}원",
                            text:
                                "${itemListRes[index]['refItem']['description']}",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: ColorConstants.white,
                          ),
                          AppText(
                            // text: "${itemListRes[index].refItem.description}",
                            text: "${itemListRes[index]['price']}원",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: ColorConstants.white,
                          )
                        ])),
              );
            },
          ),
          // for (int i = 0; i < 4; i++)
          // GestureDetector(
          //   onTap: (){

          //   },
          //   child:
          //   Container(
          //       width: double.maxFinite,
          //       decoration: BoxDecoration(
          //           border:
          //               Border.all(color: ColorConstants.halfWhite, width: 2),
          //           borderRadius: BorderRadius.all(Radius.circular(4))),
          //       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          //       child: Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             AppText(
          //               text: "1개월 사용권",
          //               fontWeight: FontWeight.bold,
          //               fontSize: 16,
          //               color: ColorConstants.white,
          //             ),
          //             AppText(
          //               text: "9900원",
          //               fontWeight: FontWeight.bold,
          //               fontSize: 16,
          //               color: ColorConstants.white,
          //             )
          //           ])),
          // ),

          const Spacer(),
          if (nowSelected != -1)
            AppButton(
                text: "${itemListRes[nowSelected]['price']}원 결제하기",
                onTap: () {
                  clickPurchaseItem(
                      "${itemListRes[nowSelected]['store_code']}");
                  //  Utils.showToast("text");
                }),
          const SizedBox(
            height: 20,
          ),
        ]));
  }
}

//레거시 아이템 초기화 flutter부분
Future<List<dynamic>> initPurchase(List<String> products) async {
  await PurchaseManager.instance.initListener(); // 리스너 등록
  var result = await PurchaseManager.instance.getProduct(products);
  return result;
}

//레거시 구매가능 체크 flutter부분
Future<dynamic> purchaseItem(String productId) async {
  var result = await PurchaseManager.instance.buyConsumable(productId);
  return result;
}

//레거시 영수증 소비 flutter 부분
Future<dynamic> consumeReceipt(dynamic arg) async {
  return await PurchaseManager.instance
      .conSumePurchase(arg[0] as Map<String, dynamic>, errorState);
}
