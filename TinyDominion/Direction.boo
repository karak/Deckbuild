namespace TinyDominion


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
