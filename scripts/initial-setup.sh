#! /usr/bin/env bash

set -euo pipefail

print_help() {
    echo "Usage: $0 [HOST] [ADMINPWD]"
    echo
    echo "Examples:"
    echo
    echo "  Initialize the database at localhost:8080 with db password 'PASSWORD':"
    echo "  $0"
    echo
    echo "  Initialize database on different host with db password 'notforprod':"
    echo "  $0 example.com notforprod"
}

if [[ "$*" =~ (-h|--help) ]]; then
    print_help
    exit 0
fi

if ! command -v jq; then
    echo "Please install \`jq' (https://stedolan.github.io/jq/) first!"
    echo
    echo "On Debian/Ubuntu this can be done by running \`apt-get install jq'."
fi

HOST="${1:-localhost:8080}"
PASSWORD="${2:-PASSWORD}"

create_db() {
    [ -z "$1" ] && { echo "Missing database arg!"; return 1; }

    result="$(curl -X PUT -u admin:"$PASSWORD" http://"$HOST"/db/"$1" ${2:+-d "$2"} 2>/dev/null)"
    if [ "$(jq '.ok' <<< "$result")" = "true" ]; then
        echo "Successfully created database $1..."
        return 0
    fi

    echo "Failed to create database $1 ($(jq '.error' <<< "$result"))"
    return 1
}

# Create system databases for couchdb
create_db _users
create_db _replicator
create_db _global_changes

# Create app database
create_db app
create_db app/_security \
  '{"admins": { "names": [], "roles": [] }, "members": { "names": [], "roles": ["user_app"] } }'
