# Example project with Infra-as-Code and Dev/Prod parity using Scalingo and 3DS Outscale

## Architecture

Here is the architecture diagram of the infrastructure:

![architecture diagram](https://i.imgur.com/qcyeOBU.png)

## Pre-requisite

- Docker, docker-engine, and docker-compose for the development environment
- Terraform for the provisionning
- The Scalingo CLI (https://cli.scalingo.com/)
- Java 1.8 or more

## Run the app locally

- Go to the `java-app` directory
- Run `./mvnw spring-boot:run`
- Go take a coffee ☕️ while maven is downloading dependencies

## Run the dev environment

- At the project root directory
- Run `make docker-up`
- Go take a coffee ☕️ while docker is downloading dependencies

*Note:* you can explore the dev environment by running `make docker-bash`

## Provision the infrastructure

- You will need Scalingo and Outscale credential  
- Edit the file `./infrastructure/tf.sh.to-edit` with the credentials
- Rename the file to `./infrastructure/tf.sh`
- Go to the project root directory
- Run `make scalingo-and-outscale-provision`, read the output !
- WIP: Run `make scalingo-and-outscale-up` to deploy the configurations => This step is not finished and needs updating


