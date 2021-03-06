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
	

interface IActionExpr://TODO:(ILValue):
	def Accept(visitor as IActionExprVisitor) as void:
		pass

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
class ActionOp:
	[Getter(Symbol)]
	private final _symbol as string
	
	def constructor(symbol as string):
		_symbol = symbol

interface IActionParameter:
	def Accept(visitor as IActionParameterVisitor):
		pass

[MemberwiseEquatable(CustomEquals: true)]
class FunctionCall(IActionParameter, ILValue):
	[Getter(Id)]
	private final _id as Identifier
	private final _args as (IActionParameter)
	
	def constructor(id as Identifier, args as IActionParameter*):
		_id = id
		_args = array(IActionParameter, args)
	
	def constructor(id as Identifier):
		_id = id
		_args = array(IActionParameter, 0)
	
	Args as IActionParameter*:
		get:
			return _args
	
	def Equals(other as FunctionCall):
		return _id.Equals(other._id) and ArraysAreEqual(_args, other._args)
	
	override def ToString() as string:
		argsString = array(string, x.ToString() for x in _args)
		return "(FunctionCall ${_id}(${string.Join(', ', argsString)}))"
	
	def IActionParameter.Accept(visitor as IActionParameterVisitor):
		visitor.Visit(self)

	def ILValue.Accept(visitor as ILValueVisitor):
		visitor.Visit(self)

[MemberwiseEquatable(CustomEquals: true)]
[PrettyPrintable]
class FunctionCallSequence(IActionExpr):
	[Getter(FunctionCalls)]
	private final _funcs as (FunctionCall)
	
	def constructor(funcs as FunctionCall*):
		_funcs = array[of FunctionCall](funcs)
	
	def Equals(other as FunctionCallSequence):
		return ArraysAreEqual(_funcs, other._funcs)
	
	def Accept(visitor as IActionExprVisitor) as void:
		visitor.Visit(self)
	
//TODO: integrate to MemberwiseEquatableAttribute
static def ArraysAreEqual[of T, U](lhs as (T), rhs as (U)):
	return false if lhs.Length != rhs.Length
	for i in range(0, lhs.Length):
		return false if lhs[i] != rhs[i]
	return true
	
