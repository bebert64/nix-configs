{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.byDb.weakSwaylockPasswordHash;
in
{
  options.byDb.weakSwaylockPasswordHash = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      SHA-256 hex hash of a weak password that unlocks swaylock independently
      of the user's system password. When set, swaylock's PAM service is
      configured to accept ONLY this password (not the system password), so
      the user's system password can remain strong while the lock screen is
      easy to unlock in low-physical-risk environments.

      Generate with: echo -n "password" | sha256sum | awk '{print $1}'
    '';
  };

  config = lib.mkIf (cfg != null) (
    let
      # pam_exec with expose_authtok writes the password to stdin as raw
      # bytes with no trailing newline, so we must use `cat` (not `read`,
      # which returns non-zero at EOF without a newline).
      checkScript = pkgs.writeShellScript "swaylock-check-weak-password" ''
        set -u
        password=$(${pkgs.coreutils}/bin/cat)
        actual=$(printf '%s' "$password" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.gawk}/bin/awk '{print $1}')
        [ "$actual" = "${cfg}" ]
      '';
    in
    {
      security.pam.services.swaylock.text = ''
        auth required pam_exec.so expose_authtok quiet ${checkScript}
        account required pam_permit.so
      '';
    }
  );
}
