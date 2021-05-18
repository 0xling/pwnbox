#!/usr/bin/python

import argparse
import json
import struct
import socket


def pack(num):
    return struct.pack('<I', num)


def main():
    parser = argparse.ArgumentParser('fake terminal that connects to outside world')
    parser.add_argument('-e', required=True, help='execute command in outside terminal')
    parser.add_argument('-p', '--port', type=int, help='port used outside')
    parser.add_argument('-s', '--server', help='host server')

    args = parser.parse_args()

    cmd = args.e
    port = args.port if not args.port is None else 15111
    server = args.server if not args.server is None else '127.0.0.1'

    msg = {
        'exec': cmd,
    }
    msg_json = json.dumps(msg)
    length = len(msg_json)
    protocol_msg = pack(length) + msg_json

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server, port))

    sock.sendall(protocol_msg)


if __name__ == '__main__':
    main()
