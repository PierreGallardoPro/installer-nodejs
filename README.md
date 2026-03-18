# 📦 install_nodejs_trixie.sh

Script Bash d'installation automatisée de **Node.js** sur **Debian 13 Trixie**, via le dépôt officiel [NodeSource](https://github.com/nodesource/distributions).

---

## 🖥️ Compatibilité

| Système           | Support |
|-------------------|---------|
| Debian 13 Trixie  | ✅ Officiel |
| Debian 12 Bookworm | ⚠️ Compatible (avec avertissement) |
| Autres Debian/Linux | ⚠️ Peut fonctionner (confirmation demandée) |

> Le script détecte automatiquement l'OS via `/etc/os-release` et affiche un avertissement si Debian n'est pas détecté.

---

## 🚀 Versions disponibles

| Canal     | Version  | Nom de code | Usage recommandé  |
|-----------|----------|-------------|-------------------|
| **LTS**     | `24.x`   | Krypton     | Production ✅      |
| **Current** | `25.x`   | —           | Développement 🧪  |

---

## ⚙️ Prérequis

- Debian 13 Trixie (ou compatible)
- Droits **root** ou accès `sudo`
- Connexion internet active

---

## 📥 Installation

### 1. Cloner ou télécharger le script

```bash
# Via git
git clone <url-du-repo>
cd <dossier>

# Ou directement
wget https://<url>/install_nodejs_trixie.sh
```

### 2. Rendre le script exécutable

```bash
chmod +x install_nodejs_trixie.sh
```

### 3. Lancer l'installation

```bash
# Mode interactif — un menu vous propose de choisir la version
sudo ./install_nodejs_trixie.sh

# Installer directement la version LTS (24.x) — recommandée production
sudo ./install_nodejs_trixie.sh --lts

# Installer directement la version Current (25.x) — dernière version
sudo ./install_nodejs_trixie.sh --current
```

---

## 🔄 Déroulement du script

Le script effectue les étapes suivantes dans l'ordre :

1. **Vérification root** — s'assure que le script est exécuté avec les droits suffisants
2. **Détection de l'OS** — lit `/etc/os-release` et confirme Debian
3. **Sélection de version** — via argument CLI ou menu interactif
4. **Installation des dépendances** — `curl`, `gnupg`, `ca-certificates`, `apt-transport-https`, `lsb-release`
5. **Suppression de l'ancienne installation** — désinstalle `nodejs` et `npm` existants, et nettoie les anciens dépôts NodeSource
6. **Ajout du dépôt NodeSource** — import de la clé GPG + ajout de la source `apt`
7. **Installation de Node.js** — via `apt-get install nodejs`
8. **Vérification** — affiche les versions installées de `node` et `npm`

---

## ✅ Exemple de sortie

```
╔══════════════════════════════════════════════════════════╗
║        Installation de Node.js — Debian 13 Trixie        ║
╚══════════════════════════════════════════════════════════╝

  [OK]    Système détecté : Debian GNU/Linux 13 (trixie)
  [INFO]  Version sélectionnée : LTS (v24.x — Krypton, recommandée production)
  [OK]    Dépendances installées.
  [INFO]  Aucune installation existante détectée.
  [OK]    Dépôt NodeSource v24.x configuré.
  [OK]    Node.js installé avec succès.

  ━━━ Résultats ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✔  Node.js  : v24.14.0  (/usr/bin/node)
  ✔  npm      : v10.x.x   (/usr/bin/npm)
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [OK]    Installation terminée avec succès !

  Commandes utiles :
    node --version          # vérifier la version
    npm install -g yarn     # installer Yarn (optionnel)
    npm install -g pnpm     # installer pnpm (optionnel)
```

---

## 🛠️ Après l'installation

Vérifier les versions installées :

```bash
node --version
npm --version
```

Installer un gestionnaire de paquets alternatif (optionnel) :

```bash
npm install -g yarn   # Yarn
npm install -g pnpm   # pnpm
```

Mettre à jour Node.js ultérieurement :

```bash
sudo apt-get update && sudo apt-get upgrade nodejs
```

---

## 🗑️ Désinstallation

Pour supprimer Node.js et le dépôt NodeSource :

```bash
sudo apt-get remove -y nodejs npm
sudo apt-get autoremove -y
sudo rm -f /etc/apt/sources.list.d/nodesource.list
sudo rm -f /usr/share/keyrings/nodesource.gpg
sudo apt-get update
```

---

## 📄 Licence

Script libre d'utilisation et de modification. Aucune garantie implicite.

---

## 🔗 Références

- [NodeSource Distributions — GitHub](https://github.com/nodesource/distributions)
- [Node.js — Site officiel](https://nodejs.org)
- [Debian 13 Trixie](https://www.debian.org/releases/trixie/)