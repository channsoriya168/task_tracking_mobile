class QrLoginData {
  const QrLoginData({required this.qrCodeUrl, required this.expiresAt});

  final String qrCodeUrl;
  final DateTime expiresAt;
}