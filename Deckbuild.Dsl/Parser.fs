#light 
module Deckbuild.Dsl.Parser

open FParsec.Primitives
open FParsec.CharParsers
open Deckbuild.Dsl.Ast

//utility
let private applyForeach fs x = for f in fs do f(x) done

//TODO: each token should eat following ws
let private eol = newline |>> ignore
let private multipleEol = many1 eol |>> ignore <?> "multiple-eol"

/// it could consist user defined opereator
let availableOpLetter = anyOf "+-/%<>&|^"
let assignOp = skipChar '='
let invokeOp = skipString "=>"
let applyOp = skipChar '~'
let actionOp = (many1Chars availableOpLetter) |>> (fun(x) -> ActionOp(x)) <?> "user-defined-action-operator"

let private underscore = pchar '_'
let identifierStartChar = letter <|> underscore <?> "identifier-start-character"
let identifierPartChar = choice [letter ; digit ; underscore; ] <?> "identifier-part-character"
/// simplified Unicode Standard Annex #15. indeed, must accept Mn,Mc,Pc,Cf and escaped characters
let identifier: Parser<Identifier, unit> = 
    parse {let! start = identifierStartChar
           let! parts = (manyChars identifierPartChar)
           return Identifier(string(start) + parts)}
    <?> "identifier"

///integral literals
let integralLiteral = pint32 |>> (fun(x) -> IntegralLiteral(x)) <?> "integral-literal"

///rvalue for operand
let rvalue = integralLiteral |>> (fun(x) -> (x :> IRValue)) <?> "rvalue"

///subset of all cards that has common traits
let suite = identifier |>> (fun(id) -> Suite(id)) <?> "suite"

let cardDefinitionHeader =
    parse { let! id = pchar '*' >>. identifier
            let! s = pchar ':' >>. suite
            return CardDefinitionHeader(id, s)}
    <?> "card-definition-header"

let propertyDefinition =
    parse { let! id = identifier
            let! value = assignOp >>. rvalue
            return PropertyDefinition(id, value) }
    <?> "property-definition"

let trigger = identifier |>> fun(x) -> Trigger(x)

let variableId = identifier |>> fun(x) -> Variable(x)

let methodId = identifier <?> "method" |>> fun(x) -> Method(x)

let actionExpr =
    parse { let! lhs = variableId
            let! expr = 
                parse { let! m = (applyOp >>. methodId)
                        return MethodInvocationExpr(lhs, m) :> IActionExpr }
                <|>
                parse { let! op = actionOp
                        let! rhs = rvalue
                        return UserDefinedActionExpr(op, lhs, rhs) :> IActionExpr }
            return expr }
    <?> "action-expression"

let behaviorDefinition =
    parse { let! t = trigger
            do! invokeOp
            let! acts = sepBy1 actionExpr (pchar ';')
            return BehaviorDefinition(t, acts)}
    <?> "behavior-definition"

let private propertyDefinitionStatement: Parser<CardDefinitionBody->unit, _> = 
    parse { let! p = propertyDefinition
            do! multipleEol
            return fun(body: CardDefinitionBody)->body.AddProperty(p) }

let private behaviorDefinitionStatement: Parser<CardDefinitionBody->unit, _> = 
    parse { let! b = behaviorDefinition
            do! multipleEol
            return fun(body: CardDefinitionBody)->body.AddBehavior(b) }

let cardTraitStatement = (attempt propertyDefinitionStatement <|> behaviorDefinitionStatement) <?> "card-trait-statement"
//attention: we can't use just <|> because first parser may consume partial input when second parser parsed input

let cardDefinitionBody =
    parse { let! fs = (many cardTraitStatement)
            let body = CardDefinitionBody()
            applyForeach fs body
            return body }
    <?> "card-definition-body"

///parse clause to define one card
let cardDefinition =
    parse { let! header = cardDefinitionHeader .>> multipleEol
            let! body = cardDefinitionBody
            return CardDefinition(header, body) }
    <?> "card-definition"

let script = many cardDefinition

type InvalidAst (message:string, ?innerException:exn) =
    inherit System.InvalidOperationException (message, 
        match innerException with | Some(ex) -> ex | _ -> null)   

//driver for testing
let parseText<'a>(parser: Parser<'a, unit>, text: string) = 
  let result = run parser text
  match (result) with
  | Success (node, _, _) -> node
  | Failure (msg, err, _) -> raise (InvalidAst msg)

let parseFile(fileName: string) = 
  let result = runParserOnFile script () fileName System.Text.Encoding.UTF8
  match (result) with
  | Success (node, _, _) -> node
  | Failure (msg, err, _) -> raise (InvalidAst msg)
