import '../../pritt_server.dart';
import '../main/base/db/schema.dart';

Future<bool> userIsAuthorizedToPackage(
  Package pkg,
  User? user, {
    bool isRoot = false,
  }
) async{
  if (isRoot) return true;

  if (pkg.public ?? true) return true;

  if (user == null) return false;

  if (pkg.author.id == user.id) return true;

  // check if user is a contributor to the package
  final contributors = await crs.db.getContributorsForPackage(pkg.name, scope: pkg.scope);
  return contributors.entries.any(
    (entry) =>
      entry.key.id == user.id &&
      entry.value.any((p) => p == Privileges.write || p == Privileges.publish),
  );
}