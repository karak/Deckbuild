namespace Deckbuild.Dsl.Ast

import System;

interface IRValueVisitor:
	def Visit(rvalue as IntegralLiteral) as void:
		pass
	
interface ILValueVisitor:
	def Visit(lvalue as Deckbuild.Dsl.Ast.Variable) as void:
		pass
	
interface IActionExprVisitor:
	def Visit(actionExpr as FunctionCallSequence) as void:
		pass

	def Visit(actionExpr as UserDefinedActionExpr) as void:
		pass

interface IActionParameterVisitor:
	def Visit(parameter as IntegralLiteral) as void:
		pass
	
	def Visit(parameter as FunctionCall) as void:
		pass

### visitor implementation based on closure ###

struct RValueVisitor(IRValueVisitor):
	[Property(WhenIntegralLiteral )]
	private _whenIntegralLiteral as Action[of IntegralLiteral]
	
	def IRValueVisitor.Visit(rvalue as IntegralLiteral) as void:
		WhenIntegralLiteral(rvalue)

struct LValueVisitor(ILValueVisitor):
	[Property(WhenVariable)]
	private _whenVariable as Action[of Deckbuild.Dsl.Ast.Variable]
	
	def ILValueVisitor.Visit(lvalue as Deckbuild.Dsl.Ast.Variable) as void:
		WhenVariable(lvalue)

struct ActionExprVisitor(IActionExprVisitor):
	[Property(WhenFunctionCallSequence)]
	private _whenFunctionCallSequence as Action[of FunctionCallSequence]
	[Property(WhenUserDefinedActionExpr)]
	private _whenUserDefinedActionExpr as Action[of UserDefinedActionExpr]
	
	def IActionExprVisitor.Visit(actionExpr as FunctionCallSequence) as void:
		WhenFunctionCallSequence(actionExpr)

	def IActionExprVisitor.Visit(actionExpr as UserDefinedActionExpr) as void:
		WhenUserDefinedActionExpr(actionExpr)

struct ActionParameterVisitor(IActionParameterVisitor):
	[Property(WhenIntegralLiteral)]
	private _whenIntegralLiteral as Action[of IntegralLiteral]
	[Property(WhenFunctionCall)]
	private _whenFunctionCall as Action[of FunctionCall]
	
	def IActionParameterVisitor.Visit(parameter as IntegralLiteral) as void:
		WhenIntegralLiteral(parameter)
	
	def IActionParameterVisitor.Visit(parameter as FunctionCall) as void:
		WhenFunctionCall(parameter)
