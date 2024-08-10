#! /bin/sh

os() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo $NAME
  elif [ -d /system/app ] && [ -d /system/priv-app ]; then
    echo "Android $(getprop ro.build.version.release)"
  else
    echo "N/A"
  fi
}

kernel() {
  uname -rm
}

machine() {
  NAME=$(cat /sys/devices/virtual/dmi/id/product_name)
  VERSION=$(cat /sys/devices/virtual/dmi/id/product_version)
  MODEL=$(cat /sys/firmware/devicetree/base/model)
  if [ -n "$MODEL" ] || [ -n "$VERSION" ] || [ -n "$NAME" ]; then
    echo "$NAME $VERSION $MODEL"
  else
    echo "N/A"
  fi
}

up() {
  uptime -p
}

desktop() {
  for var in "XDG_CURRENT_DESKTOP" "DESKTOP_SESSION" "XDG_SESSION_DESKTOP" "CURRENT_DESKTOP" "SESSION_DESKTOP"; do
    DE=$(eval "echo \$$var")
    if [ -n "$DE" ]; then
      echo "$DE"
      return 0
    fi
  done
  echo "N/A"
}

shell() {
  if [ -n "$SHELL" ]; then
    echo "$SHELL"
  else
    echo "N/A"
  fi  
}

resolution() {
  if [ -f /usr/bin/xrandr ]; then
    RES="$(xrandr | awk '/\*/ {print $1}')"
    if [ -n "$RES" ]; then
      echo $RES
    else
      echo "N/A"
    fi
  else
    echo "N/A"
  fi
}

pkgs() {
  OUTPUT=""
  
  if [ -f /bin/dpkg ]; then
    DPKG="$(dpkg --get-selections | wc -l)"
    OUTPUT="${OUTPUT}dpkg($DPKG) "
  fi
  
  if [ -f /bin/flatpak ]; then
    FLATPAK="$(flatpak list | wc -l)"
    OUTPUT="${OUTPUT}flatpak($FLATPAK) "
  fi

  if [ -f /bin/pacman ]; then
    PACMAN="$(pacman -Qq | wc -l)"
    OUTPUT="${OUTPUT}pacman($PACMAN) "
  fi

  if [ -f /var/lib/rpm ]; then
    RPM="$(rpm -qa | wc -l)"
    OUTPUT="${OUTPUT}rpm($RPM) "
  fi

  if [ -f /bin/snap ]; then
    SNAP="$(snap list | wc -l)"
    OUTPUT="${OUTPUT}snap($SNAP) "
  fi

  if [ -f /bin/xbps-install ]; then
    XBPS="$(xbps-query -l | wc -l)"
    OUTPUT="${OUTPUT}xbps($XBPS) "
  fi

  if [ -f /bin/nix-store ]; then
    NIX="$(nix-store -q --requisites | wc -l)"
    OUTPUT="${OUTPUT}nix($NIX)"
  fi

  if [ -n "$OUTPUT" ]; then
    echo $OUTPUT
  else
    echo "N/A"
  fi
}

cpu() {
  CPU=$(awk -F ': ' '/model name/ {print $2}' /proc/cpuinfo | head -n1)
  if [ -n "$CPU" ]; then
    echo $CPU
  else
    echo "N/A"
  fi
}

gpu() {
  GPU=$(lspci | grep -E 'VGA|3D' | awk -F ': ' '{print $2}')
  if [ -n "$GPU" ]; then
    echo $GPU
  else
    echo "N/A"
  fi
}

mem() {
  TOTAL=$(grep "MemTotal:" /proc/meminfo | awk '{print $2}')
  FREE=$(grep "MemFree:" /proc/meminfo | awk '{print $2}')

  USED_MIB=$(( (TOTAL - FREE) / 1024 ))
  TOTAL_MIB=$(( TOTAL / 1024 ))

  PERCENT=$(( (USED_MIB * 100) / (TOTAL / 1024) ))

  echo "${USED_MIB}MiB of ${TOTAL_MIB}MiB ($PERCENT%)"
}

disk() {
  df -h / | awk 'NR==2 {printf "%.2fGiB of %.2fGiB (%s, /)\n", $3, $2, $5}'
}

log() {
  VAL=$(eval $2)
  if [ ! "$VAL" = "N/A" ]; then
    printf "$OPTIONS" "$1"; echo "$VAL"
  fi
}

main() {
  COLOR_KEY="94"
  COLOR_VALUE="97"
  COLOR_COLON="33"
  COLOR_IDENT="32"
  COLOR_AT="37"
  
  R=""
  OPTIONS_HEAD="%-12s %s@%s\n"
  OPTIONS="%-10s : "
  
  if [ "$1" = "color" ]; then 
    R="\033[0m"
    OPTIONS_HEAD="%-12s \033[${COLOR_IDENT}m%s$R\033[${COLOR_AT}m@$R\033[${COLOR_IDENT}m%s$R\n"
    OPTIONS="$R\033[${COLOR_KEY}m%-10s$R \033[${COLOR_COLON}m:$R\033[${COLOR_VALUE}m "
  fi
  
  HOSTNAME=${HOSTNAME:-${hostname:-$(hostname)}}
  USERNAME=${USER:-$(id -un)}
  if [ -f /proc/sys/kernel/hostname ]; then
    HOSTNAME=$(cat /proc/sys/kernel/hostname)
  elif [ -f /etc/hostname ]; then
    HOSTNAME=$(< /etc/hostname)
  fi
  printf "$OPTIONS_HEAD" "" ${USERNAME:-"user"} ${HOSTNAME:-"host"}
    
  log "Distro" "os"
  log "Kernel" "kernel"
  log "Machine" "machine"
  log "Uptime" "up"
  echo
  
  log "Desktop" "desktop"
  log "Shell" "shell"
  log "Resolution" "resolution"
  log "Packages" "pkgs"
  echo
  
  log "CPU" "cpu"
  log "GPU" "gpu"
  log "Memory" "mem"
  log "Disk" "disk"
  printf "$R"
}

main $1 2> /dev/null
