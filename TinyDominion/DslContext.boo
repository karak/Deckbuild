namespace TinyDominion

import System

interface IPredicateFactory:
	def CostIsAtMost(cost as int) as Predicate[of IFloatingCard]:
		pass
	

internal class CardDrawer(IIncreasible):
	_player as IPlayer
	
	def constructor(player as IPlayer):
		_player = player
	
	def Increase(plusCount as int) as void:
		_player.Draw(plusCount)


class DslContext(Deckbuild.Dsl.IFunctionContext):
	_game as IGameFacade
	_predFactory as IPredicateFactory
	
	[Property(It)]
	_prevResult as object
	
	def constructor(game as IGameFacade, predFactory as IPredicateFactory):
		_game = game
		_predFactory = predFactory
	
	def SelectACardFrom(source as ICardSource) as IFloatingCard:
		return You.SelectOne(source)
	
	def Trash(objective as IFloatingCard) as IFloatingCard:
		objective.MoveTo(_game.Trash)
		return objective
	
	def CostingUpToMoreThan(plusCost as int, card as IFloatingCard) as Predicate[of IFloatingCard]:
		return _predFactory.CostIsAtMost(card.Card.Cost + plusCost)
		
	def GainACard(pred as System.Predicate[of IFloatingCard]) as IFloatingCard:
		return You.GainOne(pred)
	
	You as IPlayer:
		get:
			return _game.TurnOwner
	
	YourHand as ICardSource:
		get:
			return You.Hand
	
	Actions as IIncreasible:
		get:
			return _game.ActionPoint
	
	Cards as IIncreasible:
		get:
			return CardDrawer(_game.TurnOwner)

