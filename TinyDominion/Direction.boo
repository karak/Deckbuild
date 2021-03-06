namespace TinyDominion

import System

interface IIncreasible:
	def Increase(plusCount as int) as void:
		pass

//// game direction ////
interface IGameFacade:
	TurnOwner as IPlayer:
		get:
			pass
	ActionPoint as IIncreasible:
		get:
			pass
	
	CoinPoint as IIncreasible:
		get:
			pass
	
	BuyPoint as IIncreasible:
		get:
			pass
	
	Trash as ICardSink:
		get:
			pass


interface IFloatingCard:
	Card as ICard:
		get
	
	def MoveTo(target as ICardSink):
		pass

interface ICardSource:
	pass

interface ICardSink:
	pass

interface ICardBag(ICardSource, ICardSink):
	pass

interface IPlayer:
	def Draw(numberOfCards as int) as int:
		pass
	
	def SelectOne(source as ICardSource) as IFloatingCard:
		pass
	
	def SelectOneTreasure(source as ICardSource) as IFloatingCard:
		pass
	
	#TODO: create SelectOne that recieves predicate
	#def SelectOne(source as ICardSource, pred as Predicate[of IFloatingCard]) as IFloatingCard:
	#	pass
	
	def SelectMany(source as ICardSource) as (IFloatingCard):
		pass
	
	def GainOne(pred as Predicate[of IFloatingCard]) as IFloatingCard:
		pass
	
	#TODO: integrate to gain one
	def GainOneTreasure(pred as Predicate[of IFloatingCard]) as IFloatingCard:
		pass
	
	Hand as ICardBag:
		get
	
	Discard as ICardSink:
		get