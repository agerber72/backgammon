# Runs inside gnubg's embedded Python, started by update_engine_reference.ps1.
# Rates the best moves of reference positions, as a yardstick for the engine.
import json
import os

import gnubg

SOURCE = os.environ['GNUBG_POSITIONS']
TARGET = os.environ['GNUBG_REFERENCE']
EVERY = int(os.environ['GNUBG_EVERY'])
MAX_MOVES = 14
PLIES = 1


def load(entry):
    gnubg.command('new game')
    gnubg.command('set board ' + entry['id'])
    gnubg.command('set dice %d %d' % tuple(entry['dice']))


def rate(board):
    """Cubeless equity and win chance for the player on roll."""
    context = gnubg.evalcontext()
    context['plies'] = PLIES
    context['cubeful'] = 0
    result = gnubg.evaluate(board, gnubg.cubeinfo(), context)
    win, win_g, win_bg, lose_g, lose_bg = result[:5]
    return 2 * win - 1 + win_g + win_bg - lose_g - lose_bg, win


def rate_move(entry, move):
    load(entry)
    gnubg.command('move ' + move)
    equity, _ = rate(gnubg.board())
    return gnubg.positionid(gnubg.board()), -equity


for command in ('set automatic game off', 'set automatic roll off',
                'set automatic move off', 'set player 0 human',
                'set player 1 human'):
    gnubg.command(command)

with open(SOURCE) as source:
    entries = [e for e in json.load(source)[::EVERY] if len(e['expected']) >= 2]

results = []
for index, entry in enumerate(entries):
    load(entry)
    equity, win = rate(gnubg.board())
    moves = [item['move'] for item in gnubg.hint(MAX_MOVES)['hint']]
    rated = dict(rate_move(entry, move) for move in moves)
    entry = dict(entry)
    entry.pop('expected')
    entry['positionEquity'] = equity
    entry['positionWin'] = win
    entry['moves'] = rated
    results.append(entry)
    if index % 50 == 0:
        print('RESULT %d of %d' % (index, len(entries)))

with open(TARGET, 'w') as target:
    json.dump(results, target, separators=(',', ':'))
print('RESULT done %d' % len(results))
