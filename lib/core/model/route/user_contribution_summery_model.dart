/// ===============================================================
/// USER CONTRIBUTION SUMMARY (Sidebar Support)
/// ===============================================================

class UserContributionSummary {
  final int totalRoutes;
  final int totalComments;
  final List<String> recentRouteTitles;
  final List<String> recentComments;

  const UserContributionSummary({
    required this.totalRoutes,
    required this.totalComments,
    required this.recentRouteTitles,
    required this.recentComments,
  });
}