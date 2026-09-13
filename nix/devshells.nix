# Development shells for Meshtastic Android
{
  perSystem =
    {
      config,
      lib,
      pkgs,
      system,
      ...
    }:
    let
      ANDROID_BUILD_TOOL_VERSION = "36.0.0";
      ANDROID_PLATFORM_VERSION = "37.0";
      ANDROID_MIN_SDK = "26";

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ ANDROID_PLATFORM_VERSION ];
        buildToolsVersions = [ ANDROID_BUILD_TOOL_VERSION ];
        cmdLineToolsVersion = "12.0";
        includeEmulator = false;
        includeNDK = false;
        includeSystemImages = false;
      };
      androidSdk = androidComposition.androidsdk;

      ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
      ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

      # Helper scripts for common tasks
      BuildApkScript = pkgs.writeShellScriptBin "build-apk" (builtins.readFile ./scripts/build-apk.sh);
      ValidateScript = pkgs.writeShellScriptBin "validate" (builtins.readFile ./scripts/validate.sh);
      InstallApkScript = pkgs.writeShellScriptBin "install-apk" (builtins.readFile ./scripts/install-apk.sh);
    in
    {
      devShells = {
        default = config.devShells.android;

        android = pkgs.myMkShell {
          name = "default";
          shellHook = ''
          export DEVSHELL=default
          export JAVA_HOME="${pkgs.zulu25}"
          export PATH="$JAVA_HOME/bin:$PATH"
          _git_ps1() {
              git rev-parse --is-inside-work-tree &>/dev/null || return
              local branch dirty
              branch=$(git symbolic-ref --short HEAD 2>/dev/null)
              [[ -n $(git status --porcelain) ]] && dirty='*'
              echo "<$branch$dirty>"
          }
            export PS1='\[\e[33m\][$DEVSHELL] \w $(_git_ps1) \$\[\e[0m\] '
            export PS4='\033[31m ⊙ \033[0m'
            echo -e '\033[33m## Meshtastic Android Development Environment \033[0m'
            echo -e '\033[33m## JAVA_HOME: $JAVA_HOME \033[0m'
            echo -e '\033[33m## ANDROID_HOME: ${ANDROID_HOME} \033[0m'
            echo -e '\033[33m## ANDROID_SDK_ROOT: ${ANDROID_SDK_ROOT} \033[0m'
            export PATH="${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOL_VERSION}:$PATH";
            echo ""
          '';

          inherit ANDROID_HOME ANDROID_SDK_ROOT;

          GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${ANDROID_BUILD_TOOL_VERSION}/aapt2";
          PATH = "${androidSdk}/libexec/android-sdk/build-tools/${ANDROID_BUILD_TOOL_VERSION}:$PATH";

          nativeBuildInputs = [
            pkgs.zulu25  # JDK 25 - required by the project
            pkgs.git
            pkgs.python3
            pkgs.gradle
            pkgs.android-tools  # adb and other Android tools
          ];

          myScripts = [
            BuildApkScript
            ValidateScript
            InstallApkScript
          ];

          # For Android Studio support (optional)
          buildInputs = [
            ((pkgs.android-studio.override { forceWayland = true; }).withSdk androidSdk)
          ];
        };
      };
    };
}
