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
		return _id;
		
private class TreasureCard(BaseCard):
	[Property(Coin)]
	_coin as int
	
	def constructor(id as string):
		super(id)

private class VictoryCard(BaseCard):
	[Property(VictoryPoint)]
	_victoyPoint as int
	
	def constructor(id as string):
		super(id)



//// entry ////

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
).End()

engine = config.Build("../../scripts/all.dbc")

for card in engine.Cards:
	print card

Console.ReadKey()

