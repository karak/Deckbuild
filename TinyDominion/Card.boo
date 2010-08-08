namespace TinyDominion

import System


interface ICard:
	Id as string:
		get

class BaseCard(ICard):
	[Getter(Id)]
	private _id as string
	
	[Property(Cost)]
	private _cost as int
	
	def constructor(id as string):
		_id = id
		_cost = 0
	
	override def ToString():
		return "${_id}: cost = ${_cost}";
		
class TreasureCard(BaseCard):
	[Property(Coin)]
	private _coin as int
	
	def constructor(id as string):
		super(id)
	
	override def ToString():
		return "${super.ToString()}, coin = ${_coin}"

class VictoryCard(BaseCard):
	[Property(VictoryPoint)]
	private _victoyPoint as int
	
	def constructor(id as string):
		super(id)

	override def ToString():
		return "${super.ToString()}, victory point = ${_victoyPoint}"

class ActionCard(BaseCard):
	[Property(Played)]
	private _played as Action
	
	def constructor(id as string):
		super(id)
		
	override def ToString():
		if _played is null:
			playedString = "*uninitialized!*"
		else:
			playedString = "*initialized*"
		return "${super.ToString()}, played = ${playedString}"
	
	def Play():
		print "now ${Id} is played =>"
		_played()
	