import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String url() {
    var phone = "+6282145473050";
    if (Platform.isIOS) {
      return "https://api.whatsapp.com/send?phone=$phone=${Uri.parse("Hello")}";
    } else {
      return "https://wa.me/$phone/?text=${Uri.parse("Hello")}";
    }
  }

  Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> launchEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=Contact SRG&body=Hello,',
    );
    await launchUrl(launchUri);
  }

  Future<void> launchWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch webview $url');
    }
  }

  Future<void> launchWebBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch browser $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            buildContactTile(
              icon: Icons.phone,
              title: 'Layanan Pelanggan',
              subtitle: '0361-235733',
              onTap: () => launchPhoneCall('0361235733'),
            ),
            const SizedBox(height: 20),
            buildContactTile(
              icon: Icons.chat,
              title: 'Whatsapp',
              onTap: () => launchWebBrowser(Uri.parse(url())),
            ),
            const SizedBox(height: 20),
            buildContactTile(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'cs@tiaradewata.co.id',
              onTap: () => launchEmail('cs@tiaradewata.co.id'),
            ),
            const SizedBox(height: 20),
            buildContactTile(
              icon: Icons.web,
              title: 'Website',
              subtitle: 'tiaradewata.co.id',
              onTap: () =>
                  launchWebView(Uri.parse("https://tiaradewata.co.id")),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContactTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.grey.shade100,
    );
  }
}
