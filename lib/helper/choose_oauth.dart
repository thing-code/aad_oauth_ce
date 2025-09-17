import 'package:aad_oauth_ce/helper/core_oauth.dart';
import 'package:aad_oauth_ce/model/config.dart';

CoreOAuth getOAuthConfig(Config config) => CoreOAuth.fromConfig(config);
