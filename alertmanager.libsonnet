local conf = import 'config.libsonnet';

local defaultResolveTimeout = '10m';

local defaultReceiver = 'none';

local groupBy = ['alertname', 'cluster'];

local defaultGroupWait = '10s';
local defaultGroupInterval = '5m';
local defaultRepeatInterval = '1h';

local slackRoute = {
  receiver: 'slack',
  match: {
    severity: 'warning',
  },
};

local defaultAlertTitle = '{{ .GroupLabels.alertname }}';
local defaultAlertText =
  |||
    {{ range .Alerts }}
    {{ range .Labels.SortedPairs }} *{{ .Name }}:* {{ .Value }}
    {{ end }}
    {{ end }}
  |||;

{
  alertmanager+:: {
    global: {
      resolve_timeout: defaultResolveTimeout,
    },
    route: {
      receiver: defaultReceiver,
      group_by+: groupBy,
      group_wait: defaultGroupWait,
      group_interval: defaultGroupInterval,
      repeat_interval: defaultRepeatInterval,
      routes: [
        slackRoute,
      ],
    },
    receivers: [
      {
        name: 'none',
      },
      {
        name: 'slack',
        slack_configs: [
          {
            api_url: conf.Config.slackHookUrl,
            channel: '#%s' % conf.Config.slackAlertsChannel,
            send_resolved: true,
            title_link: 'https://prometheus.%s/alerts' % conf.Config.domain,
            title: defaultAlertTitle,
            text: defaultAlertText,
          },
        ],
      },
    ],
  },
}
