module "france_dev" {
  source = "./modules/environments/france/dev"
}

module "germany_dev" {
  source = "./modules/environments/germany/dev"
}

module "france_staging" {
  source = "./modules/environments/france/staging"
}

module "germany_staging" {
  source = "./modules/environments/germany/staging"
}

module "france_prod" {
  source = "./modules/environments/france/prod"
}

module "germany_prod" {
  source = "./modules/environments/germany/prod"
}