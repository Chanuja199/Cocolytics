class SupportContact {
  final String title;
  final String description;
  final String type; // 'hotline', 'expert', 'technical'
  final List<String> phones;
  final List<String> emails;
  final String? whatsappNumber;
  final String? websiteUrl;

  SupportContact({
    required this.title,
    required this.description,
    required this.type,
    required this.phones,
    required this.emails,
    this.whatsappNumber,
    this.websiteUrl,
  });
}

class SupportData {
  static List<SupportContact> getContacts() {
    return [
      SupportContact(
        title: 'Government Hotline',
        description: 'Contact state agricultural department',
        type: 'hotline',
        phones: [
          '+94 812 030 040',
          '+94 812 030 041',
          '+94 812 030 042',
          '+94 812 030 043',
        ],
        emails: ['1920service@doa.gov.lk', '1920.doa@gmail.com'],
        whatsappNumber: '94702201920',
        websiteUrl: 'https://www.doa.gov.lk',
      ),
      SupportContact(
        title: 'Department of Agriculture',
        description: 'Main Office — Peradeniya',
        type: 'expert',
        phones: ['+94 812 386 484', '+94 812 388 157'],
        emails: ['dgagriculture@gmail.com'],
        websiteUrl: 'https://www.doa.gov.lk',
      ),
    ];
  }
}
