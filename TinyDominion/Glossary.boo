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
	[Property(It)]
	_prevResult as object
	
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

