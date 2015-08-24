# use GOPATH to determine project root
#DEIS_ROOT=${GOPATH?}/src/github.com/deis/deis

# the application under test
#DEIS_TEST_APP=${DEIS_TEST_APP:-example-dockerfile-go}

# SSH key name used for testing
#DEIS_TEST_AUTH_KEY=${DEIS_TEST_AUTH_KEY:-deis-test}

# SSH key used for deisctl tunneling
# DEIS_TEST_SSH_KEY=${DEIS_TEST_SSH_KEY:-~/.vagrant.d/insecure_private_key}

# domain used for wildcard DNS
# DEIS_TEST_DOMAIN=${DEIS_TEST_DOMAIN:-local3.deisapp.com}

# SSH tunnel used by deisctl
#DEISCTL_TUNNEL=${DEISCTL_TUNNEL?}

# set units used by deisctl
#DEISCTL_UNITS=${DEISCTL_UNITS?}

# ip address for docker containers to communicate in functional tests
#HOST_IPADDR=${HOST_IPADDR?}

# the registry used to host dev-release images
# must be accessible to local Docker engine and Deis cluster
#DEV_REGISTRY=${DEV_REGISTRY?}

# random 10-char (5-byte) hex string to identify a test run
DEIS_TEST_ID=${DEIS_TEST_ID:-$(openssl rand -hex 5)}
DEIS_TEST_ROOT="/tmp/deis/${DEIS_TEST_ID}"
DEIS_VARS_FILE="${DEIS_TEST_ROOT}/vars"

DEIS_BIN_DIR="${DEIS_TEST_ROOT}/bin"
DEISCLI_BIN="${DEIS_BIN_DIR}/deis"
DEISCTL_BIN="${DEIS_BIN_DIR}/deisctl"
DEISCTL_UNITS="${DEIS_TEST_ROOT}/units"
