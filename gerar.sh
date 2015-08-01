#!/bin/bash
set +x

export PROJECT_HOME=`cd "$(dirname "$0")"; pwd`

CONFIG="$PROJECT_HOME"/gerar.config
[ -f "$CONFIG" ] || CONFIG=${CONFIG}.exemplo
source "$CONFIG"
source "$COMUM_DIR/funcoes.sh"

mostrar_cabecalho

while [ "$1" ]
do
    case "$1" in
        -a|--ambiente)
            shift
            case "$1" in
                desenvolvimento|homologacao) :;;
                *) echo "O amibente informado \"$1\" é inválido!"; exit;;
            esac
            export AMBIENTE=$1
            echo "Ambiente alterado (via linha de comando) para \"$AMBIENTE\""
            ;;
        -r|--remover) 
            remover_gerados
            ;;
        -s|--sair)
            exit
            ;;
    esac
    shift
done

d="$PROJECT_HOME/$AMBIENTE"
[ -d "$d" ] || { echo "O diretório \"$d\" não existe!"; exit 1; } 

script="$d"/funcoes.sh
[ -f "$script" ] || { echo "O arquivo de funções \"$script\" não está presente!"; exit 1; }
source "$script"

type gerar_${AMBIENTE} &> /dev/null || { echo "A função gerar_${AMBIENTE} não foi encontrada!"; exit 1; }
gerar_${AMBIENTE}
