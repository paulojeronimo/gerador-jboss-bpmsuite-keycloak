# Projeto de integração: JBoss BPM Suite + Keycloak

## Introdução

Este projeto automatiza a geração de binários para execução integrada do [JBoss BPM Suite][jboss-bpmsuite] e o do [Keycloak][keycloak].

É utilizado, na configuração dos datasources utilizados por esses produtos, o banco de dados Oracle (pode ser o [Oracle Database 11g Express Edition][oracle-xe]).

São gerados binários de execução do [JBoss EAP][jboss-eap] para dois ambientes:
* Ambiente de desenvolvimento (local, utilizando o JBoss em modo standalone).
    * Nesse ambiente a geração pode ser integrada ao projeto [javaee-ambiente][javaee-ambiente].
* Ambiente de homologação (utilizando o JBoss em modo domain):
    * Executável localmente, em um ambiente com uma máquina virtual gerenciada pelo [Vagrant][vagrant] e provisionada com o [Docker][docker] (em ambiente Linux, não é necessário o uso do Vagrant). Esse ambiente é utilizado para testes de configuração.
    * Os binários gerados para esse ambiente também podem ser copiados para máquinas configuradas de forma equivalente aos contêineres Docker.

Os ambientes de desenvolvimento e homologação podem ser executados em servidores Linux, OS X ou Windows.

O script de geração dos binários para a execução integrada do JBoss BPM Suite e do Keycloak também aplica os ``patches`` desenvolvidos pela Red Hat para esses produtos.

## Prós e contras

O uso deste projeto adiciona ganhos significativos ao processo tradicional de instalação e configuração de servidores que é o de seguir um documento contendo um roteiro detalhado do que precisa ser realizado. Através desse projeto, espera-se que:
1. A montagem de um ambiente seja realizada de forma rápida, automática e gerenciável.
2. A evolução desse ambiente ocorra de forma sistemática e rastreável.

