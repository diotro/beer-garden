APP_NAME="beer-garden"
APP_HOME="/opt/${APP_NAME}"

CONFIG_HOME="$APP_HOME/conf"
LOG_HOME="$APP_HOME/log"

BARTENDER_CONFIG="${CONFIG_HOME}/bartender-config"
BARTENDER_LOG_CONFIG="${CONFIG_HOME}/bartender-logging-config.json"
BARTENDER_LOG_FILE="$LOG_HOME/bartender.log"

BREW_VIEW_CONFIG="${CONFIG_HOME}/brew-view-config"
BREW_VIEW_LOG_CONFIG="${CONFIG_HOME}/brew-view-logging-config.json"
BREW_VIEW_LOG_FILE="$LOG_HOME/brew-view.log"

case "$1" in
    0)
        # This is an uninstallation
        # Remove the user
        /usr/sbin/userdel $APP_NAME
    ;;
    1)
        # This is an upgrade.
        # Generate logging configs if they don't exist
        if [ ! -f "$BARTENDER_LOG_CONFIG" ]; then
            "$APP_HOME/bin/generate_bartender_log_config" \
                --log-config-file "$BARTENDER_LOG_CONFIG" \
                --log-file "$BARTENDER_LOG_FILE" \
                --log-level "WARN"
        fi

        if [ ! -f "$BREW_VIEW_LOG_CONFIG" ]; then
            "$APP_HOME/bin/generate_brew_view_log_config" \
                --log-config-file "$BREW_VIEW_LOG_CONFIG" \
                --log-file "$BREW_VIEW_LOG_FILE" \
                --log-level "WARN"
        fi

        # Migrate config files if they exist, converting to yaml if they're json
        if [ -f "$BARTENDER_CONFIG.yaml" ]; then
            "$APP_HOME/bin/migrate_bartender_config" -c "$BARTENDER_CONFIG.yaml"
        elif [ -f "$BARTENDER_CONFIG.json" ]; then
            "$APP_HOME/bin/migrate_bartender_config" -c "$BARTENDER_CONFIG.json" -t "yaml"
        fi

        if [ -f "$BREW_VIEW_CONFIG.yaml" ]; then
            "$APP_HOME/bin/migrate_brew_view_config" -c "$BREW_VIEW_CONFIG.yaml"
        elif [ -f "$BREW_VIEW_CONFIG.json" ]; then
            "$APP_HOME/bin/migrate_brew_view_config" -c "$BREW_VIEW_CONFIG.json" -t "yaml"
        fi
    ;;
esac

# Remove the old sysV init script if it exists
if [ -f /etc/init.d/${APP_NAME} ]; then
    rm -f /etc/init.d/${APP_NAME}
fi

# And reload units
systemctl daemon-reload
