import 'package:flutter/material.dart';

class TermsModal extends StatelessWidget {
  const TermsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Terms of Service',
                      'By using CodeCrave, you agree to comply with and be bound by the following terms and conditions. Please review them carefully.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing and using this food ordering service, you accept and agree to be bound by the terms and provision of this agreement.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '2. Use of Service',
                      'You agree to use this service only for lawful purposes and in a way that does not infringe the rights of, restrict or inhibit anyone else\'s use and enjoyment of the service.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '3. User Account',
                      'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '4. Orders and Payments',
                      'All orders are subject to availability and confirmation of the order price. Prices are subject to change without notice. Payment must be made at the time of order.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '5. Delivery',
                      'Delivery times are estimates and not guaranteed. We will make reasonable efforts to deliver within the estimated time frame.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      'Privacy Policy',
                      'We are committed to protecting your privacy. We collect and use your personal information only as described in this privacy policy.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '1. Information Collection',
                      'We collect information you provide directly to us, such as your name, email address, phone number, and delivery address when you create an account or place an order.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '2. Use of Information',
                      'We use the information we collect to process your orders, communicate with you, and improve our services.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '3. Information Sharing',
                      'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as necessary to fulfill your orders.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '4. Security',
                      'We implement reasonable security measures to protect your personal information from unauthorized access, use, or disclosure.',
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      '5. Cookies',
                      'We may use cookies and similar technologies to enhance your experience and gather information about visitors and visits to our application.',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Last Updated: ${DateTime.now().year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'I Understand',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
