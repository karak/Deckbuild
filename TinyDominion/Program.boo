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
		
	def Player.Draw(numberOfCards as int) as int:
		print "player ${_order} draw ${numberOfCards} cards"
		return numberOfCards
		
	Player.NextPlayer as Player:
		get:
			return StubGamePlayer(_order)
	
class StubGameFacade(GameFacade):
	_firstPlayer = StubGamePlayer(0)
	_actionPoint = ResourceCounter()
	
	GameFacade.TurnOwner as Player:
		get:
			return _firstPlayer
	
	GameFacade.ActionPoint as ResourceCounter:
		get:
			return _actionPoint


static def Build(gameFacade as GameFacade, cardDefinitionFilePath as string):
	config = Configure[of GameFacade, Card]()
	InjectSemantics(config)
	InjectGlossary(config)
	engine = config.Build(gameFacade, cardDefinitionFilePath)
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

