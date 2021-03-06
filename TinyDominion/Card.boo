namespace TinyDominion

import System


interface ICard:
	Id as string:
		get
	
	Cost as int:
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

class CurseCard(BaseCard):
	[Property(VictoryPoint)]
	private _victoyPoint as int
	
	def constructor(id as string):
		super(id)

	override def ToString():
		return "${super.ToString()}, victory point = ${_victoyPoint}"

class ActionCard(BaseCard):
	private final NoPlay = { return null }
	
	[Property(Play)]
	private _play as Func[of object] = NoPlay
	
	def constructor(id as string):
		super(id)
		
	override def ToString():
		if _play is null:
			playedString = "*uninitialized!*"
		else:
			playedString = "*initialized*"
		return "${super.ToString()}, play = ${playedString}"
