#! /usr/bin/env python3

import argparse
from base64 import b64encode
from hashlib import pbkdf2_hmac
from http import client
from json import dumps, loads
from os import urandom
from sys import exit


def encrypt(string):
    salt = b64encode(urandom(16))

    return {
        'hash': pbkdf2_hmac('sha1', string.encode(), salt, 128, dklen=256/8).hex(),
        'salt': salt.decode('ascii'),
        'iterations': 128,

        # the JS implementation expects 256bits, but the JS
        # implementation expects the size in words (which is a custom
        # data structure consisting of 32-bit words)
        'keysize': 256 / 32
    }


def couchdb_put(path, data, credentials, host):
    serialized_data = dumps(data)
    authstr = b64encode(credentials.encode()).decode('ascii')
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f"Basic {authstr}"
    }

    req = client.HTTPConnection(host)
    req.request('PUT', f"/db/{path}", serialized_data, headers=headers)

    response = req.getresponse()

    if response.status >= 400:
        json_response = loads(response.read())
        if 'reason' in json_response:
            reason = json_response['reason']
        else:
            reason = response.reason

        print(f"Request to /db/{path} failed with the following error: {reason}")
        print("Aborting...")
        exit(1)

    print(f"OK: /db/{path}")


def main():
    parser = argparse.ArgumentParser('add-user')
    parser.add_argument('--database', default='app')
    parser.add_argument('user', help='Name of the user to add.')
    parser.add_argument('password', help='Name of the password to add.')
    parser.add_argument('--auth', default='admin:PASSWORD')
    parser.add_argument('--host', default='localhost')

    args = parser.parse_args()
    couchdb_put(
        f"_users/org.couchdb.user:{args.user}",
        {
            'name': args.user,
            'password': args.password,
            'roles': [f"user_{args.database}"],
            'type': 'user'
        },
        args.auth,
        args.host
    )

    couchdb_put(
        f"{args.database}/User:{args.user}",
        {
            '_id': f"User:{args.user}",
            'name': args.user,
            'password': encrypt(args.password)
        },
        args.auth,
        args.host
    )


if __name__ == '__main__':
    main()
