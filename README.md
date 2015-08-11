# Projeto de integração: JBoss BPM Suite + Keycloak

## Introdução

Este projeto automatiza a geração de binários para execução integrada do [JBoss BPM Suite][jboss-bpmsuite] e do [Keycloak][keycloak].

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

1. A montagem de um ambiente seja realizada de forma menos humana (errônea), rápida, automática e gerenciável.
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
        * [jboss-eap-native-utils-6.4.0-win6.x86_64.zip](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=36833) (_se a geração estiver sendo realizada para a plataforma Windows_)
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

## Geração, uso e remoção do ambiente de desenvolvimento

No ambiente de desenvolvimento, uma única instância de JBoss é utilizada para a execução do JBoss BPM Suite. Ela é iniciada em modo standalone. Essa instalação pode ser realizada utilizando-se (ou não) o projeto [javaee-ambiente][javaee-ambiente].

### Geração sem o uso do projeto javaee-ambiente

Crie o diretório ``binarios`` e copie os arquivos baixados para esse diretório.

Abra um shell Bash (no Windows, utilize o Cygwin).

Copie o arquivo ``gerar.config.exemplo`` para ``gerar.config`` e edite-o fazendo quaisquer ajustes que forem necessários para o teu ambiente.

Vá para o diretório desse projeto e execute:
```bash
./gerar
```

Alternativamente, caso você deseje utilizar os binários disponíveis em um diretório específico (diferente de ``binarios``), você pode utilizar a variável ``BIN_DIR`` para informar a localização desse diretório. Dessa forma, a execução do script acima pode ser realizada da seguinte forma (por exemplo):
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

O arquivo [jboss.sh](jboss.sh) é o que realiza a integração deste projeto com o projeto javaee-ambiente. Altere o seu conteúdo se precisar fazer algum ajuste.

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

#### Criação do realm do Keycloak (e sua exportação)

Este passo é necessário para a criação do arquivo ``myapp-realm.json``. Esse arquivo é importado pelo Keycloak na inicialização do JBoss e isso é realizado quando é especificado o parâmetro ``-Dkeycloak.import=$JBOSS_HOME/myapp-realm.json``. Dessa forma o Keycloak importa (se já não existirem) as configurações para o realm ``myapp``.

Neste projeto, o arquivo ``myapp-realm.json`` já existe e está disponível no diretório ``keycloak/myapp``. Sendo assim, os passos descritos aqui são apenas informativos e estão disponíveis para que possam ser realizados, novamente, caso se deseje recriar esse arquivo do zero quando o banco de dados do Keycloak ainda não contiver informações sobre o realm ``myapp``. No caso desse banco já conter tais configurações, o arquivo ``myapp-realm.json`` pode ser gerado por uma função do script ``gerar`` (executada nos passos descritos abaixo).

Os passos realizados para a configuração do Keycloak através de sua interface de administrativa são os seguintes:

