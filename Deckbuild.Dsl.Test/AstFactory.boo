namespace Deckbuild.Dsl.Test

import System
import Deckbuild.Dsl

static class AstFactory:
	def PropertyDefinition(id as string, value as int):
		return Ast.PropertyDefinition(Ast.Identifier(id), Ast.IntegralLiteral(value))
		
	def CardDefinitionHeader(cardId as string, suiteId as string):
		return Ast.CardDefinitionHeader(Ast.Identifier(cardId), Ast.Suite(Ast.Identifier(suiteId)))
	
	def CardDefinitionBody(*properties as (Ast.PropertyDefinition)):
		body = Ast.CardDefinitionBody()
		for p in properties:
			body.AddProperty(p)
		return body
	
	def CardDefinition(header as Ast.CardDefinitionHeader, *properties as (Ast.PropertyDefinition)):
		return Ast.CardDefinition(header, CardDefinitionBody(*properties))
