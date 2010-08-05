namespace TinyDominion

import System
import Deckbuild.Dsl

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

private class TreasureCard(BaseCard):
	def constructor(id as string):
		super(id)

private class VictoryCard(BaseCard):
	def constructor(id as string):
		super(id)

abstract class SemanticError(Exception):
	pass

class UnknownSuite(SemanticError):
	pass

def AssignCost(card as BaseCard, propertyDef as Ast.PropertyDefinition):
	return false if propertyDef.Id.Name !=  "cost"
	integral = propertyDef.Value as Ast.IntegralLiteral
	return false if integral is null
	card.Cost = integral.Value
	return true

def BuildTreasureCard(id, properties):
	card = TreasureCard(id)
	for p in properties:
		AssignCost(card, p)
	return card

def BuildVictoryCard(id, properties):
	card = VictoryCard(id)
	for p in properties:
		AssignCost(card, p)
	return card

static def Build(cardDef as Ast.CardDefinition) as Card:
	header = cardDef.Header
	id = header.Id.Name
	suiteId = header.Suite.Id.Name
	if suiteId == "Treasure":
		return BuildTreasureCard(id, cardDef.Properties)
	elif suiteId == "Victory":
		return BuildVictoryCard(id, cardDef.Properties)
	else:
		raise UnknownSuite()


cardDefs = Parser.parseFile("../../scripts/all.dbc")
cards = [Build(x) for x in cardDefs]

Console.ReadKey()
