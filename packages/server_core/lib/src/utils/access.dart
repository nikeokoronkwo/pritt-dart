// import '../../pritt_server.dart';
import '../db.dart';
import '../db/schema.dart';

Future<bool> userIsAuthorizedToPackage(
  Package pkg,
  User? user, {
  User? author,
  required PrittDatabase db,
}) async {
  author ??= pkg.author;
  // check if package is public
  if (pkg.scoped) {
    if (pkg.public ?? true) return true;

    // if user is not provided, return false
    if (user == null) return false;

    if (author == user) return true;

    final contribs = await db.getContributorsForPackage(pkg.name);

    if (contribs.keys.contains(user)) return true;
  } else {
    final org = pkg.scope != null
        ? await db.getOrganizationByName(pkg.scope!)
        : null;

    if ((pkg.public ?? true) && (org?.public ?? true)) return true;

    // if user is not provided, return false
    if (user == null) return false;

    if (author == user) return true;

    final members = db.getMembersForOrganizationStream(pkg.scope!);

    if (pkg.public ?? true && await members.contains(user)) return true;

    final contribs = await db.getContributorsForPackage(
      pkg.name,
      scope: pkg.scope,
    );

    if (contribs.keys.contains(user)) return true;
  }

  return false;
}
