
import 'package:flutter/material.dart';
import 'package:frcrce_canteen_app/menu_page.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Razorpay razorpay;
  TextEditingController textEditingController = TextEditingController();
  late BuildContext storedContext;

  @override
  void initState() {
    super.initState();

    razorpay =  Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {

    super.dispose();
    razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_CXUxLZeJ8Kt9ui",
      "amount": num.parse(textEditingController.text) * 100,
      "name": "Pay App",
      "description": "Payment",
      "prefill": {"contact": "9156994575", "email": "jose@gmail.com"},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment success')),
    );
    //Navigate to the payment successful screen

    Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuPage()));
  }


  void handlerErrorFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment error')),
    );
  }

  void handlerExternalWallet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('External Wallet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Razor Pay"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(hintText: "Amount to pay"),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                openCheckout();
              },
              child: const Text(
                "Next",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:upi_india/upi_india.dart';

// class UpiPaymentScreen extends StatefulWidget {
//   const UpiPaymentScreen({Key? key}) : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _UpiPaymentScreenState createState() => _UpiPaymentScreenState();
// }

// class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
//   Future<UpiResponse>? _transaction;
//   final UpiIndia _upiIndia = UpiIndia();
//   List<UpiApp>? apps;
//   double amount = 0.0; // Track the amount to be paid

//   TextStyle header = const TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//   );

//   TextStyle value = const TextStyle(
//     fontWeight: FontWeight.w400,
//     fontSize: 14,
//   );

//   @override
//   void initState() {
//     _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
//       setState(() {
//         apps = value;
//       });
//     }).catchError((e) {
//       apps = [];
//     });
//     super.initState();
//   }

//   Future<UpiResponse> initiateTransaction(UpiApp app) async {
//     return _upiIndia.startTransaction(
//         app: app,
//         receiverUpiId: "myronthecoolguy@okaxis",
//         receiverName: 'lance',
//         transactionRefId: 'Testing Upi India Plugin',
//         transactionNote: 'DEMO PAY',
//         amount: amount, // Use the amount entered by the user
//         merchantId: '');
//   }

//   Widget displayUpiApps() {
//     if (apps == null) {
//       return const Center(child: CircularProgressIndicator());
//     } else if (apps!.isEmpty) {
//       return Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: header,
//         ),
//       );
//     } else {
//       return Align(
//         alignment: Alignment.topCenter,
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Wrap(
//             children: apps!.map<Widget>((UpiApp app) {
//               return GestureDetector(
//                 onTap: () {
//                   _transaction = initiateTransaction(app);
//                   setState(() {});
//                 },
//                 child: SizedBox(
//                   height: 200,
//                   width: 100,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Container(
//                         height: 100,
//                         width: 100,
//                         color: Colors.blue.shade900,
//                         child: const Icon(
//                           Icons.payment,
//                           size: 60,
//                           color: Colors.white,
//                         ),
//                       ),
//                       Text(app.name),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
//     }
//   }

//   String _upiErrorHandler(error) {
//     switch (error) {
//       case UpiIndiaAppNotInstalledException:
//         return 'Requested app not installed on device';
//       case UpiIndiaUserCancelledException:
//         return 'You cancelled the transaction';
//       case UpiIndiaNullResponseException:
//         return 'Requested app didn\'t return any response';
//       case UpiIndiaInvalidParametersException:
//         return 'Requested app cannot handle the transaction';
//       default:
//         return 'An Unknown error has occurred';
//     }
//   }

//   void _checkTxnStatus(String status) {
//     switch (status) {
//       case UpiPaymentStatus.SUCCESS:
//         print('Transaction Successful');
//         break;
//       case UpiPaymentStatus.SUBMITTED:
//         print('Transaction Submitted');
//         break;
//       case UpiPaymentStatus.FAILURE:
//         print('Transaction Failed');
//         break;
//       default:
//         print('Received an Unknown transaction status');
//     }
//   }

//   Widget displayTransactionData(title, body) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text("$title: ", style: header),
//           Flexible(
//               child: Text(
//             body,
//             style: value,
//           )),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue.shade900,
//         title: const Text("Integrate UPI"),
//       ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Amount to Pay',
//                 hintText: 'Enter amount', 
//               ),
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               onChanged: (value) {
//                 setState(() {
//                   amount = double.tryParse(value) ?? 0.0;
//                 });
//               },
//             ),
//           ),
//           Expanded(
//             child: displayUpiApps(),
//           ),
//           Expanded(
//             child: FutureBuilder(
//               future: _transaction,
//               builder:
//                   (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text(
//                         _upiErrorHandler(snapshot.error.runtimeType),
//                         style: header,
//                       ), // Print's text message on screen
//                     );
//                   }

//                   UpiResponse _upiResponse = snapshot.data!;

//                   String txnId = _upiResponse.transactionId ?? 'N/A';
//                   String resCode = _upiResponse.responseCode ?? 'N/A';
//                   String txnRef = _upiResponse.transactionRefId ?? 'N/A';
//                   String status = _upiResponse.status ?? 'N/A';
//                   String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
//                   _checkTxnStatus(status);

//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         displayTransactionData('Transaction Id', txnId),
//                         displayTransactionData('Response Code', resCode),
//                         displayTransactionData('Reference Id', txnRef),
//                         displayTransactionData('Status', status.toUpperCase()),
//                         displayTransactionData('Approval No', approvalRef),
//                       ],
//                     ),
//                   );
//                 } else {
//                   return const Center(
//                     child: Text(''),
//                   );
//                 }
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