1. Efetue o login na console administrativa do Keycloak (http://localhost:8080/auth/admin/)
1. Crie o realm ``myapp`` (http://localhost:8080/auth/admin/master/console/#/create/realm)
    * Para o campo ``Name`` em ``Create Realm`` informe o valor ``myapp``
    * Clique no botão ``Create``
1. Clique em ``Clients`` (http://localhost:8080/auth/admin/master/console/#/realms/myapp/clients)
    * Clique em ``Create`` (http://localhost:8080/auth/admin/master/console/#/create/client/myapp)
    * Para o campo ``Client ID`` informe o valor ``business-central``
    * Para o campo ``Valid Redirect URIs`` informe o valor ``/business-central/*``
    * Clique no botão ``Save``
    * Altere o valor do campo ``Base URL`` para ``/business-central``
    * Altere o valor do campo ``Admin URL`` para ``/business-central``
    * Clique no botão ``Save``
    * Vá para a aba ``Installation``
        * Selecione ``Keycloak JSON`` para ``Format option``
        * Clique em ``Download`` para salvar o arquivo ``keycloak.json`` no diretório ``desenvolvimento/jboss-eap-6.4.files/standalone/deployments/business-central/WEB-INF``
1. Repita os passos anteriores para criar o cliente ``dashbuilder``
1. Clique em ``Roles`` (http://localhost:8080/auth/admin/master/console/#/realms/myapp/roles)
    * Adicione as seguintes roles: ``admin``, ``analyst``, ``developer``, ``manager`` e ``user``. Essas são as roles definidas nos arquivos ``web.xml`` das aplicações ``business-central`` e ``dashbuilder``
1. Clique em ``Users`` (http://localhost:8080/auth/admin/master/console/#/realms/myapp/users)
    * Clique em ``Add User`` (http://localhost:8080/auth/admin/master/console/#/create/user/myapp)
    * Para o campo ``Username`` informe o valor ``user1``
    * Clique no botão ``Save``
    * Abra a aba ``Credentials`` e para os campos ``New password`` e ``Password confirmation`` informe o valor ``redhat@123``
    * Altere o valor do campo ``Temporary`` para ``OFF``
    * Clique em ``Role Mappings``
        * Selecione todas as ``Available Roles`` e clique em ``Add selected``
1. Pare a execução do JBoss
1. Gere o arquivo ``myapp-realm.json`` através da execução do seguinte script:
```
./gerar --exportar-keycloak-realm
```
9. Aguarde o término da inicialização do JBoss. Quando isso ocorrer, pare-o
10. Verifique a existência (ou atualização) do arquivo ``myapp-realm.json`` dentro do diretório ``keycloak/myapp``

#### Destruição dos bancos de dados

Se for necessário remover os bancos de dados do BPMS e do KEYCLOAK, o seguinte comando pode ser executado:

```
./oracle drop-databases
```

#### Inicialização do JBoss

Ajuste o valor da variável JBOSS_HOME para a localização do JBoss gerado. Em seguida, inicie o JBoss:
```
$JBOSS_HOME/bin/standalone.sh
```

Acesse a interface administrativa do JBoss em http://localhost:9990. O "usuário/senha" pré-configurado para esse acesso é "admin/redhat@123".

A interface de administração do Keycloak pode ser acessada através da URL http://localhost:8080/auth. Será solicitado um "usuário/senha" que, por padrão, é "admin/admin".

O Business Central pode ser acesado através da URL http://localhost:8080/business-central. Usuário/senha: user1/redhat@123

O Dashbuilder pode ser acessado através da URL http://localhost:8080/dashbuilder. Usuário/senha: user1/redhat@123

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

### Remoção do ambiente

Remover o ambiente é, no contexto deste projeto, excluir arquivos e diretórios gerados. Isso inclui os seguintes:
* jboss-eap-6.4.zip (arquivo)
* jboss-eap-6.4.remove.bat (arquivo)
* jboss-eap-6.4 (diretório)
* jboss-bpmsuite-6.1.1-patch (diretório)
* BZ-1234592-for-6.1.1 (diretório)

#### Remoção sem o uso do projeto javaee-ambiente

Execute:
```
./gerar -r -s
```

O parâmetro ``-r`` é para remover os arquivos. O parâmetro ``-s`` é para forçar o término do script antes do início da geração de quaisquer arquivos.

#### Remoção utilizando o projeto javaee-ambiente

```
jboss_remover
```

## Geração e uso do ambiente de homologação

Em ambiente de homologação, o JBoss BPM Suite é instalado em modo domain. São utilizados três hosts, um master e dois slaves.

TODO

## Problemas atuais

### 01) Erro ao tentar logar no business-central (http://localhost:8080/business-central)
* Status: resolvido no [commit 9e627d35b721f613e0d745e1cc5e213944d04905](https://github.com/paulojeronimo/gerador-jboss-bpmsuite-keycloak/commit/9e627d35b721f613e0d745e1cc5e213944d04905)
* Detalhamento:
    * Enquanto é possível o logon no dashbuilder, seguindo o mesmo roteiro de configuração realizado para o business-central, esse último gera um erro que impossibilita o usuário se logar na aplicação (é exibido um erro 403).
* Logs do servidor (a mesma saída, em dois momentos distintos de teste, regerando a instalação do JBoss e dos bancos de dados):
    * [01/a.log](problemas/01/a.log)
    * [01/b.log](problemas/01/b.log)


## Artigos úteis
* http://www.schabell.org/2015/04/docker-how-to-for-jboss-integration-bpm-projects.html

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
