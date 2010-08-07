namespace TinyDominion

import System
import Deckbuild.Framework


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
			
