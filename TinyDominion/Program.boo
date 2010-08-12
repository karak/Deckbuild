namespace TinyDominion

import System
import Deckbuild.Framework

//// entry ////
static def Build(gameFacade as IGameFacade, predFactory as IPredicateFactory, cardDefinitionFilePath as string):
	config = Configure[of ICard]( { Context(gameFacade, predFactory) })
	InjectSemantics(config)
	engine = config.Build(cardDefinitionFilePath)
	return engine
