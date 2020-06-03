
jar-package:
	(cd java-app && ./mvnw package)
	cp java-app/target/*-SNAPSHOT.jar jar-on-scalingo

docker-build: java-app-jar-package
	docker-compose build

docker-up:
	docker-compose up

docker-bash:
	docker-compose run java-app bash

scalingo-build: java-app-jar-package
	tar -cvzf jar-on-scalingo.tar.gz jar-on-scalingo

scalingo-and-outscale-provision:
	./infrastructure/tf.sh apply

scalingo-deploy:
	./infrastructure/deploy.sh

scalingo-up: scalingo-deploy

# scalingo-bash:
#	scalingo run bash --app $application-name
