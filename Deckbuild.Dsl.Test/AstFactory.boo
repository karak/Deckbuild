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
	
	def BehaviorDefinition(trigger as Ast.Trigger, *actions as (Ast.IActionExpr)):
		return Ast.BehaviorDefinition(trigger, actions)
		
	def Trigger(id as string):
		return Ast.Trigger(Ast.Identifier(id))
	
	def IntegralLiteral(value as int):
		return Ast.IntegralLiteral(value)
		
	def ActionOp(symbol as string):
		return Ast.ActionOp(symbol)
		
	def UserDefinedActionExpr(variableId as string, opSymbol as string, integralValue as int):
		return Ast.UserDefinedActionExpr(
			ActionOp(opSymbol),
			FunctionCall(variableId),
			Ast.IntegralLiteral(integralValue))
	
	def FunctionCall(functionId as string):
		return Ast.FunctionCall(
			Ast.Identifier(functionId)
		)
	
	def FunctionCall(functionId as string, *argIds as (string)):
		return Ast.FunctionCall(
			Ast.Identifier(functionId),
			cast(Ast.IActionParameter, FunctionCall(x)) for x in argIds
		)
	
	def FunctionCall(functionId as string, *args as (Ast.IActionParameter)):
		return Ast.FunctionCall(
			Ast.Identifier(functionId),
			args
		)
	
	def FunctionCallSequence(*functionIds as (string)):
		return Ast.FunctionCallSequence(
			FunctionCall(x) for x in functionIds
		)