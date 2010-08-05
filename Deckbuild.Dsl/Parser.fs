#light 
module Deckbuild.Dsl.Parser

open FParsec.Primitives
open FParsec.CharParsers
open Deckbuild.Dsl.Ast

//TODO: each token should eat following ws
let private eol = newline |>> ignore
let private multipleEol = many1 eol |>> ignore <?> "multiple-eol"
let private underscore = pchar '_'
let private identifierStartChar = letter <|> underscore <?> "identifier-start-character"
let private identifierPartChar = choice [letter ; digit ; underscore; ] <?> "identifier-part-character"
/// simplified Unicode Standard Annex #15. indeed, must accept Mn,Mc,Pc,Cf and escaped characters
let identifier: Parser<Identifier, unit> = 
    parse {let! start = identifierStartChar
           let! parts = (manyChars identifierPartChar)
           return Identifier(string(start) + parts)}
    <?> "identifier"

///integral literals
let integralLiteral: Parser<IntegralLiteral, unit> =
    pint32 |>> fun(x) -> IntegralLiteral(x)
    <?> "integral-literal"

let rvalue =
    parse {let! i = integralLiteral
           return i :> RValue}
    <?> "rvalue"

let suite = identifier |>> (fun(id) -> Suite(id)) <?> "suite"

let cardDefinitionHeader =
    parse { do! skipChar '*'
            let! id = identifier
            do! skipChar ':'
            let! s = suite
            return CardDefinitionHeader(id, s)}
    <?> "card-definition-header"

let propertyDefinition =
    parse { let! id = identifier
            do! skipChar '='
            let! value = rvalue
            return PropertyDefinition(id, value) }
    <?> "property-definition"

let cardDefinition =
    parse { let! header = cardDefinitionHeader .>> multipleEol
            let! properties = many (propertyDefinition .>> multipleEol)
            return CardDefinition(header, properties) }
    <?> "card-definition"

exception InvalidAst of string

//driver for testing
let parseText<'a>(parser: Parser<'a, unit>, text: string) = 
  let result = run parser text
  match (result) with
  | Success (node, _, _) -> node
  | Failure (msg, err, _) -> raise (InvalidAst msg)
