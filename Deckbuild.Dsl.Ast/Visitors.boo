namespace Deckbuild.Dsl.Ast

import System;

interface RValueVisitor:
	def Visit(rvalue as IntegralLiteral) as void:
		pass
	
interface LValueVisitor:
	def Visit(lvalue as Deckbuild.Dsl.Ast.Object) as void:
		pass

interface ActionExprVisitor:
	def Visit(actionExpr as MethodInvocationExpr) as void:
		pass
	
	def Visit(actionExpr as UserDefinedActionExpr) as void:
		pass


### visitor implementation based on closure ###

struct RValueVisitorImpl(RValueVisitor):
	public WhenIntegralLiteral as Action[of IntegralLiteral]
	def RValueVisitor.Visit(rvalue as IntegralLiteral) as void:
		WhenIntegralLiteral(rvalue)

struct LValueVisitorImpl(LValueVisitor):
	public WhenObject as Action[of Deckbuild.Dsl.Ast.Object]
	
	def LValueVisitor.Visit(lvalue as Deckbuild.Dsl.Ast.Object) as void:
		WhenObject(lvalue)

struct ActionExprVisitorImpl(ActionExprVisitor):
	public WhenMethodInvocationExpr as Action[of MethodInvocationExpr]
	public WhenUserDefinedActionExpr as Action[of UserDefinedActionExpr]
	
	def ActionExprVisitor.Visit(actionExpr as MethodInvocationExpr) as void:
		WhenMethodInvocationExpr(actionExpr)
	
	def ActionExprVisitor.Visit(actionExpr as UserDefinedActionExpr) as void:
		WhenUserDefinedActionExpr(actionExpr)
