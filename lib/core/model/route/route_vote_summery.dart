/// ===============================================================
/// ROUTE VOTE SUMMARY
/// ===============================================================

class RouteVoteSummary {
  final int upVotes;
  final int downVotes;

  const RouteVoteSummary({
    required this.upVotes,
    required this.downVotes,
  });

  int get score => upVotes - downVotes;
}