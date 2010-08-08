namespace TinyDominion

import System

interface Increasible:
	def Increase(plusCount as int) as void:
		pass

class ResourceCounter(Increasible):
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
interface GameFacade:
	TurnOwner as Player:
		get:
			pass
	ActionPoint as ResourceCounter:
		get:
			pass

class CardDrawer(Increasible):
	_player as Player
	
	def constructor(player as Player):
		_player = player
	
	def Increase(plusCount as int) as void:
		_player.Draw(plusCount)

interface Player:
	def DiscardAllHands():
		pass
	
	def Draw(numberOfCards as int) as int:
		pass
	
	NextPlayer as Player:
		get:
			pass
