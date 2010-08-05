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
let integralLiteral = pint32 |>> (fun(x) -> IntegralLiteral(x)) <?> "integral-literal"

///rvalue for operand
let rvalue = integralLiteral |>> (fun(x) -> (x :> RValue)) <?> "rvalue"

///subset of all cards that has common traits
let suite = identifier |>> (fun(id) -> Suite(id)) <?> "suite"

let cardDefinitionHeader =
    parse { let! id = pchar '*' >>. identifier
            let! s = pchar ':' >>. suite
            return CardDefinitionHeader(id, s)}
    <?> "card-definition-header"

let propertyDefinition =
    parse { let! id = identifier
            let! value = pchar '=' >>. rvalue
            return PropertyDefinition(id, value) }
    <?> "property-definition"

///parse clause to define one card
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
