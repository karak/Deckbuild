namespace Deckbuild.Dsl.Ast

import System
import Deckbuild.Dsl.Utility


[MemberwiseEquatable]
class BehaviorDefinition(IEquatable[of BehaviorDefinition]):
	[Getter(Trigger)]
	_trigger as Trigger
	
	[Getter(Action)]
	_action as ActionExpr
	
	def constructor(trigger as Trigger, action as ActionExpr):
		_trigger = trigger
		_action = action
	
	override def ToString():
		return "(BehaviorDef ${_trigger} ${_action})"


[MemberwiseEquatable]
class Trigger(IEquatable[of Trigger]):
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	override def ToString():
		return "(Trigger ${_id})"
	

interface ActionExpr:
	def Accept(visitor as ActionExprVisitor) as void:
		pass


[MemberwiseEquatable]
class MethodInvocationExpr(ActionExpr, IEquatable[of MethodInvocationExpr]):
	[Getter(LValue)]
	_lvalue as LValue
	
	[Getter(Method)]
	_method as Method
	
	def constructor(lvalue as LValue, method as Method):
		_lvalue = lvalue
		_method = method
	
	override def ToString():
		return "(MethodInvocationExpr ${_lvalue} ${_method})"
	
	def ActionExpr.Accept(visitor as ActionExprVisitor) as void:
		visitor.Visit(self)
		
[MemberwiseEquatable]
class UserDefinedActionExpr(ActionExpr, IEquatable[of UserDefinedActionExpr]):
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
class Object(LValue, IEquatable[of Object]):
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	override def ToString():
		return "(Object ${_id})"
	
	//override def GetHashCode():
	def LValue.Accept(visitor as LValueVisitor) as void:
		visitor.Visit(self)
	
[MemberwiseEquatable]
class Method(IEquatable[of Method]):
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	override def ToString():
		return "(Method ${_id})"
	
[MemberwiseEquatable]
class ActionOp(IEquatable[of ActionOp]):
	[Getter(Symbol)]
	_symbol as string
	
	def constructor(symbol as string):
		_symbol = symbol
	
	override def ToString():
		return "(ActionOp ${_symbol})"
