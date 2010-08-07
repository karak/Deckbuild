namespace TinyDominion

import System
import Deckbuild.Framework


//// action injecting ////
def InjectGlossary[of CardT(class)](config as Configure[of GameFacade, CardT]):
	config.Glossary.Object("next_player",
		{ g as GameFacade| g.TurnOwner.NextPlayer }
	).Method("discard_all_hands",
		{ g as GameFacade, x | cast(Player, x).DiscardAllHands() }
	)
