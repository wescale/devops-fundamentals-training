# Infra as code

<walkthrough-tutorial-duration duration="45.0"></walkthrough-tutorial-duration>

## Description

Dans cet exercice, vous allez utiliser Terraform pour créer une instance sur AWS, et utilisez Ansible pour provisionner l'application construite précédemment.

## Terraform - Installation

La CLI Terraform est déjà installée sur CloudShell. Si ce n'était le cas, il suffirait de récupérer le binaire pré-compilé et de l'ajouter au PATH. Pour les curieux: <https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli>

## Initialisation d'une configuration Terraform

Créez un dossier `terraform` et allez dedans:

```sh
mkdir -p terraform
cd terraform
```

Créez un premier fichier `terraform.tf` qui indique le provider que vous allez utiliser:

```tf
terraform {

  required_version = ">= 1.5"
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.7.0"
    }
  }
}
```

Ce fichier pose des contraintes sur la version de la Terraform possible, ainsi que la version du provider AWS.
Il s'agit de la dernière version à date, telle qu'indiquée sur le site <https://registry.terraform.io/providers/hashicorp/aws/latest/docs>.

Vous pouvez initialiser la configuration terraform en tapant: `terraform init`.

Vous verrez notamment le téléchargement du provider.

## Terraform - configuration de provider

Pour être fonctionnel, le provider doit être configuré avec des credentials. Comme indiqué sur la documentation, le provider AWS supporte différents mécansimes d'authentification, notamment les variables d'environmment.

Chaque stagiaire de la formation a un compte utilisation AWS distinct, avec une paire de clés AWS. Consultez le fichier partagé pour retrouver les clés AWS. **Attention à ne pas diffuser ces credentials**!

Vous pouvez alors les exporter dans le terminal:

```sh
export AWS_ACCESS_KEY_ID=XXX
export AWS_SECRET_ACCESS_KEY=YYY
```

Le provider doit aussi connaitre la région AWS sur laquelle travailler.

Créez un fichier `providers.tf`:

```tf
provider "aws" {
  region = "eu-west-3"
}
```

Enfin, vérifiez que le provider est fonctionnel en créant un fichier `test.tf`:

```tf
data "aws_caller_identity" "current" {}

output "current_aws_account_id" {
  value = "${data.aws_caller_identity.current.id}"
}
```

Lancez une exécution terraform:

```sh
terraform apply
```

Puis entrez `yes`.

Le fichier `test.tf` contient **data** et **output**. Terraform manipule 4 types d'objets:

* **data**: le provider retourne des données sans qu'il n'y ait de traitement
* **resource**: le provider applique un état indiqué. C'est 90% du code terraform
* **variable**: tout est dans le titre
* **output**: valeurs retournées par une configuration Terraform.

## Terraform - keypair

Pour se connecter en SSH à une instance, il faut définir une ressource [Keypair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair).

Vous allez ré-utiliser la clé générée précédemment. Créez un fichier `keypair.tf` avec le contenu suivant:

```tf
resource "aws_key_pair" "cloudshell" {
  key_name   = "${data.aws_caller_identity.current.user_id}-cloudshell"
  public_key = #A compléter
}
```

