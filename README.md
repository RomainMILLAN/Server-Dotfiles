# server-dotfiles

Alias communs pour serveurs (Docker, listing, …).

## Guide d'installation

### 1. Créer le repository sur GitHub

```bash
cd ~/server_dotfiles
git init
git add -A
git commit -m "Initial: server aliases + one-line installer"
git branch -M main
git remote add origin git@github.com:RomainMILLAN/Server-s-Dotfiles.git
git push -u origin main
```

Le repo doit être **public** pour que l'installation par `curl` fonctionne.

### 2. Installer sur un serveur

```bash
curl -fsSL https://raw.githubusercontent.com/RomainMILLAN/Server-s-Dotfiles/main/install.sh | bash
source ~/.bashrc
```

### 3. Vérifier

```bash
alias
```

### 4. Mettre à jour

```bash
bash ~/.server-dotfiles/update.sh
```

L'update.sh :
- Compare la version locale avec la version distante
- Met à jour uniquement si des changements sont détectés
- Peut se mettre à jour lui-même

### 5. Désinstaller

```bash
rm -rf ~/.server-dotfiles
# Supprimer le bloc "# --- server-dotfiles ---" dans ~/.bashrc
```

## Alias inclus

| Catégorie | Alias | Description |
|-----------|-------|-------------|
| Listing | `ll`, `la`, `l` | Variantes de `ls` |
| Cat | `cat`, `more` | `bat`/`batcat` si dispo |
| Docker | `d`, `dps`, `dc`, `dcl`, `dclf`, `dce`, `dceit`, `dcr`, `dcrm`, `dip` | Commandes Docker courantes |
| Docker prune | `dspa`, `dnk`, `dka` | Nettoyage Docker interactif |
