#light 
module Deckbuild.Dsl.Parser

open FParsec.Primitives
open FParsec.CharParsers

//abstract syntax tree

type Ast = Id of string

//TODO: each token should eat following ws

let private underscore = pchar '_'
let private identifierStartChar = letter <|> underscore <?> "identifier-start-character"
let private identifierPartChar = choice [letter ; digit ; underscore; ] <?> "identifier-part-character"
/// simplified Unicode Standard Annex #15. indeed, must accept Mn,Mc,Pc,Cf and escaped characters
let identifier: Parser<Ast, unit> = 
    parse {let! start = identifierStartChar
           let! parts = (manyChars identifierPartChar)
           return Id (string(start) + parts)}

exception InvalidAst of string

//driver for testing
let parseText(parser: Parser<Ast, unit>, text: string) = 
  let result = run parser text
  match (result) with
  | Success (ast, _, _) -> ast
  | Failure (msg, err, _) -> raise (InvalidAst msg)
