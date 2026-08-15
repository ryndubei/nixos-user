; ----------------------------------------------------------------------------
; Modified version of
; https://github.com/nvim-treesitter/nvim-treesitter/blob/main/runtime/queries/haskell/highlights.scm
; because I disagree with some of the choices made, including:
;
; - It's pointless to attempt semantic highlighting for functions when there's
;   no typechecker. You cannot tell them apart using syntax alone, so previously
;   the highlighting resorted to special cases like "it's a @function.call if the
;   operator is a <$>". This just results in the highlighting being inconsistent,
;   unpredictable and untrustworthy.
; - It is misleading to highlight ordinary standard library functions like
;   `bracket` as if they were keywords. What if I don't import Control.Exception
;   and `bracket` means something else entirely? Or what if I define `bracket2 =
;   bracket`?
; - 'forall' is not a "keyword related to loops" (@keyword.repeat: https://neovim.io/doc/user/treesitter)
; - 'True', 'False' should not be given special boolean literal highlighting
;   because `Bool` is also an ordinary standard library sum type. This is doubly
;   the case for `otherwise`. It doesn't matter that the default implementation
;   is `otherwise = True`, what if I have NoImplicitPrelude?
;
; In return, I make only two or three questionable choices of my own:
; - names in type signatures are highlighted as functions while the
;   corresponding names in definitions are highlighted as variables
; - Any variable that is named exactly 'proc' is highlighted as a keyword. This
;   is because the Haskell treesitter grammar does not support arrow syntax yet.
; ----------------------------------------------------------------------------
; Parameters and variables
; NOTE: These are at the top, so that they have low priority,
; and don't override destructured parameters
(variable) @variable

(decl/function
  patterns: (patterns
    (_) @variable.parameter))

(expression/lambda
  patterns: (patterns
    (_) @variable.parameter)
  "->")

(decl/function
  (infix
    (pattern) @variable.parameter))

; ----------------------------------------------------------------------------
; Literals and comments
(integer) @number

(negation) @number

(expression/literal
  (float)) @number.float

(char) @character

(string) @string

(comment) @comment

(haddock) @comment.documentation

; ----------------------------------------------------------------------------
; Punctuation
[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

[
  ","
  ";"
] @punctuation.delimiter

; ----------------------------------------------------------------------------
; Keywords, operators, includes
[
  "forall"
  ; "∀" ; utf-8 is not cross-platform safe
] @keyword.modifier

(pragma) @keyword.directive

[
  "if"
  "then"
  "else"
  "case"
  "of"
] @keyword.conditional

[
  "import"
  "qualified"
  "module"
  "as"
  "hiding"
  "foreign"
  "import"
  "export"
] @keyword.import

; Rely on the treesitter haskell parser to track all the different calling
; conventions and safety levels.
; The downside is that the text won't be highlighted until the foreign import/
; export declaration is written in full, so TODO also explicitly track
; ccall/capi/javascript/safe/unsafe as keywords.
(foreign_import
  .
  (calling_convention)? @keyword.import
  (safety)? @keyword.import)
(foreign_export
  .
  (calling_convention) @keyword.import)

[
  (operator)
  (constructor_operator)
  (all_names)
  "."
  ".."
  "="
  "|"
  "::"
  "=>"
  "->"
  "<-"
  "\\"
  "`"
  "@"
  "!"
] @operator

(wildcard) @character.special

(module
  (module_id) @module)

[
  "where"
  "let"
  "in"
  "pattern"
] @keyword.function ; you can define functions with these after all

[
  "class"
  "instance"
  "data"
  "newtype"
  "type"
  "family"
] @keyword.type ; you can define functions with these after all

[
  "deriving"
  "via"
  "stock"
  "anyclass"
  "do"
  "mdo"
  "rec"
  "infix"
  "infixl"
  "infixr"
] @keyword

; Arrow 'proc' keyword
; Since the grammar does not support arrow syntax, we have to highlight it
; naively by hand.
; This will lead to erroneous highlighting of variables that are named exactly
; 'proc', which I am personally fine with.
(
  (variable) @keyword
  (#eq? @keyword "proc")
)

; ----------------------------------------------------------------------------
; Functions and variables

; Since @function will be unused otherwise, it is instead used as separate
; highlighting for names in explicit type signatures.
; Think of this as symbolising an implicit type-level function from names to
; types.
(decl/signature
  [
    name: (variable) @function
    names: (binding_list
      (variable) @function)
  ])

(decl/function
  [
    name: (variable) @variable
    names: (binding_list
      (variable) @variable)
  ])

(decl/bind
  [
    name: (variable) @variable
    names: (binding_list
      (variable) @variable)
  ])

; consider infix functions as operators
(infix_id
  [
    (variable) @operator
    (qualified
      (variable) @operator)
  ])

; infix operator function definitions
(decl/function
  (infix
    left_operand: (variable) @variable.parameter
    operator: (operator)
    right_operand: (variable) @variable.parameter)
  )

; mixed opinions on having this, leaving it as commented out.
; It might help make code easier to read, but it will also fail
; when wrapped in enough parentheses like `((...(foo)...)) bar`
; no matter how many special cases we have.
; Also, we want to keep @function highlighting for type signatures.
; (apply
;   [
;     (expression/variable) @function.call
;     (expression/qualified
;       (variable) @function.call)
;   ])

; ----------------------------------------------------------------------------
; Types
(name) @type

(type/unit) @type

(type/unit
  [
    "("
    ")"
  ] @type)

(type/list
  [
    "["
    "]"
  ] @type)

(type/star) @type

(constructor) @constructor

; ----------------------------------------------------------------------------
; Quasi-quotes
(quoter) @function.call

(quasiquote
  quoter: [
    (quoter) @_name
    (quoter
      (qualified
        id: (variable) @_name))
  ]
  (#eq? @_name "qq")
  body: (quasiquote_body) @string)

; namespaced quasi-quoter
(quoter
  [
    (variable) @function.call
    (_
      (module) @module
      .
      (variable) @function.call)
  ])

; Highlighting of quasiquote_body for other languages is handled by injections.scm
; ----------------------------------------------------------------------------
;
; I just personally dislike highlighting fields like that.
;
; Also, the grammar cannot distinguish between foo.bar with OverloadedRecordDot
; and the function composition foo.bar when OverloadedRecordDot is disabled
; (the grammar assumes that it's always a field access)
;
; Fields
; (field_name
;   (variable) @variable.member)
;
; (import_name
;   (name)
;   .
;   (children
;     (variable) @variable.member))

; ----------------------------------------------------------------------------
; Spell checking
(comment) @spell

