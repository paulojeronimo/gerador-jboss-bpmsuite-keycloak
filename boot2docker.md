# Utilizando o Boot2Docker neste projeto

## O que é o Boot2Docker?

Leia em http://boot2docker.io/

## Criação da VM

```
boot2docker init --memory=4096
```

## Destruição da VM

```
boot2docker destroy
```

## Inicialização da VM e configuração do shell para o uso do docker

```
boot2docker up
eval $(boot2docker shellinit)
echo $DOCKER_HOST
```

## Execução de um contêiner

```
docker run -it --rm jboss/base-jdk:8 env
```

## Configurando um redirecionamento da porta 1521 para acesso ao contêiner do Oracle XE

Se a ``boot2docker-vm`` já estiver em execução:
```
VBoxManage controlvm "boot2docker-vm" natpf1 "tcp-port1521,tcp,,1521,,1521";
```
Para configurar de maneira definitiva (modificando as configurações da ``boot2docker-vm`` com ela parada):
```
VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port1521,tcp,,1521,,1521";
```
Ref.: https://github.com/boot2docker/boot2docker/blob/master/doc/WORKAROUNDS.md#port-forwarding

