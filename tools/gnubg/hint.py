# Runs inside gnubg's embedded Python, started by hint.ps1.
# gnubg's `hint` stays at 0-ply in this build, so each candidate is played and
# the resulting position is re-evaluated by `evaluate`, which honours the depth.
import os

import gnubg

POSITION_ID = os.environ['GNUBG_POSITION_ID']
DIE_1 = os.environ['GNUBG_DIE_1']
DIE_2 = os.environ['GNUBG_DIE_2']
PLIES = int(os.environ['GNUBG_PLIES'])
MAX_MOVES = int(os.environ['GNUBG_MAX_MOVES'])


def load_position():
    gnubg.command('new game')
    gnubg.command('set board ' + POSITION_ID)
    gnubg.command('set dice %s %s' % (DIE_1, DIE_2))


def equity_after(move):
    """Cubeless equity for the player who makes `move`."""
    load_position()
    gnubg.command('move ' + move)
    context = gnubg.evalcontext()
    context['plies'] = PLIES
    context['cubeful'] = 0
    result = gnubg.evaluate(gnubg.board(), gnubg.cubeinfo(), context)
    win, win_g, win_bg, lose_g, lose_bg = result[:5]
    return -(2 * win - 1 + win_g + win_bg - lose_g - lose_bg), result[:5]


for command in ('set automatic game off', 'set automatic roll off',
                'set player 0 human', 'set player 1 human'):
    gnubg.command(command)

load_position()
candidates = [entry['move'] for entry in gnubg.hint(MAX_MOVES)['hint']]

rated = [(move,) + equity_after(move) for move in candidates]
rated.sort(key=lambda entry: entry[1], reverse=True)

best = rated[0][1]
print('RESULT plies=%d candidates=%d' % (PLIES, len(rated)))
for rank, (move, equity, probs) in enumerate(rated, 1):
    # Probabilities are from the opponent's view, so wins and losses swap.
    win, win_g, win_bg, lose_g, lose_bg = probs
    print('RESULT %2d. %-24s Eq %+.3f (%+.3f)  win %.3f g %.3f bg %.3f - loss %.3f g %.3f bg %.3f'
          % (rank, move, equity, equity - best, 1 - win, lose_g, lose_bg,
             win, win_g, win_bg))
