namespace TinyDominion

import System

interface IIncreasible:
	def Increase(plusCount as int) as void:
		pass

class ResourceCounter(IIncreasible):
	private _count as int
	
	def constructor():
		_count = 0
	
	def constructor(count as int):
		_count = count
	
	def Increase(plusCount as int) as void:
		old = _count
		_count += plusCount
		print "count up to ${_count} from ${old}" 	
	
	override def ToString():
		return _count.ToString()
		
	
//// game direction ////
interface IGameFacade:
	TurnOwner as IPlayer:
		get:
			pass
	ActionPoint as ResourceCounter:
		get:
			pass

class CardDrawer(IIncreasible):
	_player as IPlayer
	
	def constructor(player as IPlayer):
		_player = player
	
	def Increase(plusCount as int) as void:
		_player.Draw(plusCount)

interface IPlayer:
	def DiscardAllHands():
		pass
	
	def Draw(numberOfCards as int) as int:
		pass
	
	NextPlayer as IPlayer:
		get:
			pass
