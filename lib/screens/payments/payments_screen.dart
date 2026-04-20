import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined),
            title: Text('Wallet'),
            subtitle: Text('Balance: Rs. 500'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.credit_card_rounded),
            title: Text('Credit / Debit Card'),
            subtitle: Text('**** **** **** 1234'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.money_rounded),
            title: Text('Cash'),
            subtitle: Text('Pay directly to driver'),
          ),
        ],
      ),
    );
  }
}
