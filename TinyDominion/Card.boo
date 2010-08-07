namespace TinyDominion

import System


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
	