import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google UMP (GDPR / US state privacy) consent gathered before any ad request.
///
/// Release builds do not force a debug geography and do not pass test device
/// identifiers. A message still has to be published in AdMob under
/// Privacy & messaging, or the SDK has no form to show.
class ConsentManager {
  ConsentManager();

  /// Used when ads are unsupported (tests, desktop). Never touches the plugin.
  ConsentManager.unavailable() : _unavailable = true;

  bool _unavailable = false;
  bool canRequestAds = false;
  bool privacyOptionsRequired = false;

  Future<void> gatherConsent() async {
    if (_unavailable) return;
    try {
      final error = await _requestConsentInfoAndShowFormIfRequired();
      if (error != null) {
        debugPrint(
          'UMP consent form error ${error.errorCode}: ${error.message}',
        );
      }
    } catch (error, stack) {
      debugPrint('UMP consent update failed: $error\n$stack');
    }
    await _refreshFlags();
  }

  Future<void> showPrivacyOptionsForm() async {
    if (_unavailable || !privacyOptionsRequired) return;
    final completer = Completer<void>();
    try {
      await ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) {
          debugPrint(
            'UMP privacy options error ${formError.errorCode}: ${formError.message}',
          );
        }
        if (!completer.isCompleted) completer.complete();
      });
    } catch (error, stack) {
      debugPrint('UMP privacy options failed: $error\n$stack');
      if (!completer.isCompleted) completer.complete();
    }
    await completer.future;
    await _refreshFlags();
  }

  Future<FormError?> _requestConsentInfoAndShowFormIfRequired() {
    final completer = Completer<FormError?>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        tagForUnderAgeOfConsent: false,
        consentDebugSettings: kDebugMode
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyDisabled,
              )
            : null,
      ),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            if (!completer.isCompleted) completer.complete(formError);
          });
        } catch (error, stack) {
          debugPrint('UMP form failed: $error\n$stack');
          if (!completer.isCompleted) completer.complete(null);
        }
      },
      (FormError error) {
        if (!completer.isCompleted) completer.complete(error);
      },
    );
    return completer.future;
  }

  Future<void> _refreshFlags() async {
    try {
      canRequestAds = await ConsentInformation.instance.canRequestAds();
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      privacyOptionsRequired =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (error, stack) {
      debugPrint('UMP status read failed: $error\n$stack');
      canRequestAds = false;
      privacyOptionsRequired = false;
    }
  }
}
