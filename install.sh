#!/bin/bash
# ==============================================================================
# INSTALL.SH - GitHub-basierter One-Liner Installer (mit Privat-Repo Support)
# Dieses Skript klont das Repository und startet das Haupt-Setup-Skript.
# ==============================================================================

set -e

REPO_URL="https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation.git" # BITTE AN IHR REPOSITORY ANPASSEN!
INSTALL_DIR="openclaw_ultimate_setup"
TTY_DEVICE="/dev/tty"
USER_WORKSPACE_DIR="${HOME}/.openclaw_ultimate_user_data"
SETUP_PREFERENCES_FILE="$USER_WORKSPACE_DIR/setup_preferences.conf"

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

SETUP_LANGUAGE="de"

create_repo_update_backup() {
    local repo_dir="$1"
    local backup_dir="$USER_WORKSPACE_DIR/repo_update_backups"
    local timestamp

    timestamp="$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    git -C "$repo_dir" status --porcelain > "$backup_dir/status_${timestamp}.txt" 2>/dev/null || true
    git -C "$repo_dir" diff > "$backup_dir/unstaged_${timestamp}.patch" 2>/dev/null || true
    git -C "$repo_dir" diff --cached > "$backup_dir/staged_${timestamp}.patch" 2>/dev/null || true
    git -C "$repo_dir" ls-files --others --exclude-standard > "$backup_dir/untracked_${timestamp}.txt" 2>/dev/null || true

    LAST_REPO_BACKUP_DIR="$backup_dir"
    LAST_REPO_BACKUP_TIMESTAMP="$timestamp"
}

perform_repo_hard_sync() {
    local repo_dir="$1"

    create_repo_update_backup "$repo_dir"
    git -C "$repo_dir" reset --hard origin/main
    git -C "$repo_dir" clean -fd
}

persist_setup_language() {
    mkdir -p "$USER_WORKSPACE_DIR"
    cat > "$SETUP_PREFERENCES_FILE" <<EOF
# Ausgelagerte Benutzer-Einstellungen für das Ultimate Setup
SETUP_LANGUAGE="$SETUP_LANGUAGE"
EOF
}

