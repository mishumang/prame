import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';


class DonatePage extends StatefulWidget {
  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  late Razorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();
  final List<int> _suggestedAmounts = [501, 1001, 2001, 5001];
  int _selectedAmount = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: "Thank you for your generous donation!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Color(0xff457B9D),
      textColor: Colors.white,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: "External wallet selected: ${response.walletName}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _openCheckout() {
    int amount = _selectedAmount > 0
        ? _selectedAmount
        : (_amountController.text.isNotEmpty
        ? int.parse(_amountController.text)
        : 501); // Default amount if nothing selected

    var options = {
      'key': 'rzp_test_YOUR_KEY_HERE', // Replace with your actual Razorpay key
      'amount': amount * 100, // Amount in paise
      'name': 'Yoga Mandir',
      'description': 'Donation to Charitable Trust',
      'prefill': {
        'contact': '',
        'email': ''
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // App's color palette
    final Color primaryBlue = const Color(0xff457B9D);
    final Color lightBlue = const Color(0xffA8DADC);
    final Color creamBg = const Color(0xffF1FAEE);
    final Color accentGold = const Color(0xFFFFD700);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Support Our Mission',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryBlue.withOpacity(0.95),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              creamBg.withOpacity(0.9),
              creamBg,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildObjectivesCard(primaryBlue, lightBlue),
                  SizedBox(height: 24),
                  _buildTaxBenefitNote(primaryBlue, lightBlue),
                  SizedBox(height: 24),
                  _buildDonationAmountSection(primaryBlue, lightBlue, accentGold),
                  SizedBox(height: 24),
                  _buildDonateButton(primaryBlue, accentGold),
                  SizedBox(height: 24),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectivesCard(Color primaryBlue, Color lightBlue) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            lightBlue.withOpacity(0.7),
            lightBlue.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: primaryBlue,
                size: 30,
              ),
              SizedBox(width: 12),
              Text(
                'Yoga Mandir\'s Objectives',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryBlue.withOpacity(0.8),
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: 'Objective and Recognition: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      TextSpan(
                        text: 'Yoga Mandir',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' operates as a ',
                      ),
                      TextSpan(
                        text: 'Charitable Trust',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' with a noble mission – to ',
                      ),
                      TextSpan(
                        text: 'promote yoga as a holistic health solution',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      TextSpan(
                        text: 'power of yoga',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' to foster well-rounded individuals.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Key impact areas
                Text(
                  'Your donation helps us:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 8),
                _buildImpactItem('Provide free yoga education to underprivileged students', primaryBlue),
                _buildImpactItem('Support research on yoga\'s physical and mental health benefits', primaryBlue),
                _buildImpactItem('Preserve ancient yoga traditions and teachings', primaryBlue),
                _buildImpactItem('Develop accessible wellness programs for all age groups', primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(String text, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: primaryBlue,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: primaryBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBenefitNote(Color primaryBlue, Color lightBlue) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long,
            color: primaryBlue,
            size: 28,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Donations to Yoga Mandir are eligible for tax benefits under Section 80G of the Income Tax Act, 1961.',
              style: TextStyle(
                fontSize: 14,
                color: primaryBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationAmountSection(Color primaryBlue, Color lightBlue, Color accentGold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Donation Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        SizedBox(height: 16),
        // Suggested amounts
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _suggestedAmounts.map((amount) {
            bool isSelected = _selectedAmount == amount;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedAmount = amount;
                  _amountController.clear();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? primaryBlue : lightBlue,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ]
                      : [],
                ),
                child: Text(
                  '₹${amount}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : primaryBlue,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        // Custom amount
        Text(
          'Or enter a custom amount:',
          style: TextStyle(
            fontSize: 16,
            color: primaryBlue,
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _selectedAmount = 0; // Deselect preset amounts
              });
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.currency_rupee, color: primaryBlue),
            hintText: 'Enter amount',
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: lightBlue, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          style: TextStyle(
            fontSize: 16,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDonateButton(Color primaryBlue, Color accentGold) {
    return Center(
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _openCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            shadowColor: primaryBlue.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: accentGold),
              SizedBox(width: 12),
              Text(
                'DONATE NOW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  }
