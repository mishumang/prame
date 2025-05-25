import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class DonatePage extends StatefulWidget {
  @override
  _DonatePageState createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _suggestedAmounts = [501, 1001, 2001, 5001];
  int _selectedAmount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _openCheckout() async {
    int amount = _selectedAmount > 0
        ? _selectedAmount
        : (_amountController.text.isNotEmpty
        ? int.tryParse(_amountController.text) ?? 501
        : 501);

    final Uri donationUrl = Uri.parse("https://pages.razorpay.com/prame");

    if (await canLaunchUrl(donationUrl)) {
      await launchUrl(donationUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch donation page."),
          backgroundColor: Color(0xff457B9D),
        ),
      );
    }
  }

  void _openInAppDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppDonationPage(),
      ),
    );
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
                  _buildDonateButtons(primaryBlue, accentGold, lightBlue),
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
                        text: '. We harness the ',
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

  Widget _buildDonateButtons(Color primaryBlue, Color accentGold, Color lightBlue) {
    return Column(
      children: [
        // External donation button
        Container(
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
                Icon(Icons.open_in_new, color: accentGold),
                SizedBox(width: 12),
                Text(
                  'DONATE NOW (EXTERNAL)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        // In-app donation button
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openInAppDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: primaryBlue, width: 2),
              ),
              elevation: 3,
              shadowColor: primaryBlue.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: primaryBlue),
                SizedBox(width: 12),
                Text(
                  'DONATE IN-APP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        // Powered by Razorpay
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Powered by ',
              style: TextStyle(
                fontSize: 12,
                color: primaryBlue.withOpacity(0.6),
              ),
            ),
            Text(
              'Razorpay',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryBlue.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// New InAppDonationPage class
class InAppDonationPage extends StatefulWidget {
  @override
  _InAppDonationPageState createState() => _InAppDonationPageState();
}

class _InAppDonationPageState extends State<InAppDonationPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String? errorMessage;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xff457B9D);
    final Color creamBg = const Color(0xffF1FAEE);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donate to Yoga Mandir',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: creamBg,
            child: errorMessage != null
                ? _buildErrorWidget(primaryBlue)
                : InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('https://pages.razorpay.com/prame'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                setState(() {
                  isLoading = false;
                  errorMessage = 'Failed to load: ${error.description}';
                });
              },
            ),
          ),
          if (isLoading)
            Container(
              color: creamBg,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading donation page...',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryBlue,
                      ),
                    ),
                    if (progress > 0)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryBlue.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Color primaryBlue) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: primaryBlue,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unable to load the donation page',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                webViewController?.reload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}