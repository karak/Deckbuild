namespace TinyDominion

import System


//// action injecting ////
class StubCard(ICard):
	Id as string:
		get:
			return "StubCard"
			
	Cost as int:
		get:
			return 1

class StubFloatingCard(IFloatingCard):
	Card as ICard:
		get:
			return StubCard()


class StubCardSource(ICardSource):
	pass

class StubContext:
	_game as IGameFacade
	
	[Property(It)]
	_prevResult as object
	
	def constructor(game as IGameFacade):
		_game = game
	
	def SelectACardFrom(source as ICardSource) as IFloatingCard:
		print "stub card is selected"
		return StubFloatingCard()
	
	def Trash(objective as IFloatingCard) as IFloatingCard:
		print "trash ${objective.Card.Id}"
		return objective
	
	def CostingUpToMoreThan(plusCost as int, card as IFloatingCard) as Predicate[of IFloatingCard]:
		maxCost = card.Card.Cost + plusCost
		print "cost <= ${maxCost}"
		return { x as IFloatingCard | x.Card.Cost <= maxCost }
		
	def GainACard(pred as System.Predicate[of IFloatingCard]) as IFloatingCard:
		print "gain"
		return StubFloatingCard()
	
	YourHand as ICardSource:
		get:
			return StubCardSource()
	
	Action:
		get:
			return _game.ActionPoint
	
	Card:
		get:
			return CardDrawer(_game.TurnOwner)

	NextPlayer:
		get:
			return _game.TurnOwner.NextPlayer
