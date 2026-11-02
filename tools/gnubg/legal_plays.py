# Runs inside gnubg's embedded Python, started by update_reference.ps1.
# Adds to every position the positions GNU Backgammon reaches with a legal play.
import json
import os

import gnubg

SOURCE = os.environ['GNUBG_POSITIONS']
TARGET = os.environ['GNUBG_REFERENCE']
MAX_MOVES = 9999


def load(entry):
    gnubg.command('new game')
    gnubg.command('set board ' + entry['id'])
    gnubg.command('set dice %d %d' % tuple(entry['dice']))


def candidates(entry):
    load(entry)
    try:
        return [item['move'] for item in gnubg.hint(MAX_MOVES)['hint']]
    except Exception:
        # gnubg raises when there is no legal move to rank.
        return []


def result_of(entry, move):
    load(entry)
    gnubg.command('move ' + move)
    return gnubg.positionid(gnubg.board())


for command in ('set automatic game off', 'set automatic roll off',
                'set automatic move off', 'set player 0 human',
                'set player 1 human'):
    gnubg.command(command)

with open(SOURCE) as source:
    entries = json.load(source)

for index, entry in enumerate(entries):
    entry['expected'] = sorted({result_of(entry, move)
                                for move in candidates(entry)})
    if index % 50 == 0:
        print('RESULT %d of %d' % (index, len(entries)))

with open(TARGET, 'w') as target:
    json.dump(entries, target, separators=(',', ':'))
print('RESULT done %d' % len(entries))
