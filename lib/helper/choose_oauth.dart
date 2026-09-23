import 'package:azure_ad_oauth_mrt/helper/core_oauth.dart';
import 'package:azure_ad_oauth_mrt/model/config.dart';

CoreOAuth getOAuthConfig(Config config) => CoreOAuth.fromConfig(config);
