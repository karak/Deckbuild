namespace Deckbuild.Dsl.Ast

import System


class BehaviorDefinition:
	[Getter(Trigger)]
	_trigger as Trigger
	
	[Getter(Action)]
	_action as ActionExpr
	
	def constructor(trigger as Trigger, action as ActionExpr):
		_trigger = trigger
		_action = action
	
	override def ToString():
		return "(BehaviorDef ${_trigger} ${_action})"
	
	static def op_Equality(lhs as BehaviorDefinition, rhs as BehaviorDefinition):
		return lhs._trigger == rhs._trigger and lhs._action == rhs._action
	
	override def Equals(obj):
		casted = obj as BehaviorDefinition
		if casted is not null:
			return self == casted
		else:
			return false
			
	//override def GetHashCode():

class Trigger:
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	override def ToString():
		return "(Trigger ${_id})"
	
	static def op_Equality(lhs as Trigger, rhs as Trigger):
		return lhs._id == rhs._id
	
	override def Equals(obj):
		casted = obj as Trigger
		if casted is not null:
			return self == casted
		else:
			return false
	
	//override def GetHashCode():


interface ActionExpr:
	def Accept(visitor as ActionExprVisitor) as void:
		pass

class MethodInvocationExpr(ActionExpr):
	[Getter(LValue)]
	_lvalue as LValue
	
	[Getter(Method)]
	_method as Method
	
	def constructor(lvalue as LValue, method as Method):
		_lvalue = lvalue
		_method = method
	
	override def ToString():
		return "(MethodInvocationExpr ${_lvalue} ${_method})"
	
	static def op_Equality(lhs as MethodInvocationExpr, rhs as MethodInvocationExpr):
		return lhs._lvalue == rhs._lvalue and lhs._method == rhs._method
	
	override def Equals(obj):
		casted = obj as MethodInvocationExpr
		if casted is not null:
			return self == casted
		else:
			return false
	//override def GetHashCode():
	def ActionExpr.Accept(visitor as ActionExprVisitor) as void:
		visitor.Visit(self)
		
struct UserDefinedActionExpr(ActionExpr):
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

class Object(LValue):
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	override def ToString():
		return "(Object ${_id})"
	
	static def op_Equality(lhs as Object, rhs as Object):
		return lhs._id == rhs._id
	
	override def Equals(obj):
		casted = obj as Object
		if casted is not null:
			return self == casted
		else:
			return false
	
	//override def GetHashCode():
	def LValue.Accept(visitor as LValueVisitor) as void:
		visitor.Visit(self)
	
class Method:
	[Getter(Id)]
	_id as Identifier
	
	def constructor(id as Identifier):
		_id = id
	
	override def ToString():
		return "(Method ${_id})"
	
	static def op_Equality(lhs as Method, rhs as Method):
		return lhs._id == rhs._id
	
	override def Equals(obj):
		casted = obj as Method
		if casted is not null:
			return self == casted
		else:
			return false
	
	//override def GetHashCode():

class ActionOp:
	[Getter(Symbol)]
	_symbol as string
	
	def constructor(symbol as string):
		_symbol = symbol
	
	override def ToString():
		return "(ActionOp ${_symbol})"
	
	static def op_Equality(lhs as ActionOp, rhs as ActionOp):
		return lhs._symbol == rhs._symbol
	
	override def Equals(obj):
		casted = obj as ActionOp
		if casted is not null:
			return self == casted
		else:
			return false
	
	//override def GetHashCode():
