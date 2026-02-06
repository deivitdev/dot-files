#!/bin/bash

# ==========================================
#  SCRIPT DE INSTALACIÓN LOCAL
#  Instala dotfiles desde el directorio actual
# ==========================================

DOTFILES_DIR=$(pwd)

echo "🚀 Iniciando instalación local de dotfiles..."
echo "📁 Directorio fuente: $DOTFILES_DIR"

# Verificar que estamos en el directorio correcto
if [ ! -d "nvim" ] && [ ! -d "tmux" ] && [ ! -d "wezterm" ]; then
    echo "❌ Error: No se encontraron las carpetas de configuración (nvim, tmux, wezterm)"
    echo "   Asegúrate de ejecutar este script desde el directorio de dotfiles."
    exit 1
fi

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
install_brew_cask "font-jetbrains-mono-nerd-font"
install_brew_cask "wezterm"

# Herramientas CLI
tools=(tmux neovim git lazygit zoxide fzf ripgrep bat eza fd)
for tool in "${tools[@]}"; do
    install_brew_pkg "$tool"
done

# 3. Función para desplegar configuraciones
deploy_config() {
    local src_folder=$1
    local target_path=$2
    local is_file=$3
    local filename=$4

    echo "🔗 Procesando $src_folder..."

    # Eliminar destino si ya existe para sobreescribir
    if [ -e "$target_path" ]; then
        echo "   Eliminando configuración anterior..."
        rm -rf "$target_path"
    fi

    # Instalar desde el directorio local
    if [ -d "$DOTFILES_DIR/$src_folder" ]; then
        if [ "$is_file" = true ]; then
            # Buscar el archivo dentro de la carpeta
            if [ -f "$DOTFILES_DIR/$src_folder/$filename" ]; then
                cp "$DOTFILES_DIR/$src_folder/$filename" "$target_path"
                echo "✅ $filename copiado a $target_path"
            elif [ -f "$DOTFILES_DIR/$src_folder/.$filename" ]; then
                cp "$DOTFILES_DIR/$src_folder/.$filename" "$target_path"
                echo "✅ .$filename copiado a $target_path"
            else
                echo "⚠️  No se encontró el archivo $filename en $src_folder"
            fi
        else
            # Copiar carpeta entera
            mkdir -p "$(dirname "$target_path")"
            cp -R "$DOTFILES_DIR/$src_folder" "$target_path"
            echo "✅ $src_folder copiado a $target_path"
        fi
    else
        echo "⚠️  No se encontró la carpeta $src_folder en el directorio local."
    fi
}

# 4. Desplegar configuraciones específicas

echo ""
echo "📂 Desplegando configuraciones..."
echo ""

# tmux -> ~/.tmux.conf
deploy_config "tmux" "$HOME/.tmux.conf" true "tmux.conf"

# nvim -> ~/.config/nvim (carpeta entera)
deploy_config "nvim" "$HOME/.config/nvim" false ""

# wezterm -> ~/.wezterm.lua (archivo en HOME)
deploy_config "wezterm" "$HOME/.wezterm.lua" true "wezterm.lua"

# 5. Instalar TPM (Tmux Plugin Manager)
echo ""
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "🔌 Instalando TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "✅ TPM instalado"
else
    echo "✅ TPM ya está instalado"
fi

# 6. Configurar integraciones de Zsh
echo ""
echo "🐚 Configurando integraciones de Zsh..."
touch ~/.zshrc

if ! grep -q "zoxide" ~/.zshrc; then
    echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
    echo "✅ Zoxide agregado a ~/.zshrc"
else
    echo "✅ Zoxide ya está configurado"
fi

# 7. Mostrar resumen
echo ""
echo "=========================================="
echo "🎉 ¡INSTALACIÓN LOCAL COMPLETADA!"
echo ""
echo "📋 Próximos pasos:"
echo "   1. Reinicia WezTerm"
echo "   2. En tmux: presiona Ctrl+a I para instalar plugins"
echo "   3. Abre nvim y espera a que Lazy.nvim instale los plugins"
echo ""
echo "📁 Dotfiles instalados desde: $DOTFILES_DIR"
echo "=========================================="
