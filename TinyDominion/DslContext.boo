namespace TinyDominion

import System

interface IPredicateFactory:
	def CostIsAtMost(cost as int) as Predicate[of IFloatingCard]:
		pass

	#TODO:	
	#def IsTreasure() as Predicate[of IFloatingCard]:
	#	pass
	#
	#def Or(lhs as Predicate[of IFloatingCard], rhs as Predicate[of IFloatingCard]) as Predicate[of IFloatingCard]:
	#	pass

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
	[Getter(Them)]	//alias
	_prevResult as object
	
	def constructor(game as IGameFacade, predFactory as IPredicateFactory):
		_game = game
		_predFactory = predFactory
	
	def SelectACardFrom(source as ICardSource) as IFloatingCard:
		return You.SelectOne(source)
	
	def SelectATreasureCardFrom(source as ICardSource) as IFloatingCard:
		return You.SelectOneTreasure(source)
	
	def SelectAnyNumberOfCardsFrom(source as ICardSource) as (IFloatingCard):
		return You.SelectMany(source)
	
	def DiscardAllOf(objective as (IFloatingCard)) as (IFloatingCard):
		for o in objective:
			o.MoveTo(You.Discard)
		return objective
	
	def DrawCardsPer(n as int, objective as (IFloatingCard)) as (IFloatingCard):
		You.Draw(n * objective.Length)
		return objective
	
	def Trash(objective as IFloatingCard) as IFloatingCard:
		objective.MoveTo(_game.Trash)
		return objective
	
	def CostingUpTo(maxCost as int) as Predicate[of IFloatingCard]:
		return _predFactory.CostIsAtMost(maxCost)
		
	def CostingUpToMoreThan(plusCost as int, card as IFloatingCard) as Predicate[of IFloatingCard]:
		return _predFactory.CostIsAtMost(card.Card.Cost + plusCost)
		
	def GainACard(pred as System.Predicate[of IFloatingCard]) as IFloatingCard:
		return You.GainOne(pred)
	
	def GainATreasureCard(pred as System.Predicate[of IFloatingCard]) as IFloatingCard:
		return You.GainOneTreasure(pred)
	
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
	
	Buy as IIncreasible:
		get:
			return _game.BuyPoint
	
	Coins as IIncreasible:
		get:
			return _game.CoinPoint
