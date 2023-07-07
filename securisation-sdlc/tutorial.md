# Sécurisation du SDLC

<walkthrough-tutorial-duration duration="25.0"></walkthrough-tutorial-duration>

## Description

Dans cet exercice, vous allez sécuriser le pipeline d'intégration continue GitLab CI précédemment créé.

Vous allez mettre en oeuvre une sécurisation sur deux axes:

* Software Composition Analysis (SCA), avec l'analyse des images de base à partir desquelles sont construites votre application. Pour cela vous utiliserez [Trivy](https://github.com/aquasecurity/trivy).
* Static Application Security Testing (SAST), avec l'analyse du code source avec [Semgrep](https://semgrep.dev/).

## Etat de départ

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
  - package
  - build
  - test

build:
  stage: build
  script:
    - mvn $MAVEN_CLI_OPTS compile
  rules:
    - if: $CI_COMMIT_BRANCH

test:
  stage: test
  script:
    - mvn $MAVEN_CLI_OPTS test
  rules:
    - if: $CI_COMMIT_BRANCH

mvn:package:
  stage: package
  script:
    - mvn $MAVEN_CLI_OPTS package
  rules:
    - if: $CI_COMMIT_TAG

docker:package:
  stage: package
  image: docker:20.10.16
  needs: ["mvn:package"]
  script:
    - docker build -f src/main/docker/Dockerfile.jvm -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG} .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push ${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}
  rules:
    - if: $CI_COMMIT_TAG
```

## Analyse des images de base (SCA) avec Trivy

GitLab CI propose une intégration facilitée de Trivy, au travers d'un directive `include`:

```yaml
include:
  - template: Security/Container-Scanning.gitlab-ci.yml
```

Plus de détails [ici](https://gitlab.dev.aws.wescale.fr/help/user/application_security/container_scanning/index#configuration).

Une fois ajoutée, vous aurez un nouveau job `container_scanning` exécuté au stage `test`.

Puisque l'image n'est construite que lorsqu'un tag est poussé, vous devez configurer le job de scan `container_scanning` pour:

* n'être executé que lorsque le pipeline est déclanché pour un tag
* utiliser la variable `CS_IMAGE` pour indiquer que l'image est scanner est `${CI_REGISTRY_IMAGE}:${CI_COMMIT_TAG}`

Vérifier que le pipeline exécuté pour branche `main`, ne génère pas de scan.

Vérifier que le pipeline exécuté pour un nouveau tag, génère un scan. Les rapports sont disponibles dans la section `Build / Artifacts`.

## Analyse du code SAST avec Semgrep

GitLab CI propose une intégration facilitée avec Semgrep:

```yaml
sast:
  stage: test
include:
- template: Security/SAST.gitlab-ci.yml
```

Le contenu détaillé de l'include est ici: <https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml>

Les rapports sont disponibles dans la section `Build / Artifacts`.

## Question

Que pensez-vous de cette approche ?
## Félicitations

Vous avez terminé l'exercice!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
