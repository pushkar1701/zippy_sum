/// Central registry for all external URLs used by ZippySum.
///
/// Expected app-ads.txt URL: https://bonafide-losers.vercel.app/app-ads.txt
// TODO: Update app-ads.txt on bonafide-losers.vercel.app with the real AdMob
//       publisher ID before production ads go live.
abstract final class AppLinks {
  // TODO: Replace test AdMob IDs with production IDs before App Store release.

  static const String website = 'https://bonafide-losers.vercel.app';

  static const String privacyPolicy =
      'https://bonafide-losers.vercel.app/apps/zippysum/privacy';

  static const String support =
      'https://bonafide-losers.vercel.app/apps/zippysum/support';
}
