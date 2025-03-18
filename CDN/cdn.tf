terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = ""
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-cdn"
  location = "brazilsouth"
}

resource "azurerm_app_service_plan" "plan" {
    name                = "asp-cdn-luiz"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "app" {
    name                = "app-cdn-luiz"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.plan.id
}

resource "azurerm_cdn_profile" "profile" {
  name                = "cdn-profile-luiz"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "endpoint" {
  name                = "cdn-endpoint-luiz"
  profile_name        = azurerm_cdn_profile.profile.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  origin_host_header  = azurerm_app_service.app.default_site_hostname

  origin {
    name      = "cdnendpointluizorigin"
    host_name = azurerm_app_service.app.default_site_hostname
  }

  delivery_rule{
    name = "cdnendpointluizrule"
    order = 1

    request_scheme_condition {
      match_values = ["HTTPS"]
      operator     = "Equal"
    }

    url_redirect_action {
        redirect_type = "Found"
        protocol = "Https"
    }
  }
}
