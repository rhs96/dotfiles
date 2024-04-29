#!/bin/bash

# Função para exibir uma barra de carregamento
exibir_barra_carregamento() {
  local progresso=0
  local limite=100
  local delay=0.1

  while [ "$progresso" -le "$limite" ]; do
    printf '[Carregando: %d%%]\r' "$progresso"
    sleep "$delay"
    ((progresso++))
  done
  printf '\n'
}

# Função para instalar o Paru
instalar_paru() {
  if ! command -v paru &> /dev/null; then
    echo "Instalando o Paru..."
    cd "$HOME/Downloads" || exit
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
  else
    echo "O Paru já está instalado."
  fi
}

# Função para instalar programas do repositório oficial do Arch Linux
instalar_programas() {
  echo "Instalando programas do repositório oficial:"
  while IFS= read -r programa; do
    if pacman -Qs "$programa" &> /dev/null; then
      echo "Pacote '$programa' já está instalado. Pulando para o próximo pacote."
    else
      printf "Instalando: %s\n" "$programa"
      sudo -n pacman -Sy --noconfirm "$programa"
      echo "Dependências de '$programa':"
      sudo -n pacman -Qi "$programa" | awk '/Depends On/{gsub(/[<>]/,"",$4); print $4}' | tr '\n' ' '
      echo
    fi
  done < apps.txt
}

# Função para instalar programas AUR
instalar_programas_aur() {
  if command -v paru &> /dev/null; then
    echo "Instalando programas AUR:"
    while IFS= read -r programa; do
      if pacman -Qs "$programa" &> /dev/null || paru -Qs "$programa" &> /dev/null; then
        echo "Pacote '$programa' já está instalado. Pulando para o próximo pacote."
      else
        printf "Instalando: %s\n" "$programa"
        sudo -n paru -Sy --noconfirm "$programa"
        echo "Dependências de '$programa':"
        sudo -n paru -Qi "$programa" | awk '/Depends On/{gsub(/[<>]/,"",$4); print $4}' | tr '\n' ' '
        echo
      fi
    done < paru-apps.txt
  else
    echo "O Paru não está instalado. Não é possível instalar os programas AUR."
  fi
}

# Variável que recebe o path para a pasta .config/
CONFIG="$HOME/.config/"

# Função para mover arquivos (utilizando links simbólicos)
mover_arquivos() {
  echo "Movendo arquivos..."
  ln -sf "$CONFIG" "$HOME"
  ln -sf "$HOME/.bashrc" "$HOME"
}

# Função para verificar e instalar o microcódigo apropriado
verificar_e_instalar_ucode() {
  if [[ "$(lscpu | grep -i vendor)" =~ "genuineintel" ]]; then
    ucode_pkg="intel-ucode"
    vendor="Intel"
  elif [[ "$(lscpu | grep -i vendor)" =~ "authenticamd" ]]; then
    ucode_pkg="amd-ucode"
    vendor="AMD"
  else
    echo "Não foi possível determinar o tipo de processador."
    exit 1
  fi

  if pacman -Qs "$ucode_pkg" &> /dev/null; then
    echo "Microcódigo para $vendor já está instalado."
  else
    echo "Instalando microcódigo para $vendor..."
    sudo -n pacman -Sy --noconfirm "$ucode_pkg"
  fi
}

# Função para atualizar os repositórios e chaves (keyring) do sistema
atualizar_sistema() {
  echo "Atualizando repositórios e chaves (keyring) do sistema..."
  sudo -n pacman -Sy --noconfirm
  sudo -n pacman-key --refresh-keys
}

# Função de ajuda para exibir informações de uso
exibir_ajuda() {
  echo "Uso: $0 [opções]"
  echo "Opções:"
  echo "  -h, --help        Exibir esta mensagem de ajuda"
  echo "  -p, --paru        Instalar o Paru (necessário antes de instalar pacotes AUR)"
  echo "  -a, --aur         Instalar pacotes AUR (necessário ter instalado o Paru)"
  echo "  -m, --move        Mover arquivos .config e .bashrc"
  echo "  -u, --ucode       Verificar e instalar microcódigo apropriado"
  echo "  -r, --repo        Instalar programas do repositório oficial"
  echo "  -y, --yes         Executar todas as ações sem interação (modo automático)"
}

# Processar as opções da linha de comando
while getopts ":hpaymur" opcao; do
  case "$opcao" in
    h)
      exibir_ajuda
      exit 0
      ;;
    p)
      instalar_paru
      ;;
    a)
      instalar_programas_aur
      ;;
    m)
      mover_arquivos
      ;;
    u)
      verificar_e_instalar_ucode
      ;;
    r)
      instalar_programas
      ;;
    y)
      instalar_paru
      instalar_programas
      instalar_programas_aur
      mover_arquivos
      verificar_e_instalar_ucode
      exit 0
      ;;
    \?)
      echo "Opção inválida: -$OPTARG"
      exibir_ajuda
      exit 1
      ;;
  esac
done

# Se não houver opções, instalar apenas os programas do repositório oficial
if [[ $OPTIND -eq 1 ]]; then
  instalar_programas
fi
