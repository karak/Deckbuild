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
	
	def CardDefinitionBody(*behaviors as (Ast.BehaviorDefinition)):
		body = Ast.CardDefinitionBody()
		for b in behaviors:
			body.AddBehavior(b)
		return body
	
	def CardDefinitionBody(properties as Ast.PropertyDefinition*, behaviors as Ast.BehaviorDefinition*):
		body = Ast.CardDefinitionBody()
		for p in properties:
			body.AddProperty(p)
		for b in behaviors:
			body.AddBehavior(b)
		return body
	
	def CardDefinition(header as Ast.CardDefinitionHeader, *properties as (Ast.PropertyDefinition)):
		return Ast.CardDefinition(header, CardDefinitionBody(*properties))
	
	def BehaviorDefinition(trigger as Ast.Trigger, action as Ast.ActionExpr):
		return Ast.BehaviorDefinition(trigger, action)
	
	def Trigger(id as string):
		return Ast.Trigger(Ast.Identifier(id))
	
	def ApplyOp(objectId as string, methodId as string):
		return ApplyOp(Object(objectId), Method(methodId))
	
	def ApplyOp(lvalue as Ast.LValue, method as Ast.Method):
		return Ast.ApplyOp(lvalue, method)
	
	def Object(id as string):
		return Ast.Object(Ast.Identifier(id))
	
	def Method(id as string):
		return Ast.Method(Ast.Identifier(id))
