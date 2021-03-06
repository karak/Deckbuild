namespace Deckbuild.Dsl.Utility

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast


class PrettyPrintableAttribute(AbstractAstAttribute):
"""provide ToString() implementation
Remarks:
	build string by combination of type-name and all the fields.
	this combination rule is specialized for data object hieralcy.
"""
	override def Apply(targetNode as Node):
		assert targetNode isa ClassDefinition
		
		type as TypeDefinition = targetNode
		toString = DefToString(type)
		type.Members.Add(toString)
		
	private static def DefToString(type as TypeDefinition) as Method:
		header = StringLiteralExpression(type.Name)
		
		fields = FieldsArrayOf(type)
		expr as Expression
		if fields.Length > 1:
			invokeMemberToStrings = InvokeMemberToString(x) for x in fields
			memberStrings = ArrayLiteralExpression()
			for x in invokeMemberToStrings:
				memberStrings.Items.Add(x)
			invokeJoin = [| String.Join('; ', $(memberStrings)) |]
			expr = [| "(${$(header)}| ${$(invokeJoin)})" |]
		elif fields.Length == 1:
			expr = InvokeMemberToString(fields[0])
		else:
			expr = StringLiteralExpression('()')
		return [|
			override def ToString():
				return $(expr)
		|]
	
	private static def InvokeMemberToString(field as Field):
		if field.Type.ToString() == "string": //how to create TypeReference?
			return [| "\"${self.$(field.Name)}\"" |]
		else:
			return [| self.$(field.Name).ToString() |]

