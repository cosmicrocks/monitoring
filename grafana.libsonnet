local conf = import 'config.libsonnet';

(import 'kube-prometheus/kube-prometheus.libsonnet') +
(import 'kubernetes-mixin/mixin.libsonnet') +
{
  _config+:: {
    clusterName: conf.Config.clusterName,
    clientId: conf.Config.oidc_google_clientId,
    clientSecret: conf.Config.oidc_google_clientSecret,
    namespace: conf.Config.namespace,
    versions+:: {
      grafana: '6.2.1',
    },
    grafana+:: {
      config: {
        sections: {
          metrics: { enabled: true },
          server: {
            domain: 'grafana.%s' % conf.Config.domain,
            root_url: 'https://grafana.%s' % conf.Config.domain,
          },
          auth: { disable_login_form: true },
          'auth.basic': { enabled: false },
          users: {
            auto_assign_org_role: 'Editor',
          },
          security: {
            admin_user: conf.Config.admin_user,
          },
          'auth.google': {
            enabled: true,
            client_id: $._config.clientId,
            client_secret: $._config.clientSecret,
            scopes: 'https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email',
            auth_url: 'https://accounts.google.com/o/oauth2/auth',
            token_url: 'https://accounts.google.com/o/oauth2/token',
            allowed_domains: conf.Config.allowed_domains,
            allow_sign_up: true,
          },
        },
      },
      datasources:
        [
          {
            name: 'Prometheus',
            type: 'prometheus',
            access: 'proxy',
            orgId: 1,
            url: 'http://prometheus-' + $._config.clusterName + '.' + conf.Config.namespace + '.svc:9090',
            version: 1,
            editable: true,
          },
        ],
    },
  },
  grafanaDashboards+::
    {
    'postgres.json': (import 'dashboards/postgres.json'),
  },
}
