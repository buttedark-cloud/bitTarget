import 'package:bittarget/core/network/api_client.dart';
import 'package:bittarget/l10n/app_localizations.dart';

String apiErrorText(AppLocalizations l10n, ApiErrorKind kind) {
  switch (kind) {
    case ApiErrorKind.network:
      return l10n.errNetwork;
    case ApiErrorKind.timeout:
      return l10n.errTimeout;
    case ApiErrorKind.server:
      return l10n.errServer;
    case ApiErrorKind.rateLimited:
      return l10n.errRateLimited;
    case ApiErrorKind.unknown:
      return l10n.errUnknown;
  }
}
