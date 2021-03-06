namespace Deckbuild.Dsl.Utility

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast


# note AstAttribute must be separate assembly

class MemberwiseEquatableAttribute(AbstractAstAttribute):
""" implement memberwise equality compare
Remarks:
	this ast-attribute add implementation of following methods to the target.
	as well as add interface IEquatable[of T] to type declaration,
	* Equals(obj as object)
	* Equals(obj as T)
	* GetHashCode()
"""
	private _customEquals as bool
	
	CustomEquals as BoolLiteralExpression:
		set:
			_customEquals = value.Value
	
	def Apply(targetNode as Node):
		assert targetNode isa ClassDefinition
		
		type as ClassDefinition = targetNode
		type.BaseTypes.Add(MakeIEquatable(type))
		type.Members.Add(DefEqualsToSameType(type)) unless _customEquals
		type.Members.Add(DefEqualsToObject(type))
		type.Members.Add(DefGetHashCode(type))
		
	//how to create TypeReference directly?
	private static def MakeIEquatable(type as ClassDefinition) as TypeReference:
		dummyType as ClassDefinition = [|
			class _Local(System.IEquatable[of $(type.ToString())]):
				pass
		|]
		return dummyType.BaseTypes[0]
		
	private static def DefEqualsToSameType(type as ClassDefinition) as Method:
		exprs = [|self.$(x.Name).Equals(other.$(x.Name))|] for x in FieldsOf(type)
		foldedByAnd = Fold(BinaryOperatorType.And, BoolLiteralExpression(true), exprs)
		return [|
			def Equals(other as $(type.Name)) as bool:
				return $(foldedByAnd)
		|]
		
	private static def DefEqualsToObject(type as ClassDefinition):
		return [|
			override def Equals(obj as object) as bool:
				objWithSameType = obj as $(type.Name)
				if objWithSameType is not null:
					return self.Equals(objWithSameType)
				else:
					return false
		|]
	
	private static def DefGetHashCode(type as ClassDefinition):
		exprs = [| $(x.Name).GetHashCode() |] for x in FieldsOf(type)
		foldedByXor = Fold(BinaryOperatorType.ExclusiveOr, IntegerLiteralExpression(0), exprs)
		return [|
			override def GetHashCode() as int:
				return $(foldedByXor)
		|]
	
		
		