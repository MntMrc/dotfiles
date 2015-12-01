# This script provides a command to cast your Ubuntu Phone to the desktop via
# SSH and wifi.
#
# Script made by Pietro Albini <pietro@pietroalbini.io>
# Released under the UNLICENSE license, aka public domain


cast-uphone () {

    # Option parsing thing
    show_help=false
    error=false
    fps=60
    next_fps=false
    args=( )
    for param in "$@"; do

        if "${next_fps}"; then
            fps="${param}"
            next_fps=false
            continue
        fi

        # Remove options from the arguments array
        if ! [[ "${param}" = -* ]]; then
            args+=( "${param}" )
            continue
        fi

        # -h or --help
        if [[ "${param}" = "-h" ]] || [[ "${param}" = "--help" ]]; then
            show_help=true
        # -f or --fps
        elif [[ "${param}" = "-f" ]] || [[ "${param}" = "--fps" ]]; then
            next_fps=true
        else
            error=true
        fi

    done

    # Usage and help messages
    if [[ "${#args[@]}" -ne 3 ]] || "${show_help}" || "${error}"; then
        echo "Usage: cast-uphone [-h] [-f fps] [user@]phone-ip" \
             "<resolution x> <resolution y>"
        echo "Cast an Ubuntu Phone to your computer"

        if "${show_help}"; then
            echo
            echo "Options:"
            echo " -h      --help     Show this message"
            echo " -f FPS  --fps FPS  Set the number of frames per second"
            echo
            echo "Example:"
            echo " cast-uphone phablet@192.168.1.110 270x480 -f 30"
        else
            echo
            echo "For more information: cast-uphone --help"
        fi

        if "${error}"; then
            return 1
        else
            return
        fi
    fi

    cap_interval=$(( 60 / fps ))
    real_fps=$(( fps - 60 % fps ))

    resx="${args[1]}"
    resy="${args[2]}"

    # Execute the real screencast
    ssh "${args[0]}" -- \
        mirscreencast -m /var/run/mir_socket --cap-interval "${cap_interval}" \
            --stdout -s "${resx}" "${resy}" \
            \| gzip -c \
        | gzip -dc \
        | mplayer -demuxer rawvideo -rawvideo \
            "fps=${fps}:w=${resx}:h=${resy}:format=rgba" -

}