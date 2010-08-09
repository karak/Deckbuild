namespace Deckbuild.Dsl.Ast

import System;

interface IRValueVisitor:
	def Visit(rvalue as IntegralLiteral) as void:
		pass
	
interface ILValueVisitor:
	def Visit(lvalue as Deckbuild.Dsl.Ast.Variable) as void:
		pass
	
	def Visit(lvalue as Deckbuild.Dsl.Ast.MethodInvocationExpr) as void:
		pass

interface IActionExprVisitor:
	def Visit(actionExpr as MethodInvocationExpr) as void:
		pass
	
	def Visit(actionExpr as UserDefinedActionExpr) as void:
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
	[Property(WhenMethodInvokation)]
	private _whenMethodInvokation as Action[of Deckbuild.Dsl.Ast.MethodInvocationExpr]
	
	def ILValueVisitor.Visit(lvalue as Deckbuild.Dsl.Ast.Variable) as void:
		WhenVariable(lvalue)
	def ILValueVisitor.Visit(lvalue as Deckbuild.Dsl.Ast.MethodInvocationExpr) as void:
		WhenMethodInvokation(lvalue)

struct ActionExprVisitor(IActionExprVisitor):
	[Property(WhenMethodInvocationExpr)]
	private _whenMethodInvocationExpr as Action[of MethodInvocationExpr]
	[Property(WhenUserDefinedActionExpr)]
	private _whenUserDefinedActionExpr as Action[of UserDefinedActionExpr]
	
	def IActionExprVisitor.Visit(actionExpr as MethodInvocationExpr) as void:
		WhenMethodInvocationExpr(actionExpr)
	
	def IActionExprVisitor.Visit(actionExpr as UserDefinedActionExpr) as void:
		WhenUserDefinedActionExpr(actionExpr)
