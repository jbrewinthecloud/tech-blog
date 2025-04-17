terraform {
  backend "remote" {
    organization = "jbrewinthecloud"

    workspaces {
      name = "tech-blog"
    }
  }
}

