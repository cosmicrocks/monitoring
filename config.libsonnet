local MonitoringConfigurationMap = {
  clusterName: 'alpha',
  domain: 'alpha.cosmic.rocks',
  admin_user: 'itamarperez@cosmic.rocks',
  allowed_domains: 'cosmic.rocks',
  oidc_google_clientId: 'oidc-auth-client',
  oidc_google_clientSecret: 'ZXhh',

  slackAlertsChannel: '%s-alerts' % $.clusterName,
  slackHookUrl: 'https://hooks.slack.com/services/dsDOU74DF/BG7E41ESW/dsaHHHDSDSDSSF',
  namespace: 'monitoring',
  storageClassName: 'default',
};

{
  Config: MonitoringConfigurationMap,
}
