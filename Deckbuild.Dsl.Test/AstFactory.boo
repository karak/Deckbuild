namespace Deckbuild.Dsl.Test

import System
import Deckbuild.Dsl

static class AstFactory:
	def PropertyDefinition(id as string, value as int):
		return Ast.PropertyDefinition(Ast.Identifier(id), Ast.IntegralLiteral(value))
		
	def CardDefinitionHeader(cardId as string, suiteId as string):
		return Ast.CardDefinitionHeader(Ast.Identifier(cardId), Ast.Suite(Ast.Identifier(suiteId)))
	
	def CardDefinition(header as Ast.CardDefinitionHeader, *properties as (Ast.PropertyDefinition)):
		return Ast.CardDefinition(header, properties)

