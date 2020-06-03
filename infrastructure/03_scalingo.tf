
provider "scalingo" {
  region       = ""
  api_token    = var.scalingo_apitoken
  auth_api_url = "https://auth.scalingo.com"
  api_url      = "https://api.osc-fr1.scalingo.com"
}

resource "scalingo_app" "component_app" {
  name = "${local.demovars.prefix}-component-${count.index}"
  environment = {
    BUILDPACK_URL = "https://github.com/Scalingo/buildpack-jvm-common"
  }
  count = 3
}

resource "scalingo_addon" "component_influx" {
  provider_id = "influxdb"
  plan        = "free"
  app         = scalingo_app.component_app[0].id
}
resource "scalingo_addon" "component_pg" {
  provider_id = "postgresql"
  plan        = "postgresql-sandbox"
  app         = scalingo_app.component_app[0].id
}

resource "scalingo_app" "grafana_app" {
  name = "${local.demovars.prefix}-grafana"
  environment = {
    "BUILDPACK_URL"              = "https://github.com/Scalingo/multi-buildpack"
    "GF_DATABASE_URL"            = "$SCALINGO_POSTGRESQL_URL",
    "GF_SECURITY_ADMIN_PASSWORD" = var.grafana_passwd,
    "GF_SECURITY_ADMIN_USER"     = var.grafana_user,
    "GF_SERVER_HTTP_PORT"        = "$PORT",
    "NPM_CONFIG_PRODUCTION"      = "false",
  }
}

resource "scalingo_addon" "grafana_pg" {
  provider_id = "postgresql"
  plan        = "postgresql-sandbox"
  app         = scalingo_app.grafana_app.id
}

resource "scalingo_app" "metabase_app" {
  name = "${local.demovars.prefix}-metabase"
  environment = {
    "BUILDPACK_URL" = "https://github.com/Scalingo/multi-buildpack"
  }
}
resource "scalingo_addon" "metabase_pg" {
  provider_id = "postgresql"
  plan        = "postgresql-sandbox"
  app         = scalingo_app.metabase_app.id
}

resource "scalingo_app" "sentry_app" {
  name = "${local.demovars.prefix}-sentry"
}
resource "scalingo_addon" "sentry_pg" {
  provider_id = "postgresql"
  plan        = "postgresql-sandbox"
  app         = scalingo_app.sentry_app.id
}
