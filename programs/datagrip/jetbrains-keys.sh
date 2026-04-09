#!/usr/bin/env bash
set -euo pipefail

export PATH="@jetbrains_keys_bin_path@:$PATH"

PRODUCT_CODE="${1-}"
if [ -z "$PRODUCT_CODE" ]; then
	xdg-open "@ja_netfilter_base_url@"
else
	ACTIVATION_OUTPUT_FILE="${2-}"
	if [ -n "$ACTIVATION_OUTPUT_FILE" ]; then echo "Product code: $PRODUCT_CODE"; fi
	ACTIVATION_CODE=$(jq -r ".$PRODUCT_CODE.[]" "@out@/jetbrains-keys.json")
	if [ -z "$ACTIVATION_OUTPUT_FILE" ]; then
		echo "$ACTIVATION_CODE"
		xclip -selection clipboard <<< "$ACTIVATION_CODE"
	else
		SMART_INSTALLATION_APPDATA_DIR_WITHOUT_VERSION="${3-}"
		if [ ! -d "$(dirname "$ACTIVATION_OUTPUT_FILE")" ] && [ -n "$SMART_INSTALLATION_APPDATA_DIR_WITHOUT_VERSION" ]; then
			# If there is already an existing installation, creating the folder will prevent it from copying settings
			# From one version to another. In that case we should instead "activate" the previous version, so that copy
			# preserves activation.
			APPDATA_DIR=$(dirname "$SMART_INSTALLATION_APPDATA_DIR_WITHOUT_VERSION")
			if [ "$APPDATA_DIR" != "$HOME/.config/JetBrains" ]; then
				echo "jetbrains-keys: Jetbrains dir prefix should be in .config/JetBrains"
				exit 1
			fi
			if [ -d "$APPDATA_DIR" ]; then
				PRODUCT_DATA_DIR_PREFIX=$(basename "$SMART_INSTALLATION_APPDATA_DIR_WITHOUT_VERSION")
				# shellcheck disable=SC2010 # We are using ls for sorting by date so we allow ls|grep
				LAST_UPDATED_DIR=$(ls -t1 "$APPDATA_DIR" | grep "^$PRODUCT_DATA_DIR_PREFIX" | head -n 1)
				if [ -n "$LAST_UPDATED_DIR" ]; then
					ACTIVATION_OUTPUT_FILE="$APPDATA_DIR/$LAST_UPDATED_DIR/$(basename "$ACTIVATION_OUTPUT_FILE")"
				fi
			fi
			
		fi
		mkdir -p "$(dirname "$ACTIVATION_OUTPUT_FILE")"
		(printf "\xff\xff" && (printf "<certificate-key>\n%s" "$ACTIVATION_CODE" | iconv --from-code UTF-8 --to-code UCS2)) > "$ACTIVATION_OUTPUT_FILE"
	fi
fi
