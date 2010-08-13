namespace TinyDominion

import Deckbuild.Framework
import Deckbuild.Dsl

class DslFactory(AbstractDslFactory[of ICard]):
	def constructor(gameFacade as IGameFacade, predFactory as IPredicateFactory):
		super({ Context(gameFacade, predFactory) })
		
	override def Configure(semantics as ISemanticBinder[of ICard], operators as IOperatorRepository):
		semantics.Suite("Victory").To[of VictoryCard](
			{id as string | return cast(ICard, VictoryCard(id))}
		).Property("cost").To(
			{ card as VictoryCard, value as int | card.Cost = value }
		).Property("victory_point").To(
			{ card as VictoryCard, value as int | card.VictoryPoint = value }
		).End(
		).Suite("Treasure").To[of TreasureCard](
			{ id as string | return cast(ICard, TreasureCard(id))} 
		).Property("cost").To(
			{ card as TreasureCard, value as int | card.Cost = value }
		).Property("coin").To(
			{ card as TreasureCard, value as int | card.Coin = value }
		).End(
		).Suite("Action").To[of ActionCard](
			{ id as string | return ActionCard(id) } 
		).Property("cost").To(
			{ card as ActionCard, value as int | card.Cost = value }
		).Behavior("play").To(
			{ card as ActionCard, f as System.Action | card.Played = f }
		).End()
		
		operators["+"] = { lhs, rhs | cast(IIncreasible, lhs).Increase(rhs) }
