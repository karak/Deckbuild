namespace Deckbuild.Dsl.Ast

import System
import Deckbuild.Dsl.Utility


[MemberwiseEquatable]
[PrettyPrintable]
class BehaviorDefinition:
	[Getter(Trigger)]
	_trigger as Trigger
	
	[Getter(Action)]
	_action as ActionExpr
	
	def constructor(trigger as Trigger, action as ActionExpr):
		_trigger = trigger
		_action = action


[MemberwiseEquatable]
[PrettyPrintable]
class Trigger:
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	

interface ActionExpr:
	def Accept(visitor as ActionExprVisitor) as void:
		pass


[MemberwiseEquatable]
[PrettyPrintable]
class MethodInvocationExpr(ActionExpr):
	[Getter(LValue)]
	_lvalue as LValue
	
	[Getter(Method)]
	_method as Method
	
	def constructor(lvalue as LValue, method as Method):
		_lvalue = lvalue
		_method = method
	
	def ActionExpr.Accept(visitor as ActionExprVisitor) as void:
		visitor.Visit(self)
		
[MemberwiseEquatable]
[PrettyPrintable]
class UserDefinedActionExpr(ActionExpr):
	[Getter(Operator)]
	_op as ActionOp
	
	[Getter(Lhs)]
	_lhs as LValue
	
	[Getter(Rhs)]
	_rhs as RValue
	
	public def constructor(op as ActionOp, lhs as LValue, rhs as RValue):
		_op = op
		_lhs = lhs
		_rhs = rhs
	
	def Accept(visitor as ActionExprVisitor) as void:
		visitor.Visit(self)
		
interface LValue:
	def Accept(visitor as LValueVisitor) as void:
		pass

[MemberwiseEquatable]
[PrettyPrintable]
class Object(LValue):
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	//override def GetHashCode():
	def LValue.Accept(visitor as LValueVisitor) as void:
		visitor.Visit(self)
	
[MemberwiseEquatable]
[PrettyPrintable]
class Method:
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
[MemberwiseEquatable]
[PrettyPrintable]
class ActionOp:
	[Getter(Symbol)]
	_symbol as string
	
	def constructor(symbol as string):
		_symbol = symbol

