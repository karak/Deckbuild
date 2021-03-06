#light 
module Deckbuild.Dsl.Parser

open FParsec.Primitives
open FParsec.CharParsers
open Deckbuild.Dsl.Ast

//utility
let private applyForeach fs x = for f in fs do f(x) done
let private toPascalCase(x: Identifier) =
    let textInfo = System.Globalization.CultureInfo.CurrentCulture.TextInfo
    textInfo.ToTitleCase x.Name
let private toPascalCases(xs: seq<Identifier>) =
    let builder = System.Text.StringBuilder()
    for x in xs do ignore (builder.Append(toPascalCase(x))) done
    Identifier(builder.ToString())


//TODO: each token should eat following ws
let private ws = many (anyOf " \t")
let private eol = newline |>> ignore
let private multipleEol = many1 eol |>> ignore <?> "multiple-eol"

/// it could consist user defined opereator
let availableOpLetter = anyOf "+-/%<>&|^"
let assignOp = (skipChar '=') .>> ws
let invokeOp = (skipString "=>") .>> ws
let actionOp = (many1Chars availableOpLetter) .>> ws |>> (fun(x) -> ActionOp(x)) <?> "user-defined-action-operator"
let private headerStarter = (pchar '*') .>> ws
let private suiteStarter = (pchar ':') .>> ws
let private opfunctionCallSep = (skipChar '.') .>> ws

let private underscore = pchar '_'
let identifierStartChar = letter <|> underscore <?> "identifier-start-character"
let identifierPartChar = choice [letter ; digit ; underscore; ] <?> "identifier-part-character"
/// simplified Unicode Standard Annex #15. indeed, must accept Mn,Mc,Pc,Cf and escaped characters
let identifier: Parser<Identifier, unit> = 
    parse {let! start = identifierStartChar
           let! parts = (manyChars identifierPartChar)
           return Identifier(string(start) + parts)}
    .>> ws
    <?> "identifier"

let multiIdentifiers =
    (many1 identifier)
    |>> toPascalCases
    <?> "multi-identifiers"

///integral literals
let integralLiteral = pint32 .>> ws |>> (fun(x) -> IntegralLiteral(x)) <?> "integral-literal"

///rvalue for operand
let rvalue = integralLiteral |>> (fun(x) -> (x :> IRValue)) <?> "rvalue"

///subset of all cards that has common traits
let suite = identifier |>> (fun(id) -> Suite(id)) <?> "suite"

let cardDefinitionHeader =
    parse { let! id = headerStarter >>. identifier
            let! s = suiteStarter >>. suite
            return CardDefinitionHeader(id, s)}
    <?> "card-definition-header"

let propertyDefinition =
    parse { let! id = multiIdentifiers
            let! value = assignOp >>. rvalue
            return PropertyDefinition(id, value) }
    <?> "property-definition"

let trigger = multiIdentifiers |>> fun(x) -> Trigger(x)

// region new-syntax
let functionCall, functionCallRef = createParserForwardedToRef()
let functionArg =
    (functionCall |>> fun(x) -> (x :> IActionParameter)) <|>
    (integralLiteral |>> fun(x) -> (x :> IActionParameter))

functionCallRef :=
  parse {
    let ids = System.Collections.Generic.List<Identifier>()
    let args = System.Collections.Generic.List<IActionParameter>()
    let parseId = identifier |>> fun(x) -> ids.Add x
    let parseArg = (pchar '[' >>. functionArg .>> pchar ']') |>> fun(x) -> args.Add x

    do! parseId .>> (many (ws >>. (parseId <|> parseArg)))
    return FunctionCall(toPascalCases(ids), args) }
  <?> "function-call"

let functionCallSeq = sepBy1 functionCall opfunctionCallSep <?> "function-call-sequence"

// endregion new-syntax

let actionExpr =
    (functionCallSeq |>> fun(xs) -> (FunctionCallSequence(xs) :> IActionExpr)) <|>
    parse { let! op = actionOp .>> ws
            let! rhs = rvalue .>> ws
            let! lhs = identifier |>> fun(id) -> FunctionCall(Identifier(toPascalCase(id)))
            return UserDefinedActionExpr(op, lhs, rhs) :> IActionExpr }
    <?> "action-expression"

let behaviorDefinition =
    parse { let! t = trigger
            do! invokeOp
            let! acts = sepBy1 actionExpr (pchar ';' .>> ws)
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