apply_install_language() {
    case "$SETUP_LANGUAGE" in
        en)
            TXT_INSTALLER_START="Starting the OpenClaw Ultimate Setup installation..."
            TXT_NO_TTY="Error: No interactive terminal found. Please start the script in a normal shell."
            TXT_GIT_NOT_INSTALLED="Git is not installed. Installing Git..."
            TXT_GIT_INSTALL_FAILED="Error: Git could not be installed. Please install it manually."
            TXT_PRIVATE_REPO_QUESTION="Is your GitHub repository private? (y/N): "
            TXT_PRIVATE_REPO_INFO="Private repositories require a GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="Guide: docs/PRIVATE_REPO_GUIDE.md in the cloned repository."
            TXT_PAT_PROMPT="Please enter your GitHub Personal Access Token: "
            TXT_PAT_MISSING="Error: No GitHub Personal Access Token entered. Installation aborted."
            TXT_EXISTING_DIR_UPDATE="Installation directory $INSTALL_DIR already exists. Updating repository..."
            TXT_LOCAL_CHANGES_DETECTED="Local changes were detected in the setup repository."
            TXT_LOCAL_CHANGES_EXPLANATION="That is why the normal update command does not switch to the latest setup version."
            TXT_LOCAL_CHANGES_QUESTION="Do you want to hard-sync the setup repository with origin/main now? (y/N): "
            TXT_LOCAL_CHANGES_WARNING="Only files inside the setup repository will be reset. Your external user workspace remains untouched."
            TXT_LOCAL_CHANGES_ABORTED="Repository update aborted because local changes were kept."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="The setup repository was hard-synced to origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="A backup of the repo changes was stored in:"
            TXT_REMOTE_MAIN_MISSING="Error: Remote branch origin/main was not found."
            TXT_CLONE_REPO="Cloning repository into $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="Installation completed. Please follow the instructions in the menu."
            ;;
        fr)
            TXT_INSTALLER_START="Démarrage de l'installation OpenClaw Ultimate Setup..."
            TXT_NO_TTY="Erreur : aucun terminal interactif trouvé. Veuillez lancer le script dans un shell normal."
            TXT_GIT_NOT_INSTALLED="Git n'est pas installé. Installation en cours..."
            TXT_GIT_INSTALL_FAILED="Erreur : Git n'a pas pu être installé. Veuillez l'installer manuellement."
            TXT_PRIVATE_REPO_QUESTION="Votre dépôt GitHub est-il privé ? (o/N) : "
            TXT_PRIVATE_REPO_INFO="Les dépôts privés nécessitent un GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="Guide : docs/PRIVATE_REPO_GUIDE.md dans le dépôt cloné."
            TXT_PAT_PROMPT="Veuillez saisir votre GitHub Personal Access Token : "
            TXT_PAT_MISSING="Erreur : aucun GitHub Personal Access Token saisi. Installation annulée."
            TXT_EXISTING_DIR_UPDATE="Le dossier d'installation $INSTALL_DIR existe déjà. Mise à jour du dépôt..."
            TXT_LOCAL_CHANGES_DETECTED="Des modifications locales ont été détectées dans le dépôt du setup."
            TXT_LOCAL_CHANGES_EXPLANATION="C'est pour cela que la commande de mise à jour normale ne bascule pas vers la version la plus récente."
            TXT_LOCAL_CHANGES_QUESTION="Voulez-vous synchroniser maintenant de force le dépôt du setup avec origin/main ? (o/N) : "
            TXT_LOCAL_CHANGES_WARNING="Seuls les fichiers du dépôt du setup seront réinitialisés. L'espace utilisateur externe reste intact."
            TXT_LOCAL_CHANGES_ABORTED="La mise à jour du dépôt a été annulée, car les modifications locales ont été conservées."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="Le dépôt du setup a été synchronisé de force avec origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="Une sauvegarde des modifications du dépôt a été enregistrée dans :"
            TXT_REMOTE_MAIN_MISSING="Erreur : la branche distante origin/main est introuvable."
            TXT_CLONE_REPO="Clonage du dépôt dans $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="Installation terminée. Veuillez suivre les instructions du menu."
            ;;
        zh)
            TXT_INSTALLER_START="正在启动 OpenClaw Ultimate Setup 安装..."
            TXT_NO_TTY="错误：未找到交互式终端。请在正常 shell 中启动该脚本。"
            TXT_GIT_NOT_INSTALLED="Git 未安装。正在安装 Git..."
            TXT_GIT_INSTALL_FAILED="错误：无法安装 Git。请手动安装。"
            TXT_PRIVATE_REPO_QUESTION="你的 GitHub 仓库是私有的吗？(y/N)："
            TXT_PRIVATE_REPO_INFO="私有仓库需要 GitHub Personal Access Token (PAT)。"
            TXT_PRIVATE_REPO_GUIDE="说明：请查看克隆仓库中的 docs/PRIVATE_REPO_GUIDE.md。"
            TXT_PAT_PROMPT="请输入你的 GitHub Personal Access Token："
            TXT_PAT_MISSING="错误：未输入 GitHub Personal Access Token。安装已中止。"
            TXT_EXISTING_DIR_UPDATE="安装目录 $INSTALL_DIR 已存在。正在更新仓库..."
            TXT_LOCAL_CHANGES_DETECTED="检测到 setup 仓库中存在本地更改。"
            TXT_LOCAL_CHANGES_EXPLANATION="这就是普通更新命令无法切换到最新 setup 版本的原因。"
            TXT_LOCAL_CHANGES_QUESTION="现在要将 setup 仓库强制同步到 origin/main 吗？(y/N)："
            TXT_LOCAL_CHANGES_WARNING="只有 setup 仓库中的文件会被重置，外部用户工作区不会受影响。"
            TXT_LOCAL_CHANGES_ABORTED="因为保留了本地更改，仓库更新已取消。"
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="setup 仓库已强制同步到 origin/main。"
            TXT_LOCAL_CHANGES_BACKUP_INFO="仓库更改的备份已保存到："
            TXT_REMOTE_MAIN_MISSING="错误：未找到远程分支 origin/main。"
            TXT_CLONE_REPO="正在将仓库克隆到 $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="安装完成。请按照菜单中的说明继续。"
            ;;
        ja)
            TXT_INSTALLER_START="OpenClaw Ultimate Setup のインストールを開始します..."
            TXT_NO_TTY="エラー：対話型ターミナルが見つかりません。通常のシェルでスクリプトを起動してください。"
            TXT_GIT_NOT_INSTALLED="Git がインストールされていません。Git をインストールします..."
            TXT_GIT_INSTALL_FAILED="エラー：Git をインストールできませんでした。手動でインストールしてください。"
            TXT_PRIVATE_REPO_QUESTION="GitHub リポジトリは非公開ですか？(y/N): "
            TXT_PRIVATE_REPO_INFO="非公開リポジトリには GitHub Personal Access Token (PAT) が必要です。"
            TXT_PRIVATE_REPO_GUIDE="ガイド：クローンしたリポジトリ内の docs/PRIVATE_REPO_GUIDE.md を参照してください。"
            TXT_PAT_PROMPT="GitHub Personal Access Token を入力してください: "
            TXT_PAT_MISSING="エラー：GitHub Personal Access Token が入力されていません。インストールを中止します。"
            TXT_EXISTING_DIR_UPDATE="インストールディレクトリ $INSTALL_DIR は既に存在します。リポジトリを更新します..."
            TXT_LOCAL_CHANGES_DETECTED="セットアップリポジトリにローカル変更が見つかりました。"
            TXT_LOCAL_CHANGES_EXPLANATION="そのため通常の更新コマンドでは最新のセットアップ版へ切り替わりません。"
            TXT_LOCAL_CHANGES_QUESTION="今すぐ setup リポジトリを origin/main と強制同期しますか？(y/N): "
            TXT_LOCAL_CHANGES_WARNING="リセットされるのは setup リポジトリ内のファイルだけです。外部のユーザーワークスペースはそのまま残ります。"
            TXT_LOCAL_CHANGES_ABORTED="ローカル変更を保持したため、リポジトリ更新を中止しました。"
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="setup リポジトリは origin/main に強制同期されました。"
            TXT_LOCAL_CHANGES_BACKUP_INFO="リポジトリ変更のバックアップ保存先:"
            TXT_REMOTE_MAIN_MISSING="エラー：リモートブランチ origin/main が見つかりません。"
            TXT_CLONE_REPO="リポジトリを $INSTALL_DIR にクローンしています..."
            TXT_INSTALLATION_FINISHED="インストールが完了しました。メニューの案内に従ってください。"
            ;;
        ru)
            TXT_INSTALLER_START="Запуск установки OpenClaw Ultimate Setup..."
            TXT_NO_TTY="Ошибка: интерактивный терминал не найден. Запустите скрипт в обычной оболочке."
            TXT_GIT_NOT_INSTALLED="Git не установлен. Устанавливаем Git..."
            TXT_GIT_INSTALL_FAILED="Ошибка: Git не удалось установить. Установите его вручную."
            TXT_PRIVATE_REPO_QUESTION="Ваш репозиторий GitHub приватный? (y/N): "
            TXT_PRIVATE_REPO_INFO="Для приватных репозиториев нужен GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="Инструкция: docs/PRIVATE_REPO_GUIDE.md в клонированном репозитории."
            TXT_PAT_PROMPT="Введите ваш GitHub Personal Access Token: "
            TXT_PAT_MISSING="Ошибка: GitHub Personal Access Token не введён. Установка прервана."
            TXT_EXISTING_DIR_UPDATE="Каталог установки $INSTALL_DIR уже существует. Обновляем репозиторий..."
            TXT_LOCAL_CHANGES_DETECTED="В репозитории setup обнаружены локальные изменения."
            TXT_LOCAL_CHANGES_EXPLANATION="Именно поэтому обычная команда обновления не переключается на самую новую версию setup."
            TXT_LOCAL_CHANGES_QUESTION="Выполнить сейчас жёсткую синхронизацию репозитория setup с origin/main? (y/N): "
            TXT_LOCAL_CHANGES_WARNING="Будут сброшены только файлы внутри репозитория setup. Внешнее пользовательское рабочее пространство не затрагивается."
            TXT_LOCAL_CHANGES_ABORTED="Обновление репозитория отменено, потому что локальные изменения были сохранены."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="Репозиторий setup жёстко синхронизирован с origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="Резервная копия изменений репозитория сохранена в:"
            TXT_REMOTE_MAIN_MISSING="Ошибка: удалённая ветка origin/main не найдена."
            TXT_CLONE_REPO="Клонируем репозиторий в $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="Установка завершена. Следуйте инструкциям в меню."
            ;;
        es)
            TXT_INSTALLER_START="Iniciando la instalación de OpenClaw Ultimate Setup..."
            TXT_NO_TTY="Error: no se encontró un terminal interactivo. Inicia el script en una shell normal."
            TXT_GIT_NOT_INSTALLED="Git no está instalado. Instalando Git..."
            TXT_GIT_INSTALL_FAILED="Error: no se pudo instalar Git. Instálalo manualmente."
            TXT_PRIVATE_REPO_QUESTION="¿Tu repositorio de GitHub es privado? (s/N): "
            TXT_PRIVATE_REPO_INFO="Los repositorios privados requieren un GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="Guía: docs/PRIVATE_REPO_GUIDE.md en el repositorio clonado."
            TXT_PAT_PROMPT="Introduce tu GitHub Personal Access Token: "
            TXT_PAT_MISSING="Error: no se introdujo ningún GitHub Personal Access Token. Instalación cancelada."
            TXT_EXISTING_DIR_UPDATE="El directorio de instalación $INSTALL_DIR ya existe. Actualizando el repositorio..."
            TXT_LOCAL_CHANGES_DETECTED="Se detectaron cambios locales en el repositorio del setup."
            TXT_LOCAL_CHANGES_EXPLANATION="Por eso el comando de actualización normal no cambia a la versión más reciente del setup."
            TXT_LOCAL_CHANGES_QUESTION="¿Quieres sincronizar ahora a la fuerza el repositorio del setup con origin/main? (s/N): "
            TXT_LOCAL_CHANGES_WARNING="Solo se restablecerán los archivos dentro del repositorio del setup. Tu espacio de usuario externo no se tocará."
            TXT_LOCAL_CHANGES_ABORTED="La actualización del repositorio se canceló porque se conservaron los cambios locales."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="El repositorio del setup se sincronizó a la fuerza con origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="Se guardó una copia de seguridad de los cambios del repositorio en:"
            TXT_REMOTE_MAIN_MISSING="Error: no se encontró la rama remota origin/main."
            TXT_CLONE_REPO="Clonando el repositorio en $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="La instalación ha finalizado. Sigue las instrucciones del menú."
            ;;
        eo)
            TXT_INSTALLER_START="Lanĉante la instaladon de OpenClaw Ultimate Setup..."
            TXT_NO_TTY="Eraro: neniu interaga terminalo trovita. Bonvolu lanĉi la skripton en normala ŝelo."
            TXT_GIT_NOT_INSTALLED="Git ne estas instalita. Instalante Git..."
            TXT_GIT_INSTALL_FAILED="Eraro: Git ne povis esti instalita. Bonvolu instali ĝin permane."
            TXT_PRIVATE_REPO_QUESTION="Ĉu via GitHub-deponejo estas privata? (j/N): "
            TXT_PRIVATE_REPO_INFO="Privataj deponejoj bezonas GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="Gvidilo: docs/PRIVATE_REPO_GUIDE.md en la klonita deponejo."
            TXT_PAT_PROMPT="Bonvolu entajpi vian GitHub Personal Access Token: "
            TXT_PAT_MISSING="Eraro: neniu GitHub Personal Access Token estis entajpita. Instalado nuligita."
            TXT_EXISTING_DIR_UPDATE="La instaldosierujo $INSTALL_DIR jam ekzistas. Ĝisdatigante la deponejon..."
            TXT_LOCAL_CHANGES_DETECTED="Lokaj ŝanĝoj estis detektitaj en la setup-deponejo."
            TXT_LOCAL_CHANGES_EXPLANATION="Pro tio la normala ĝisdatiga komando ne ŝanĝas al la plej nova setup-versio."
            TXT_LOCAL_CHANGES_QUESTION="Ĉu vi volas nun forte sinkronigi la setup-deponejon kun origin/main? (j/N): "
            TXT_LOCAL_CHANGES_WARNING="Nur dosieroj ene de la setup-deponejo estos resetitaj. Via ekstera uzanta laborejo restos netuŝita."
            TXT_LOCAL_CHANGES_ABORTED="La deponeja ĝisdatigo estis nuligita, ĉar la lokaj ŝanĝoj estis konservitaj."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="La setup-deponejo estis forte sinkronigita kun origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="Sekurkopio de la deponejaj ŝanĝoj estis konservita en:"
            TXT_REMOTE_MAIN_MISSING="Eraro: fora branĉo origin/main ne estis trovita."
            TXT_CLONE_REPO="Klonante la deponejon en $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="La instalado finiĝis. Bonvolu sekvi la instrukciojn en la menuo."
            ;;
        ar)
            TXT_INSTALLER_START="بدء تثبيت OpenClaw Ultimate Setup..."
            TXT_NO_TTY="خطأ: لم يتم العثور على طرفية تفاعلية. يرجى تشغيل السكربت في shell عادي."
            TXT_GIT_NOT_INSTALLED="Git غير مثبت. جارٍ تثبيت Git..."
            TXT_GIT_INSTALL_FAILED="خطأ: تعذر تثبيت Git. يرجى تثبيته يدوياً."
            TXT_PRIVATE_REPO_QUESTION="هل مستودع GitHub الخاص بك خاص؟ (y/N): "
            TXT_PRIVATE_REPO_INFO="تحتاج المستودعات الخاصة إلى GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="الدليل: docs/PRIVATE_REPO_GUIDE.md داخل المستودع المستنسخ."
            TXT_PAT_PROMPT="يرجى إدخال GitHub Personal Access Token الخاص بك: "
            TXT_PAT_MISSING="خطأ: لم يتم إدخال GitHub Personal Access Token. تم إيقاف التثبيت."
            TXT_EXISTING_DIR_UPDATE="دليل التثبيت $INSTALL_DIR موجود بالفعل. جارٍ تحديث المستودع..."
            TXT_LOCAL_CHANGES_DETECTED="تم اكتشاف تغييرات محلية داخل مستودع setup."
            TXT_LOCAL_CHANGES_EXPLANATION="ولهذا السبب لا ينتقل أمر التحديث العادي إلى أحدث إصدار من setup."
            TXT_LOCAL_CHANGES_QUESTION="هل تريد الآن إجراء مزامنة قسرية لمستودع setup مع origin/main؟ (y/N): "
            TXT_LOCAL_CHANGES_WARNING="سيتم إعادة ضبط الملفات داخل مستودع setup فقط. مساحة المستخدم الخارجية لن تتأثر."
            TXT_LOCAL_CHANGES_ABORTED="تم إلغاء تحديث المستودع لأن التغييرات المحلية تم الاحتفاظ بها."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="تمت مزامنة مستودع setup قسرياً مع origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="تم حفظ نسخة احتياطية من تغييرات المستودع في:"
            TXT_REMOTE_MAIN_MISSING="خطأ: لم يتم العثور على الفرع البعيد origin/main."
            TXT_CLONE_REPO="جارٍ استنساخ المستودع إلى $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="اكتمل التثبيت. يرجى متابعة التعليمات في القائمة."
            ;;
        he)
            TXT_INSTALLER_START="מפעיל את התקנת OpenClaw Ultimate Setup..."
            TXT_NO_TTY="שגיאה: לא נמצא טרמינל אינטראקטיבי. נא להפעיל את הסקריפט ב-shell רגיל."
            TXT_GIT_NOT_INSTALLED="Git אינו מותקן. מתקין את Git..."
            TXT_GIT_INSTALL_FAILED="שגיאה: לא ניתן היה להתקין את Git. נא להתקין ידנית."
            TXT_PRIVATE_REPO_QUESTION="האם מאגר ה-GitHub שלך פרטי? (y/N): "
            TXT_PRIVATE_REPO_INFO="מאגרים פרטיים דורשים GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="מדריך: docs/PRIVATE_REPO_GUIDE.md במאגר ששוכפל."
            TXT_PAT_PROMPT="נא להזין את GitHub Personal Access Token שלך: "
            TXT_PAT_MISSING="שגיאה: לא הוזן GitHub Personal Access Token. ההתקנה בוטלה."
            TXT_EXISTING_DIR_UPDATE="ספריית ההתקנה $INSTALL_DIR כבר קיימת. מעדכן את המאגר..."
            TXT_LOCAL_CHANGES_DETECTED="זוהו שינויים מקומיים במאגר ה-setup."
            TXT_LOCAL_CHANGES_EXPLANATION="לכן פקודת העדכון הרגילה לא עוברת לגרסת ה-setup החדשה ביותר."
            TXT_LOCAL_CHANGES_QUESTION="האם לבצע עכשיו סנכרון קשיח של מאגר ה-setup עם origin/main? (y/N): "
            TXT_LOCAL_CHANGES_WARNING="רק קבצים בתוך מאגר ה-setup יאופסו. מרחב המשתמש החיצוני שלך לא ייפגע."
            TXT_LOCAL_CHANGES_ABORTED="עדכון המאגר בוטל כי השינויים המקומיים נשמרו."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="מאגר ה-setup סונכרן בקשיחות עם origin/main."
            TXT_LOCAL_CHANGES_BACKUP_INFO="גיבוי של שינויי המאגר נשמר בנתיב:"
            TXT_REMOTE_MAIN_MISSING="שגיאה: הענף המרוחק origin/main לא נמצא."
            TXT_CLONE_REPO="משכפל את המאגר אל $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="ההתקנה הושלמה. נא לפעול לפי ההוראות שבתפריט."
            ;;
        *)
            TXT_INSTALLER_START="Starte die OpenClaw Ultimate Setup Installation..."
            TXT_NO_TTY="Fehler: Kein interaktives Terminal gefunden. Bitte starten Sie das Skript in einer normalen Shell."
            TXT_GIT_NOT_INSTALLED="Git ist nicht installiert. Installiere Git..."
            TXT_GIT_INSTALL_FAILED="Fehler: Git konnte nicht installiert werden. Bitte manuell installieren."
            TXT_PRIVATE_REPO_QUESTION="Ist Ihr GitHub-Repository privat? (j/N): "
            TXT_PRIVATE_REPO_INFO="Für private Repositories benötigen Sie ein GitHub Personal Access Token (PAT)."
            TXT_PRIVATE_REPO_GUIDE="Anleitung zur Erstellung: docs/PRIVATE_REPO_GUIDE.md im geklonten Repo."
            TXT_PAT_PROMPT="Bitte geben Sie Ihr GitHub Personal Access Token ein: "
            TXT_PAT_MISSING="Fehler: Kein GitHub Personal Access Token eingegeben. Installation abgebrochen."
            TXT_EXISTING_DIR_UPDATE="Installationsverzeichnis $INSTALL_DIR existiert bereits. Aktualisiere Repository..."
            TXT_LOCAL_CHANGES_DETECTED="Im Setup-Repository wurden lokale Änderungen erkannt."
            TXT_LOCAL_CHANGES_EXPLANATION="Genau deshalb wechselt der normale Update-Befehl nicht auf die neueste Setup-Version."
            TXT_LOCAL_CHANGES_QUESTION="Möchten Sie das Setup-Repository jetzt hart mit origin/main abgleichen? (j/N): "
            TXT_LOCAL_CHANGES_WARNING="Zurückgesetzt werden nur Dateien im Setup-Repository. Ihr ausgelagerter Benutzer-Workspace bleibt erhalten."
            TXT_LOCAL_CHANGES_ABORTED="Das Repository-Update wurde abgebrochen, weil die lokalen Änderungen beibehalten wurden."
            TXT_LOCAL_CHANGES_HARD_SYNC_DONE="Das Setup-Repository wurde hart auf origin/main abgeglichen."
            TXT_LOCAL_CHANGES_BACKUP_INFO="Eine Sicherung der Repo-Änderungen wurde hier abgelegt:"
            TXT_REMOTE_MAIN_MISSING="Fehler: Remote-Branch origin/main wurde nicht gefunden."
            TXT_CLONE_REPO="Klone Repository in $INSTALL_DIR..."
            TXT_INSTALLATION_FINISHED="Installation abgeschlossen. Bitte folgen Sie den Anweisungen im Menü."
            ;;
    esac
}

