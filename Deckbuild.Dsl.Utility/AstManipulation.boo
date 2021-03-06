namespace Deckbuild.Dsl.Utility

import System

import Boo.Lang.Compiler.Ast


static def Fold[of T(Expression), U(Expression)](op as BinaryOperatorType, initial as T, exprs as U*) as Expression:
	result as Expression
	result = initial
	for expr in exprs:
		result = BinaryExpression(op, result, expr)
	return result
	
static def FieldsOf(type as ClassDefinition) as Field*:
	return cast(Field, x) for x in type.Members if x isa Field
	
static def FieldsArrayOf(type as TypeDefinition):
	return array(Field, x for x in type.Members if x isa Field)
	