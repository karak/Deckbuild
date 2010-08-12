namespace TinyDominion

import System
import Deckbuild.Framework

//// entry ////

final class StubGamePlayer(IPlayer):
	private _order as int
	
	def constructor(order):
		_order = order
	
	def IPlayer.DiscardAllHands():
		print "player ${_order} discard all hands"
		
	def IPlayer.Draw(numberOfCards as int) as int:
		print "player ${_order} draw ${numberOfCards} cards"
		return numberOfCards
		
	IPlayer.NextPlayer as IPlayer:
		get:
			return StubGamePlayer(_order + 1)
	
final class StubGameFacade(IGameFacade):
	private _firstPlayer = StubGamePlayer(0)
	private _actionPoint = ResourceCounter()
	
	IGameFacade.TurnOwner as IPlayer:
		get:
			return _firstPlayer
	
	IGameFacade.ActionPoint as ResourceCounter:
		get:
			return _actionPoint


static def Build(gameFacade as IGameFacade, cardDefinitionFilePath as string):
	config = Configure[of IGameFacade, ICard]({ StubContext() })
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