select_install_language() {
    local existing_language=""
    if [ -f "$SETUP_PREFERENCES_FILE" ]; then
        # shellcheck disable=SC1090
        source "$SETUP_PREFERENCES_FILE"
        existing_language="${SETUP_LANGUAGE:-}"
    fi

    case "$existing_language" in
        de|en|fr|zh|ja|ru|es|eo|ar|he)
            SETUP_LANGUAGE="$existing_language"
            ;;
        *)
            echo "Please choose the setup language / Bitte die Setup-Sprache wählen / Choisissez la langue / 请选择语言 / 言語を選択 / Выберите язык / Elija idioma:"
            echo "1) Deutsch"
            echo "2) English"
            echo "3) Français"
            echo "4) 中文"
            echo "5) 日本語"
            echo "6) Русский"
            echo "7) Español"
            echo "8) Esperanto"
            echo "9) العربية"
            echo "10) עברית"
            read -r -p "Auswahl / Choice [1]: " LANGUAGE_CHOICE < "$TTY_DEVICE"
            case "${LANGUAGE_CHOICE:-1}" in
                2) SETUP_LANGUAGE="en" ;;
                3) SETUP_LANGUAGE="fr" ;;
                4) SETUP_LANGUAGE="zh" ;;
                5) SETUP_LANGUAGE="ja" ;;
                6) SETUP_LANGUAGE="ru" ;;
                7) SETUP_LANGUAGE="es" ;;
                8) SETUP_LANGUAGE="eo" ;;
                9) SETUP_LANGUAGE="ar" ;;
                10) SETUP_LANGUAGE="he" ;;
                *) SETUP_LANGUAGE="de" ;;
            esac
            persist_setup_language
            ;;
    esac

    apply_install_language
}

