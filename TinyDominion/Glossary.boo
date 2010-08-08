namespace TinyDominion

import System
import Deckbuild.Framework


//// action injecting ////
def InjectGlossary[of CardT(class)](config as Configure[of GameFacade, CardT]):
	config.Glossary.Object("next_player",
		{ g as GameFacade| g.TurnOwner.NextPlayer }
	).Object("action",
		{ g as GameFacade| g.ActionPoint }
	).Object("card",
		{ g as GameFacade| CardDrawer(g.TurnOwner) }
	).Method("discard_all_hands",
		{ g as GameFacade, x | cast(Player, x).DiscardAllHands() }
	).Operator("+",
		{ g as GameFacade, lhs, rhs | cast(Increasible, lhs).Increase(rhs) }
	)
