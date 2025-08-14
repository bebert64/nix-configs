selection=$(
	  cd /home/user/code/crates/ListCrateDirs
	  cargo run -- /home/user/code Cargo.toml 2>/dev/null | \
      sort -u | \
      rofi -sort -sorting-method fzf -disable-history -dmenu -show-icons -no-custom -p ""
    )
    if [[ $selection = "code" ]]; then
      code $HOME/code
	elif [[ $selection ]]; then
      code $HOME/code/$selection
    fi