if [ ! -e "$TTY_DEVICE" ]; then
    apply_install_language
    echo -e "${RED}${TXT_NO_TTY}${NC}"
    exit 1
fi

select_install_language

echo -e "${BLUE}${TXT_INSTALLER_START}${NC}"

# Prüfen, ob Git installiert ist
if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}${TXT_GIT_NOT_INSTALLED}${NC}"
    sudo apt update
    sudo apt install -y git
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}${TXT_GIT_INSTALL_FAILED}${NC}"
        exit 1
    fi
fi

# Abfrage für privates Repository
read -r -p "$TXT_PRIVATE_REPO_QUESTION" IS_PRIVATE_REPO < "$TTY_DEVICE"
IS_PRIVATE_REPO=${IS_PRIVATE_REPO:-N}

GIT_AUTH_URL="$REPO_URL"
if [[ "$IS_PRIVATE_REPO" =~ ^([jJyYsSoO])$ ]]; then
    echo -e "${YELLOW}${TXT_PRIVATE_REPO_INFO}${NC}"
    echo -e "${YELLOW}${TXT_PRIVATE_REPO_GUIDE}${NC}"
    read -r -s -p "$TXT_PAT_PROMPT" GITHUB_PAT < "$TTY_DEVICE"
    echo
    if [ -z "$GITHUB_PAT" ]; then
        echo -e "${RED}${TXT_PAT_MISSING}${NC}"
        exit 1
    fi
    # URL für Authentifizierung anpassen
    REPO_HOST=$(echo $REPO_URL | sed -e 's/^https:\/\///' -e 's/\.git$//')
    GIT_AUTH_URL="https://${GITHUB_PAT}@${REPO_HOST}.git"
