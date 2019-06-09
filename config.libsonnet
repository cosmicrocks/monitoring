local MonitoringConfigurationMap = {
  clusterName: 'cosmic',
  domain: 'cosmic.rocks',
  admin_user: 'itamar@yoki.works',
  allowed_domains: 'yoki.works',
  oidc_google_clientId: '',
  oidc_google_clientSecret: '',

  slackAlertsChannel: '%s-alerts' % $.clusterName,
  slackHookUrl: 'https://hooks.slack.com/services/dsDOU74DF/BG7E41ESW/dsaHHHDSDSDSSF',
  namespace: 'monitoring',
  storageClassName: 'default',
};

{
  Config: MonitoringConfigurationMap,
}
