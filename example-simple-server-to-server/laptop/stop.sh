#!/bin/bash

PEER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
wg-quick down "$PEER_DIR"/wg0.conf
wg show
