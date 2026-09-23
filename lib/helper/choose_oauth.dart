import 'package:azure_oauth/helper/core_oauth.dart';
import 'package:azure_oauth/model/config.dart';

CoreOAuth getOAuthConfig(Config config) => CoreOAuth.fromConfig(config);
