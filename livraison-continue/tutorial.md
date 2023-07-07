# Livraison continue

<walkthrough-tutorial-duration duration="40.0"></walkthrough-tutorial-duration>

## Description

Dans cet exercice, vous allez modifier le pipeline précédent pour ajouter une étape de packaging.

Vous allez construire une image Docker et la pousser dans un registre d'artefacts.

## Build image docker

Partez du fichier `.gitlab-ci.yaml` suivant:

```yaml
image: maven:latest

services:
  - docker:20.10.16-dind

variables:
  MAVEN_CLI_OPTS: "--batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"
  # Instruct Testcontainers to use the daemon of DinD.
  DOCKER_HOST: "tcp://docker:2375"
  # Instruct Docker not to start over TLS.
  DOCKER_TLS_CERTDIR: ""
  # Improve performance with overlayfs.
  DOCKER_DRIVER: overlay2

cache:
  paths:
    - .m2/repository/
    - target/

stages:
  - build
  - test

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test
```

Ajoutez un stage `package` avant les stages `build` et `test` qui va lancer deux jobs:

* `mvn:package`: qui va lancer la commande `mvn package`
* `docker:package`: qui va lancer la commande `docker build -f src/main/docker/Dockerfile.jvm -t quarkus/rest-heroes-jvm17 .`
  * Pour fonctionner, ce job a besoin d'utiliser une image `docker:20.10.16`et pas `maven:latest`.
  * Un fichier <walkthrough-editor-open-file filePath="src/main/docker/Dockerfile.jvm">Dockerfile.jvm</walkthrough-editor-open-file> est fourni. Vous pouvez le consultez pour voir ce qui est fait. Ce fichier Dockerfile utilise une image de base OpenJDK-17 fournie par RedHat <https://catalog.redhat.com/software/containers/ubi9/openjdk-17/61ee7c26ed74b2ffb22b07f6?container-tabs=technical-information>.

Le job `docker:package` a besoin du Jar construit par `mvn:package`. Cela se traduit par le mot-clé `needs` dans le fichier de pipeline. Pour rappel, la référence .gitlab-ci.yaml est [ici](https://docs.gitlab.com/ee/ci/yaml/).

Notes: pour valider la construction de l'image Docker, vous pouvez utiliser cloudShell puisque docker, Java et Maven sont installés.

Cependant, le projet Maven Quarkus necessite Java 17, alors que la CLI Maven est configurée pour utiliser Java 11:

```sh
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
```

## Envoi dans la registry

Utilisez la registry d'images fournie par GitLab.

Elle est visible sur `Deploy / Container registry`.

Modifier le job `docker:package` pour que l'image ait le nom de votre registry et soit poussé sur la registry:

```sh
# Attention remplacez XX par le nom de votre projet
docker build docker build -f src/main/docker/Dockerfile.jvm -t ${CI_REGISTRY_IMAGE} .
# Authentification pour envoi de l'image
docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
docker push ${CI_REGISTRY_IMAGE}
```

Une fois le pipeline OK, vous pouvez voir l'image dans la registry.

## Gestion de versions

Le pipeline n'est pas satisfaisant car nous mettons à jour une image avec le tag `latest` à chaque commit!.

Pour introduire une gestion de version, modifiez le pipeline pour exécuter les job du stage `package` uniquement si un tag est présent. Pour cela, testez la valeur de `CI_COMMIT_TAG` est à tester avec le mot clé [rules](https://docs.gitlab.com/ee/ci/yaml/#rulesif).  

Par ailleurs, utilisez le nom du tag GitLab `CI_COMMIT_TAG` comme tag pour l'image docker construite.

Testez la pose d'un tag.

## Améliorations du pipeline

Le pipeline n'est pas satisfaisant car le job `mvn:package` reprend les actions de `build` et `test`.

Pour une question d'optimisation, modifiez le pipeline pour ne faire les job `build` et `test` que si le pipeline est déclenché pour un commit de branche: la variable `CI_COMMIT_BRANCH` ne doit pas être vide.

## Question

Est-ce une bonne idée d'utiliser la registry d'images de GitLab CI?

## Félicitations

Vous avez terminé l'exercice!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
