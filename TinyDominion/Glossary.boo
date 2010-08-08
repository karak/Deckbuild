namespace TinyDominion

import System
import Deckbuild.Framework


//// action injecting ////
def InjectGlossary[of CardT(class)](config as Configure[of IGameFacade, CardT]):
	config.Glossary.Variable("next_player",
		{ g as IGameFacade| g.TurnOwner.NextPlayer }
	).Variable("action",
		{ g as IGameFacade| g.ActionPoint }
	).Variable("card",
		{ g as IGameFacade| CardDrawer(g.TurnOwner) }
	).Method("discard_all_hands",
		{ g as IGameFacade, x | cast(IPlayer, x).DiscardAllHands() }
	).Operator("+",
		{ g as IGameFacade, lhs, rhs | cast(IIncreasible, lhs).Increase(rhs) }
	)
