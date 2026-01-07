module "france_dev" {
  source = "./modules/environments/france/dev"
  providers = {
    aws = aws.france
  }
}

module "germany_dev" {
  source = "./modules/environments/germany/dev"
  providers = {
    aws = aws.germany
  }
}

module "france_staging" {
  source = "./modules/environments/france/staging"
  providers = {
    aws = aws.france
  }
}

module "germany_staging" {
  source = "./modules/environments/germany/staging"
  providers = {
    aws = aws.germany
  }
}

module "france_prod" {
  source = "./modules/environments/france/prod"
  providers = {
    aws = aws.france
  }
}

module "germany_prod" {
  source = "./modules/environments/germany/prod"
  providers = {
    aws = aws.germany
  }
}