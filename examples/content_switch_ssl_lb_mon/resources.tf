
resource "netscaler_sslcertkey" "generic-cert" {
  certkey = "${lookup(var.ssl_config, "certname")}"
  cert = "${lookup(var.ssl_config, "certfile")}"
  key = "${lookup(var.ssl_config, "keyfile")}"
  expirymonitor = "ENABLED"
  notificationperiod = "${lookup(var.ssl_config, "notificationperiod")}"
}

resource "netscaler_csvserver" "generic_cs" {
  name = "${lookup(var.lb_config, "lbname")}"
  ipv46 = "${lookup(var.lb_config, "vip")}"
  port = "${lookup(var.lb_config, "port")}"
  servicetype = "${lookup(var.lb_config, "servicetype")}"
  sslcertkey = "${netscaler_sslcertkey.generic-cert.certkey}"
}

resource "netscaler_cspolicy" "cart" {
  policyname = "cart_cspolicy"
  url = "${lookup(var.backend_service_config_cart, "url")}"
  csvserver = "${netscaler_csvserver.generic_cs.name}"
  targetlbvserver = "${netscaler_lbvserver.lb_cart.name}"
}

resource "netscaler_cspolicy" "catalog" {
  policyname = "catalog_cspolicy"
  url = "${lookup(var.backend_service_config_catalog, "url")}"
  csvserver = "${netscaler_csvserver.generic_cs.name}"
  targetlbvserver = "${netscaler_lbvserver.lb_catalog.name}"
}

resource "netscaler_lbvserver" "lb_cart" {
  name = "${lookup(var.backend_service_config_cart, "name")}"
  lbmethod = "ROUNDROBIN"
  persistencetype = "COOKIEINSERT"
  servicetype = "${lookup(var.backend_service_config_cart, "servicetype")}"
}

resource "netscaler_lbvserver" "lb_catalog" {
  name = "${lookup(var.backend_service_config_catalog, "name")}"
  lbmethod = "LEASTRESPONSETIME"
  servicetype = "${lookup(var.backend_service_config_catalog, "servicetype")}"
}


resource "netscaler_service" "backend_cart" {
  lbvserver = "${netscaler_lbvserver.lb_cart.name}"
  lbmonitor = "${netscaler_lbmonitor.cart_monitor.monitorname}"
  count = "${length(var.backend_services_cart)}"
  ip = "${element(var.backend_services_cart, count.index)}"
  servicetype = "${lookup(var.backend_service_config_cart, "servicetype")}"
  port = "${lookup(var.backend_service_config_cart, "port")}"
  clttimeout = "${lookup(var.backend_service_config_cart, "client_timeout")}"
}

resource "netscaler_service" "backend_catalog" {
  lbvserver = "${netscaler_lbvserver.lb_catalog.name}"
  lbmonitor = "${netscaler_lbmonitor.catalog_monitor.monitorname}"
  count = "${length(var.backend_services_catalog)}"
  ip = "${element(var.backend_services_catalog, count.index)}"
  servicetype = "${lookup(var.backend_service_config_catalog, "servicetype")}"
  port = "${lookup(var.backend_service_config_catalog, "port")}"
  clttimeout = "${lookup(var.backend_service_config_catalog, "client_timeout")}"
}

resource "netscaler_lbmonitor" "cart_monitor" {
  monitorname = "${lookup(var.http_monitor_config_cart, "name")}"
  type = "HTTP"
  interval = "${lookup(var.http_monitor_config_cart, "interval_ms")}"
  resptimeout = "${lookup(var.http_monitor_config_cart, "response_timeout_ms")}"
  units3 = "MSEC"
  units4 = "MSEC"
}

resource "netscaler_lbmonitor" "catalog_monitor" {
  monitorname = "${lookup(var.http_monitor_config_catalog, "name")}"
  type = "HTTP"
  interval = "${lookup(var.http_monitor_config_catalog, "interval_ms")}"
  resptimeout = "${lookup(var.http_monitor_config_catalog, "response_timeout_ms")}"
  units3 = "MSEC"
  units4 = "MSEC"
}
