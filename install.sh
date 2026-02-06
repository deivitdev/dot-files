#!/bin/bash

# ==========================================
#  MEGA SCRIPT DE INSTALACIÓN (Estructura por carpetas)
#  Repositorio: https://github.com/deivitdev/dot-files
# ==========================================

REPO_URL="https://github.com/deivitdev/dot-files.git"
DOTFILES_DIR="$HOME/dot-files-temp"

echo "🚀 Iniciando el Mega Script de Setup..."

# 1. Instalar Homebrew (si falta)
if ! command -v brew &> /dev/null; then
    echo "🍺 Instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew ya está instalado."
fi

# 2. Instalar fuentes y paquetes core
echo "📦 Verificando herramientas esenciales..."

install_brew_pkg() {
    if brew list "$1" &>/dev/null; then
        echo "✅ $1 ya se encuentra instalado."
    else
        echo "📥 Instalando $1..."
        brew install "$1"
    fi
}

install_brew_cask() {
    if brew list --cask "$1" &>/dev/null; then
        echo "✅ $1 (cask) ya se encuentra instalado."
    else
        echo "📥 Instalando $1 (cask)..."
        brew install --cask "$1"
    fi
}

# Fuentes y Casks
brew tap homebrew/cask-fonts 2>/dev/null
install_brew_cask "font-jetbrains-mono-nerd-font"
install_brew_cask "wezterm"

# Herramientas CLI
tools=(tmux neovim git lazygit zoxide fzf ripgrep bat eza fd)
for tool in "${tools[@]}"; do
    install_brew_pkg "$tool"
done

# 3. Determinar la fuente de los dotfiles
if [ -d ".git" ] && git remote -v | grep -q "dot-files"; then
    DOTFILES_DIR=$(pwd)
    echo "🏠 Usando el directorio actual ($DOTFILES_DIR) como fuente."
    IS_TEMPORAL=false
else
    [ -d "$DOTFILES_DIR" ] && rm -rf "$DOTFILES_DIR"
    echo "⬇️  Clonando $REPO_URL..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    IS_TEMPORAL=true
fi

# 5. Función para mover y linkear configs (Sobreescritura total)
deploy_config() {
    local src_folder=$1
    local target_path=$2
    local is_file=$3
    local filename=$4

    echo "🔗 Procesando $src_folder..."

    # Eliminar destino si ya existe para sobreescribir entero
    if [ -e "$target_path" ]; then
        rm -rf "$target_path"
    fi

    # Instalar desde el repo
    if [ -d "$DOTFILES_DIR/$src_folder" ]; then
        if [ "$is_file" = true ]; then
            # Buscar el archivo dentro de la carpeta
            if [ -f "$DOTFILES_DIR/$src_folder/$filename" ]; then
                cp "$DOTFILES_DIR/$src_folder/$filename" "$target_path"
            elif [ -f "$DOTFILES_DIR/$src_folder/.$filename" ]; then
                cp "$DOTFILES_DIR/$src_folder/.$filename" "$target_path"
            fi
        else
            # Copiar carpeta entera
            mkdir -p "$(dirname "$target_path")"
            cp -R "$DOTFILES_DIR/$src_folder" "$target_path"
        fi
        echo "✅ $src_folder instalado correctamente."
    else
        echo "⚠️  No se encontró la carpeta $src_folder en el repo."
    fi
}

# 6. Desplegar configuraciones específicas

# tmux -> ~/.tmux.conf
deploy_config "tmux" "$HOME/.tmux.conf" true "tmux.conf"

# nvim -> ~/.config/nvim (carpeta entera)
deploy_config "nvim" "$HOME/.config/nvim" false ""

# wezterm -> ~/.wezterm.lua (archivo en HOME)
deploy_config "wezterm" "$HOME/.wezterm.lua" true "wezterm.lua"

# 7. Finalizar con TPM
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "🔌 Instalando TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# 8. Limpiar archivos temporales (solo si se clonó)
if [ "$IS_TEMPORAL" = true ]; then
    echo "🧹 Limpiando archivos temporales..."
    rm -rf "$DOTFILES_DIR"
fi

# 9. Zsh integrations (Manteniendo lógica de agregado)
touch ~/.zshrc
grep -q "zoxide" ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

echo "=========================================="
echo "🎉 ¡CONFIGURACIÓN COMPLETADA!"
echo "1. Reinicia WezTerm."
echo "2. En tmux: Ctrl+a I (instalar plugins)."
echo "3. En nvim: espera a Lazy.nvim."
echo "=========================================="