fi

# Repository klonen
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}${TXT_EXISTING_DIR_UPDATE}${NC}"
    cd "$INSTALL_DIR"
    git fetch origin --prune
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        if git symbolic-ref --quiet HEAD >/dev/null 2>&1; then
            CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
            if [ "$CURRENT_BRANCH" != "main" ]; then
                git checkout main 2>/dev/null || git checkout -b main --track origin/main
            fi
        else
            git checkout -B main origin/main
        fi
        REPO_STATUS="$(git status --porcelain)"
        if [ -n "$REPO_STATUS" ]; then
            echo -e "${YELLOW}${TXT_LOCAL_CHANGES_DETECTED}${NC}"
            echo -e "${YELLOW}${TXT_LOCAL_CHANGES_EXPLANATION}${NC}"
            echo -e "${YELLOW}${TXT_LOCAL_CHANGES_WARNING}${NC}"
            echo
            printf '%s\n' "$REPO_STATUS"
            echo
            read -r -p "$TXT_LOCAL_CHANGES_QUESTION" DO_HARD_SYNC < "$TTY_DEVICE"
            if [[ "$DO_HARD_SYNC" =~ ^([jJyYsSoO])$ ]]; then
                perform_repo_hard_sync "$PWD"
                echo -e "${GREEN}${TXT_LOCAL_CHANGES_HARD_SYNC_DONE}${NC}"
                echo -e "${YELLOW}${TXT_LOCAL_CHANGES_BACKUP_INFO}${NC} $LAST_REPO_BACKUP_DIR"
            else
                echo -e "${RED}${TXT_LOCAL_CHANGES_ABORTED}${NC}"
                exit 1
            fi
        else
            git pull --ff-only origin main
        fi
    else
        echo -e "${RED}${TXT_REMOTE_MAIN_MISSING}${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}${TXT_CLONE_REPO}${NC}"
    git clone "$GIT_AUTH_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Haupt-Setup-Skript ausführen
find . -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
bash ./setup_ultimate.sh < "$TTY_DEVICE" > "$TTY_DEVICE" 2>&1

echo -e "${GREEN}${TXT_INSTALLATION_FINISHED}${NC}"
