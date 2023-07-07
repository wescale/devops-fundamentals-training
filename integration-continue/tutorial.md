# Intégration continue

<walkthrough-tutorial-duration duration="45.0"></walkthrough-tutorial-duration>

## Description

Dans cet exercice, vous allez créer un pipeline d'intégration continue GitLab CI.

Ce pipeline va intégrer une application Java Quarkus composé d'un micro service REST avec une base de données PostgreSQL.

## Fork vers un projet GitLab CI

Le pipeline GitLab CI que vous allez créer à besoin d'un projet... commençons donc par cela:

* Allez dans le groupe de projet [CI sur le GitLab](https://gitlab.dev.aws.wescale.fr/devops-training/ci) d'exercices.
* Cliquez sur le bouton `Nouveau projet` et créez un projet vide avec le nom qui vous a été attribué **k8s-fund-trainee-X**.
* Assurez-vous que vous avez décoché: `Initialize repository with a README` pour avoir un répertoire vide

CloudShell, récupérez le contenu de référence présent sur GitHub <https://github.com/wescale/quarkus-rest-heroes>:

```sh
git clone https://github.com/wescale/quarkus-rest-heroes
cd quarkus-rest-heroes
```

Enfin, poussez le contenu sur le répertoire GitLab que vous venez de créer. Attention à bien utilisez l'URL de votre repertoire: `k8s-fund-trainee-XX` apparait dans la commande ci-dessous, remplacez cette valeur par le nome du projetque vous avez créez:

```sh
git remote rename origin old-origin
git remote add origin git@gitlab.dev.aws.wescale.fr:devops-training/ci/k8s-fund-trainee-XX.git
git branch -M main
git push -u origin main
```

Voilà, vous êtes pret à créer votre premier pipeline GitLab CI.

## Initialisation du fichier .gitlab-ci.yaml

Vous pouvez éditez le fichier en ligne sur GitLab CI en allant sur le projet puis `Build / Pipeline Editor`. Il contient une vérification de syntaxe YAML, exécute un commit à chaque sauvegarde, et donne un lien vers le pipeline en cours d'exécution.

Partez de la coquille suivante pour créer le `.gitlab-ci.yaml`:

```yaml
image: maven:latest

services:
  - docker:20.10.16-dind

variables:
  MAVEN_CLI_OPTS: "--batch-mode"
  MAVEN_OPTS: "-Dmaven.repo.local=.m2/repository"
  # Instruct to use the daemon of DinD, instead of unix socket
  DOCKER_HOST: "tcp://docker:2375"
  # Instruct Docker not to start over TLS.
  DOCKER_TLS_CERTDIR: ""
  # Improve performance with overlayfs.
  DOCKER_DRIVER: overlay2

# Cache downloaded dependencies and plugins between builds.
# To keep cache across branches add 'key: "$CI_JOB_NAME"'
# Be aware that `mvn deploy` will install the built jar into this repository. If you notice your cache size
# increasing, consider adding `-Dmaven.install.skip=true` to `MAVEN_OPTS` or in `.mvn/maven.config`
cache:
  paths:
    - .m2/repository/
    - target/

# To be completed
# ....
```

Vous devez compléter le fichier pour avoir 2 stages:

* build: qui execute la commande `mvn $MAVEN_CLI_OPTS compile`
* test: qui execute la commande `mvn $MAVEN_CLI_OPTS test`

La référence .gitlab-ci.yaml est [ici](https://docs.gitlab.com/ee/ci/yaml/).

## Bonus - Pre-commit

[Pre-commit](https://pre-commit.com/#install) est un utilitaire qui permet de faire un certain nombre de vérifications avant d'exécuter un commit.

L'outil contient un certain nombre de [Hooks](https://pre-commit.com/hooks.html) pour différents languages.

Le répertoire quarkus-rest-heroes contient un fichier de configuration .pre-commit-config.yaml qui vérifie la fin de ligne, la syntaxe YAML et la présence d'espace en fin de fichiers.

Pre-commit est basé sur Python 3.10.

Modifiez le pipeline pour ajouter un stage `pre-commit`, qui utilise une image python, install pre-commit et lance la commande `pre-commit run -a`.

Le pipeline est il sans erreur ?

Pour installer pre-commit sur votre environnement Cloud Shell:

```sh
pip install pre-commit
export PATH=$PATH:$HOME/.local/bin
```

## Félicitations

Vous avez terminé l'exercice!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
