class JobApplication {
  final String id;
  final String companyName;
  final String jobTitle;
  final DateTime appliedDate;
  final String status; // Applied, Interviewing, Offer, Rejected
  final String? url;
  final String notes;

  JobApplication({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.appliedDate,
    required this.status,
    this.url,
    required this.notes,
  });

  JobApplication copyWith({
    String? companyName,
    String? jobTitle,
    String? status,
    String? url,
    String? notes,
  }) {
    return JobApplication(
      id: id,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      appliedDate: appliedDate,
      status: status ?? this.status,
      url: url ?? this.url,
      notes: notes ?? this.notes,
    );
  }
}
