namespace Deckbuild.Dsl.Utility

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast


# note AstAttribute must be separate assembly

class MemberwiseEquatableAttribute(AbstractAstAttribute):
""" implement memberwise equality compare
Remarks:
	this ast-attribute add implementation of following methods to the target.
	* Equals(obj as object)
	* Equals(obj as T)
	* GetHashCode()
"""
	#TODO: add declaration of T(System.IEquatable[of T])
	def Apply(target as Node):
		assert target isa ClassDefinition
		
		type as ClassDefinition = target
		type.Members.Add(DefEqualsToSameType(type))
		type.Members.Add(DefEqualsToObject(type))
		type.Members.Add(DefGetHashCode(type))
		
	private def DefEqualsToSameType(type as ClassDefinition) as Method:
		exprs = [|self.$(x.Name) == rhs.$(x.Name)|] for x in FieldsOf(type)
		foldedByAnd = Fold(BinaryOperatorType.And, BoolLiteralExpression(true), exprs)
		return [|
			def Equals(rhs as $(type.Name)) as bool:
				return $(foldedByAnd)
		|]
		
	private def DefEqualsToObject(type as ClassDefinition):
		return [|
			override def Equals(obj as object) as bool:
				objWithSameType = obj as $(type.Name)
				if objWithSameType is not null:
					return self.Equals(objWithSameType)
				else:
					return false
		|]
	
	private def DefGetHashCode(type as ClassDefinition):
		exprs = [| $(x.Name).GetHashCode() |] for x in FieldsOf(type)
		foldedByXor = Fold(BinaryOperatorType.ExclusiveOr, IntegerLiteralExpression(0), exprs)
		return [|
			override def GetHashCode() as int:
				return $(foldedByXor)
		|]
	
	private static def Fold[of T(Expression), U(Expression)](op as BinaryOperatorType, initial as T, exprs as U*) as Expression:
		result as Expression
		result = initial
		for expr in exprs:
			result = BinaryExpression(op, result, expr)
		return result
	
	private static def FieldsOf(type as ClassDefinition) as Field*:
		return cast(Field, x) for x in type.Members if x isa Field
		
