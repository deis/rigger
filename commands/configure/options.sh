# Generated by stubbs:add-option. Do not edit, if using stubbs.
# Created: Thu Oct 29 15:00:55 MDT 2015
#
#/ usage: rigger:configure [ --advanced] [ --provider <>] [ --version <>] 

# _rerun_options_parse_ - Parse the command arguments and set option variables.
#
#     rerun_options_parse "$@"
#
# Arguments:
#
# * the command options and their arguments
#
# Notes:
# 
# * Sets shell variables for any parsed options.
# * The "-?" help argument prints command usage and will exit 2.
# * Return 0 for successful option parse.
#
rerun_options_parse() {

    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case "$OPT" in
            --advanced) ADVANCED=true; [[ ${2:-} == true ]] && shift ;;
            --provider) rerun_option_check $# $1; PROVIDER=$2 ; shift ;;
            --version) rerun_option_check $# $1; VERSION=$2 ; shift ;;
            # help option
            -|--*?)
                rerun_option_usage
                exit 2
                ;;
            # end of options, just arguments left
            *)
              break
        esac
        shift
    done

    # Set defaultable options.
    [ -z "$ADVANCED" ] && ADVANCED="$(rerun_property_get $RERUN_MODULE_DIR/options/advanced DEFAULT)"
    # Check required options are set

    # If option variables are declared exportable, export them.
    export PROVIDER
    export VERSION
    #
    return 0
}


# If not already set, initialize the options variables to null.
: ${ADVANCED:=}
: ${PROVIDER:=}
: ${VERSION:=}


