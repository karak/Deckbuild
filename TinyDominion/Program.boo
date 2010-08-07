namespace TinyDominion

import System
import Deckbuild.Framework

//// entry ////

class StubGamePlayer(Player):
	_order as int
	
	def constructor(order):
		_order = order
	
	def Player.DiscardAllHands():
		print "player ${_order} discard all hands"
		
	Player.NextPlayer as Player:
		get:
			return StubGamePlayer(_order)
	
class StubGameFacade(GameFacade):
	_firstPlayer = StubGamePlayer(0)
	
	GameFacade.TurnOwner as Player:
		get:
			return _firstPlayer


static def Build(gameFacade as GameFacade, cardDefinitionFilePath as string):
	config = Configure[of Card]()
	InjectSemantics(config)	
	engine = config.Build(gameFacade, cardDefinitionFilePath, MyGlossary())
	return engine

engine = Build(StubGameFacade(), "../../scripts/all.dbc")

print "#all cards"
for card in engine.Cards:
	print card

print "#play action"
for card in engine.Cards:
	actionCard = card as ActionCard
	if actionCard is not null:
		actionCard.Play()

Console.ReadKey()

