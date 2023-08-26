.PHONY: start stop local cloud init up down ps exec kind eks vault cronjob teamcity kube-context pip run freeze deploy

init:
	./scripts/init.sh

up:
	docker-compose up -d --build

down:
	docker-compose down

ps:
	docker-compose ps -a

exec:
	docker exec -it app bash

kind:
	./kind/kind.sh $(word 2,$(MAKECMDGOALS))

eks:
	./eks/eks.sh $(word 2,$(MAKECMDGOALS))

vault:
	./vault/vault.sh $(word 2,$(MAKECMDGOALS))

cronjob:
	./password-rotation-cronjob/cronjob.sh $(word 2,$(MAKECMDGOALS))

teamcity:
	./teamcity/teamcity.sh $(word 2,$(MAKECMDGOALS))

kube-context:
	./scripts/kube-context.sh $(word 2,$(MAKECMDGOALS))
	