Modifiez le fichier pour lire le contenu de la clé `~/.ssh/id_rsa.pub`. Pour lire un fichier, Terraform a une fonction [file](https://developer.hashicorp.com/terraform/language/functions/file).

Lancez `terraform apply` lorsque vous pensez que c'est bon.

Question: pourquoi indiquer `${data.aws_caller_identity.current.user_id}` dans le nom de la resource keypair que vous créez ?

## Terraform - Security group

Chaque instance AWS a son propre firewall.

Créez celui de votre machine dans un nouveau fichier `security-group.tf`:

```tf
data "aws_vpc" "main" {}

resource "aws_security_group" "allow_ssh_http" {
  name        = "${data.aws_caller_identity.current.user_id}-allow_ssh_http"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "SSH from Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "TCP from Internet"
    from_port        = 8083
    to_port          = 8083
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}
```

Lancez `terraform apply`.

## Terraform - Instance

Maintenant, créez l'instance avec un nouveau fichier `instance.tf`:

```tf
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.large"

  tags = {
    Name = "${data.aws_caller_identity.current.user_id}-server"
  }

  key_name = aws_key_pair.cloudshell.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
}
```

Lancez `terraform apply`.

## Connexion SSH

Vous devez récupérer l'adresse IP publique de l'instance. Cette valeur est disponible dans l'attribut `public_ip` de l'instance. Voir la documentation <https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#public_ip>.

Créez donc un fichier `outputs.tf`:

```tf
output "instance_pub_ip" {
  value = # A compléter
}
```

Puis exécutez `terraform apply`.
L'adresse IP publique est visible, vous pouvez tenter une connexion SSH:

```sh
ssh -i ~/.ssh/id_rsa ec2-user@PUBLIC_IP
```

## Ansible - installation

```sh
cd ../ansible
python -m pip install --user ansible
python -m pip install --user request
```

Vérifiez qu'Ansible fonctionne: `ansible --version`

## Ansible - inventaire

Ouvrez le fichier `hosts.ini` pour modifier `PUBLIC_IP` par l'IP publique de la machine.

Validez en appelant le module [ping](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ping_module.html) ansible:

```sh
ansible --inventory=hosts.ini -m ping all
```

## Ansible - PostgreSQL

Un playbook est fourni dans le dossier `ansible` pour installer, configurer et initialiser avec des données postgresql.

Exécutez ce playbook:

```sh
ansible-playbook -i hosts.ini play-postgresql.yml -e @vars.yaml
```

## Ansible - rest-heroes-api init

Vous allez créer un playbook Ansible pour provisionner la partie Java `rest-heroes-api`.

Partez du fichier `play-rest-heroes-api.yaml`.

Pour récupérer l'image construite par le pipeline de ci/cd, docker engine doit s'authentifier sur la registry GitLab de votre projet. Le projet étant interne (non public), il en est de même pour les registries associées.

Créez un token d'accès personnel sur gitlab: <https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token> nommé `registry-iac`, avec les droits suivants:

* read (pull) access, read_registry.

Copiez-le et injectez le dans le fichier vars.yaml sous un nouvelle clé `REGISTRY_ACCESS_TOKEN: glpat-XXX`

Dans le playbook, ajoutez deux `task` pour vous pouvoir accéder à la registry d'images puis démarrer le conteneur.

```yaml
# https://docs.ansible.com/ansible/2.9/modules/docker_login_module.html
- name: Log into private registry and force re-authorization
  docker_login:
    registry: "{{ REGISTRY_URL }}"
    username: "{{ REGISTRY_USERNAME }}"
    password: "{{ REGISTRY_PASSWORD }}"

# https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html
- name: Ensure the quarkus container is here
  community.docker.docker_container:
    name: rest-heroes-api
    image: "{{ IMAGE }}"
    state: started
    ports:
      - "8083:8083"
    env:
      QUARKUS_DATASOURCE_REACTIVE_URL: postgresql://heroes-db:5432/{{ POSTGRES_DB }}
      QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION: validate
      QUARKUS_DATASOURCE_USERNAME: "{{ POSTGRES_USER }}"
      QUARKUS_DATASOURCE_PASSWORD: "{{ POSTGRES_PASSWORD }}"
      QUARKUS_HIBERNATE_ORM_SQL_LOAD_SCRIPT: no-file
      QUARKUS_OTEL_EXPORTER_OTLP_TRACES_ENDPOINT: http://otel-collector:4317
    networks:
      - name: "network_one"
```

Ajouter les variables necessaires dans `vars.yaml`.

Exécutez ce playbook:

```sh
ansible-playbook -i hosts.ini play-rest-heroes-api.yml -e @vars.yaml
```

Si tout est bon, vous devez pouvoir accéder au service http://PUBLIC_IP:8083/.

## Nettoyage

```sh
terraform destroy
```

## Remarques

* L'usage fait de Terraform pour créer une instance AWS unitaire n'est pas une bonne pratique.
* L'usage de Terraform et Ansible tel que pensez ici n'est pas optimal. Construire une AMI serait plus efficace.
* Terraform doit persister son état sur un `backend`

## Félicitations

Vous avez terminé l'exercice!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
