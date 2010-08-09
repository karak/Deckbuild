namespace Deckbuild.Dsl.Ast

import System
import Deckbuild.Dsl.Utility


[MemberwiseEquatable]
[PrettyPrintable]
class BehaviorDefinition:
	[Getter(Trigger)]
	private final _trigger as Trigger
	
	private final _actions as CustomList[of IActionExpr]
	
	def constructor(trigger as Trigger, actions as IActionExpr*):
		_trigger = trigger
		_actions = CustomList[of IActionExpr](actions)
	
	Actions as IActionExpr*:
		get:
			return _actions


[MemberwiseEquatable]
[PrettyPrintable]
class Trigger:
	[Getter(Id)]
	private final _id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	

interface IActionExpr:
	def Accept(visitor as IActionExprVisitor) as void:
		pass


[MemberwiseEquatable]
[PrettyPrintable]
final class MethodInvocationExpr(IActionExpr):
	[Getter(LValue)]
	private final _lvalue as ILValue
	
	[Getter(Method)]
	private final _method as Method
	
	def constructor(lvalue as ILValue, method as Method):
		_lvalue = lvalue
		_method = method
	
	def IActionExpr.Accept(visitor as IActionExprVisitor) as void:
		visitor.Visit(self)
		
[MemberwiseEquatable]
[PrettyPrintable]
final class UserDefinedActionExpr(IActionExpr):
	[Getter(Operator)]
	private final _op as ActionOp
	
	[Getter(Lhs)]
	private final _lhs as ILValue
	
	[Getter(Rhs)]
	private final _rhs as IRValue
	
	public def constructor(op as ActionOp, lhs as ILValue, rhs as IRValue):
		_op = op
		_lhs = lhs
		_rhs = rhs
	
	def Accept(visitor as IActionExprVisitor) as void:
		visitor.Visit(self)
		
interface ILValue:
	def Accept(visitor as ILValueVisitor) as void:
		pass

[MemberwiseEquatable]
[PrettyPrintable]
final class Variable(ILValue):
	[Getter(Id)]
	private final _id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	//override def GetHashCode():
	def ILValue.Accept(visitor as ILValueVisitor) as void:
		visitor.Visit(self)
	
[MemberwiseEquatable]
[PrettyPrintable]
class Method:
	[Getter(Id)]
	private final _id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
[MemberwiseEquatable]
[PrettyPrintable]
class ActionOp:
	[Getter(Symbol)]
	private final _symbol as string
	
	def constructor(symbol as string):
		_symbol = symbol