Talvez possa ser levantada como desvantagem por usuários Windows, a necessidade de conhecimentos de [programação em (Bash)](http://tldp.org/HOWTO/Bash-Prog-Intro-HOWTO.html) e a instalação do [Cygwin][cygwin] para que os scripts deste projeto possam ser executados.

## Pré-requisitos

Para a execução dos scripts desenvolvidos neste projeto é necessário:

1. Se estiver sendo utilizado um ambiente Windows, instalar o [Cygwin][cygwin]. Siga os [procedimentos descritos no projeto javaee-ambiente](https://github.com/paulojeronimo/javaee-ambiente/blob/master/cygwin.asciidoc) para proceder a instalação dessa ferramenta. Obviamente, em Linux e OS X isso não é necessário;
2. Instalar o **Java SE Development Kit;**
    * Podem ser utilizados, sem restrições, as versões [7u79](http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html) ou [8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) (testes foram realizados, em ambiente de desenvolvimento, com o uso da versão 8u51).
3. Baixar os seguintes binários:
    * A partir do site da Red Hat (_necessário efetuar login_):
        * [jboss-eap-6.4.0.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=37393)
        * [jboss-eap-6.4.2-patch.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=38833)
        * [jboss-bpmsuite-6.1.0.GA-deployable-eap6.x.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=37673)
        * [jboss-bpmsuite-6.1.1-patch.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=38333)
        * [BZ-1234592-patch-for-6.1.1.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=38753&product=bpm.suite)
    * [keycloak-overlay-eap6-1.4.0.Final.zip](http://downloads.jboss.org/keycloak/1.4.0.Final/keycloak-overlay-eap6-1.4.0.Final.zip)
    * [keycloak-eap6-adapter-dist-1.4.0.Final.zip](http://downloads.jboss.org/keycloak/1.4.0.Final/keycloak-overlay-eap6-1.4.0.Final.zip)
    * [ojdbc7.jar](http://www.oracle.com/technetwork/database/features/jdbc/jdbc-drivers-12c-download-1958347.html) (_necessário aceitar os temos da licença_)

Para a execução do JBoss BPM Suite gerado através desse projeto, é necessário:

1. Iniciar um banco de dados Oracle e criar bancos para acomodar as tabelas do JBoss BPM Suite e do Keycloak.
    * A instalação de um banco Oracle XE pode ser feita de forma rápida e simples pela utilização do projeto [docker-oracle-xe][docker-oracle-xe]. Obviamente, ele também pode ser instalado de forma nativa no teu sistema operacional (em Linux e Windows). Contudo, para o Mac OS X, não há binários de instalação e essa é a alternativa recomendada.
    * A criação dos bancos pode ser realizada através de scripts fornecidos neste projeto.

## Geração e uso do ambiente de desenvolvimento

No ambiente de desenvolvimento, uma única instância de JBoss é utilizada para a execução do JBoss BPM Suite. Ela é iniciada em modo standalone. Essa instalação pode ser realizada utilizando-se (ou não) o projeto [javaee-ambiente][javaee-ambiente].

### Geração sem o uso do projeto javaee-ambiente

Crie o diretório ``binarios`` e copie os arquivos baixados para esse diretório.

Abra um shell Bash (no Windows, utilize o Cygwin).

Copie o arquivo ``gerar.config.exemplo`` para ``gerar.config`` e edite-o fazendo quaisquer ajustes que forem necessários para o teu ambiente.

Vá para o diretório desse projeto e execute:
```bash
./gerar
```

Alternativamente, caso você deseje utilizar os binários disponíveis em um diretório específico (diferente de ``binarios``), você pode utilizar a variável ``BIN_DIR`` para informar a localização desse diretório. Dessa forma, a execução do script acima pode ser realizada assim (por exemplo):
```
BIN_DIR=$INSTALADORES_DIR ./gerar
```

Ao final da execução do script ``gerar`` o JBoss BPM Suite estará disponível em ``./desenvolvimento/jboss-eap-6.4``.

### Geração utilizando o projeto javaee-ambiente

Edite o arquivo ``$AMBIENTE_HOME/ambiente.config`` e adicione a seguinte linha a ele (informando, obviamente, a localização correta deste projeto):
```
JBOSS_INSTALA_DIR=$PROJETOS_DIR/gerador-jboss-bmpsuite-keycloak
```

Execute a função ``jboss_instalar`` e observe que, ao final da execução dessa função, o JBoss BPM Suite estará gerado em ``$FERRAMENTAS_DIR/jboss-eap-6.4``.

### Uso do ambiente

#### Criação dos bancos de dados

Se for o primeiro uso do ambiente, será necessário criar os bancos de dados no Oracle. Então, inicie-o. Uma forma de fazer isso, se você estiver utilizando o projeto [docker-oracle-xe][docker-oracle-xe], é configurando a variável ``DOCKER_ORACLE_XE_HOME`` no arquivo ``gerar.config`` para, em seguida, executar este próximo comando:
```
./oracle up
```

Para a execução de scripts SQL no Oracle podem ser utilizados o [sqlplus][sqlplus] e o [Oracle SQL Developer][sql-developer]. Recentemente, a Oracle também lançou o aplicativo [SQLcl][sqlcl] que é utilizado por scripts deste projeto. Então, será necessária a sua instalação.

Após instalar o sqlcl, configure variável de ambiente ``SQLCL_HOME`` informando a localização onde foi extraído esse produto. Essa variável também pode ser configurada no arquivo ``gerar.config`` se já não estiver configurada externamente. Em seguida, crie os bancos de dados do JBoss BPM Suite e do Keycloak executando o seguinte script:
```
./oracle create-databases
```

#### Destruição dos bancos de dados

Se for necessário remover os bancos de dados do BPMS e do KEYCLOAK, o seguinte comando pode ser executado:

```
./oracle drop-databases
```

#### Inicialização do JBoss

Ajuste o valor da variável JBOSS_HOME para a localização do JBoss gerado. Em seguida, inicie o JBoss:
```
$JBOSS_HOME/standalone.sh
```

Acesse a interface administrativa do JBoss em http://localhost:9990. O "usuário/senha" pré-configurado para esse acesso é "admin/redhat@123".

A interface de administração do Keycloak pode ser acessada através da URL http://localhost:8080/auth. Será solicitado um "usuário/senha" que, por padrão, é "admin/admin".

O Business Central pode ser acesado através da URL http://localhost:8080/business-central.

O Dashbuilder pode ser acessado através da URL http://localhost:8080/dashbuilder.

#### Implantação e testes de exemplos do Keycloak

Os exemplos do Keycloak (arquivo [keycloak-examples-1.4.0.Final.zip](http://downloads.jboss.org/keycloak/1.4.0.Final/keycloak-examples-1.4.0.Final.zip) podem ser todos testados nesse ambiente.

Uma forma de testar esses exemplos, passo a passo, é descrita no projeto [tutorial-keycloak](http://github.com/paulojeronimo/tutorial-keycloak).

Para rodar os testes do exemplo ``preconfigured-demo`` aqui, neste ambiente, copie o arquivo dos exemplos para o diretório ``binarios``. Instale o Maven. Em seguida vá para o diretório deste projeto e execute:

```
unzip binarios/keycloak-examples-1.4.0.Final.zip
cd keycloak-examples-1.4.0.Final/preconfigured-demo/
mvn clean install
mvn jboss-as:deploy
```

## Geração e uso do ambiente de homologação

Em ambiente de homologação, o JBoss BPM Suite é instalado em modo domain. São utilizados três hosts, um master e dois slaves.

TODO

[cygwin]: http://cygwin.com
[javaee-ambiente]: http://github.com/paulojeronimo/javaee-ambiente
[jboss-eap]:http://www.jboss.org/products/eap/overview/
[jboss-bpmsuite]: http://www.jboss.org/products/bpmsuite
[keycloak]: http://keycloak.jboss.org
[oracle-xe]: http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html
[vagrant]: http://vagrantup.com
[docker]: http://docker.com
[docker-oracle-xe]: https://github.com/paulojeronimo/docker-oracle-xe
[sqlplus]: https://docs.oracle.com/cd/B19306_01/server.102/b14357/toc.htm
[sql-developer]: http://www.oracle.com/technetwork/developer-tools/sql-developer/overview/index.html
[sqlcl]: http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html
