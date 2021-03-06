Feature updates for Traits.jl
=============================

17 April 2015
-------------

The merge of
[PR #10380](https://github.com/JuliaLang/julia/pull/10380) will
necessitate quite some work.  Until things have settled a bit, Traits
is staying on Julia commit 58cef56f523.

14 April 2015
-------------

Major overhaul of `istrait` function.  Now it uses custom-programmed
checks instead of `method_exists`.  This allows parameterized methods
to be used both in the `@traitdef` and in the trait implementation.
This may have pushed Traits.jl into usable terrain.  Closes issues #2
and #8.

30 March 2015
-------------

- Allowing symbols and isbits as associated types.

14 Nov 2014
-----------

- added ability to make type constructors part of a trait
  specification.  See test at bottom of
  [test/traitdef.jl](test/traitdef.jl).

12 Nov 2014
-----------

- added associated type, see
  [Haskell](https://www.haskell.org/haskellwiki/GHC/Type_families#An_associated_data_type_example)
  or [Rust](https://github.com/aturon/rfcs/blob/associated-items/active/0000-associated-items.md).
  Examples are in [src/commontraits.jl](src/commontraits.jl).
- using `@doc` system for documentation
- improved trait dispatch when ambiguous with the following algorithm:

     - first dispatch on the normal types
     
     Then dispatch on traits using the following rules, terminating
     when only one or zero possibilities are left:

     - find all matching traits
     - discriminate using subtraits, i.e. a subtrait will win over its supertrait
     - score all traits according to:  
       1 point for all single parameter traits,  
       2 points for all two parameter traits,  
       etc.  
       Now pick the highest scoring method.
     - if still ambiguous throw an error

  See also [examples/ex_dispatch.jl](examples/ex_dispatch.jl).
- better testing of the existence of interface methods.  Now uses the
  `method_exists` function.  This leads to some problems with
  parameterised types, however it should work fine when the parameters
  are specified:
  ```
  julia> istrait(Indexable{Array})
  false

  julia> istrait(Indexable{Array{Int}})
  false
  
  julia> istrait(Indexable{Array{Int,1}})
  true
  ```
  However there is Julia bug
  [#8959](https://github.com/JuliaLang/julia/issues/8959) which can
  bite here.

  This change also necessitated to introduce a label `All` (just a
  type) to be used in interface functions declarations where `Any`
  could be used before, for example `foo(X, All) -> All`.  The reason
  being that signature type checks with `method_exists` are
  contravariant, but for `Base.return_types` covariant (or is it the other
  way around? Always confusing me...).  Example, specify that
  `getindex` is defined but we don't care about the type of the second
  argument.  To get this past `method_exists`:
  ```
  julia> method_exists(getindex, (Array{Int,1}, Any))
  false
  
  julia> method_exists(getindex, (Array{Int,1}, None))
  true
  ```
  So, in the interface specification, we need to write `getindex(X,
  None)`.  Conversely for return types:
  ```
  julia> Base.return_types(getindex, (Array{Int,1}, None))
  0-element Array{Any,1}
  
  julia> Base.return_types(getindex, (Array{Int,1}, Any))
  11-element Array{Any,1}:
  Any
  ...
  Any
  ```
  So now, in the interface specification, we need to write
  `getindex(X, Any)`.  Thus I introduced `All` which gets replaced by
  `Any` or `None` depending on context.
