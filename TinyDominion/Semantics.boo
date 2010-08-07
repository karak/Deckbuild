namespace TinyDominion

import Deckbuild.Framework

def InjectSemantics(config as Configure[of Card]):
	config.Semantics.Suite("Victory").To[of VictoryCard](
		{id as string | return cast(Card, VictoryCard(id))}
	).Property("cost").To(
		{ card as VictoryCard, value as int | card.Cost = value }
	).Property("victory_point").To(
		{ card as VictoryCard, value as int | card.VictoryPoint = value }
	).End(
	).Suite("Treasure").To[of TreasureCard](
		{ id as string | return cast(Card, TreasureCard(id))} 
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
	
	return config