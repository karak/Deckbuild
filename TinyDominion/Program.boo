namespace TinyDominion

import System
import Deckbuild.Framework

interface Card:
	Id as string:
		get

private class BaseCard(Card):
	[Getter(Id)]
	_id as string
	
	[Property(Cost)]
	_cost as int
	
	def constructor(id as string):
		_id = id
		_cost = 0
	
	override def ToString():
		return "${_id}: cost = ${_cost}";
		
private class TreasureCard(BaseCard):
	[Property(Coin)]
	_coin as int
	
	def constructor(id as string):
		super(id)
	
	override def ToString():
		return "${super.ToString()}, coin = ${_coin}"

private class VictoryCard(BaseCard):
	[Property(VictoryPoint)]
	_victoyPoint as int
	
	def constructor(id as string):
		super(id)

	override def ToString():
		return "${super.ToString()}, victory point = ${_victoyPoint}"

private class ActionCard(BaseCard):
	[Property(Played)]
	_played as Action
	
	def constructor(id as string):
		super(id)
		
	override def ToString():
		if _played is null:
			playedString = "*uninitialized!*"
		else:
			playedString = "*initialized*"
		return "${super.ToString()}, played = ${playedString}"
	
	def Play():
		print "now ${_id} is played =>"
		_played()
	
//// game direction ////
interface GameFacade:
	TurnOwner as Player:
		get:
			pass

interface Player:
	def DiscardAllHands():
		pass
	NextPlayer as Player:
		get:
			pass

//// action injecting ////
class ObjectNotFound(Exception):
	def constructor(id as string):
		super("${id} is not found in object repository")

class MethodNotFound(Exception):
	def constructor(id as string):
		super("${id} is not found in method repository")

class MyGlossary(Deckbuild.Dsl.Glossary[of GameFacade]):
	def Object(id as string) as Deckbuild.Dsl.NiladicFunc[of GameFacade]:
		if id == "next_player":
			return do(g as GameFacade):
				return g.TurnOwner.NextPlayer
		else:
			raise ObjectNotFound(id)
		
	def Method(id as string) as Deckbuild.Dsl.MonadicFunc[of GameFacade]:
		if id == "discard_all_hands":
			return do(g as GameFacade, x):
				player as Player = x
				player.DiscardAllHands()
		else:
			raise MethodNotFound(id)
			

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

config = Configure[of Card]()

config.Semantics.Suite("Victory").To[of VictoryCard](
	{id as string | return cast(Card, VictoryCard(id))}
).Property("cost").To(
	{ card as VictoryCard, value as int | card.Cost = value }
).Property("victory_point").To(
	{ card as VictoryCard, value as int | card.VictoryPoint = value }
).End(
).Suite("Treasure").To[of TreasureCard](
	{ id as string | return cast(Card, TreasureCard(id))} 
).Property("cost").To(
	{ card as TreasureCard, value as int | card.Cost = value }
).Property("coin").To(
	{ card as TreasureCard, value as int | card.Coin = value }
).End(
).Suite("Action").To[of ActionCard](
	{ id as string | return ActionCard(id) } 
).Property("cost").To(
	{ card as ActionCard, value as int | card.Cost = value }
).Behavior("play").To(
	{ card as ActionCard, f as System.Action | card.Played = f }
).End()

engine = config.Build(StubGameFacade(), "../../scripts/all.dbc", MyGlossary())

print "#all cards"
for card in engine.Cards:
	print card

print "#play action"
for card in engine.Cards:
	actionCard = card as ActionCard
	if actionCard is not null:
		actionCard.Play()

Console.ReadKey()

