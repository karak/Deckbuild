namespace TinyDominion

import System


class ResourceCounter:
	private _count as int
	
	def constructor():
		_count = 0
	
	def constructor(count as int):
		_count = count
	
	def Increase(plusCount as int):
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

interface Player:
	def DiscardAllHands():
		pass
	NextPlayer as Player:
		get:
			pass
