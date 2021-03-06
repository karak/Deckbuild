namespace TinyDominion

import Deckbuild.Framework
import Deckbuild.Dsl

class DslFactory(AbstractDslFactory[of ICard]):
	def constructor(gameFacade as IGameFacade, predFactory as IPredicateFactory):
		super({ DslContext(gameFacade, predFactory) })
		
	override def Configure(semantics as ISemanticBinder[of ICard], operators as IOperatorRepository):
		semantics.Suite("Victory").Callback = {id as string | return VictoryCard(id)}
		semantics.Suite("Treasure").Callback = { id as string | return TreasureCard(id)} 
		semantics.Suite("Curse").Callback = { id as string | return CurseCard(id)} 
		semantics.Suite("Action").Callback = { id as string | return ActionCard(id) } 
		operators["+"] = do(lhs, rhs):
			assert lhs is not null
			assert rhs is not null
			cast(IIncreasible, lhs).Increase(rhs)
