## Skizze der Idee

    1 2 3 get-ds unpush [ ] cons :x get-dict assoc [ 1 :x + ] swap func apply set-ds

> Notwendigkeit eines Stapels um Umgebung abzubilden

## Ansatz: `func` mit `__ENV__` in Dict aufsetzen

    // Prepare Dictionary for func context
    // Result is: { ... __ENV__ [ <key> <val> @E ] ... }
    <val> \ __ENV__ get-dict [ ] get cons \ <key> push \ __ENV__ get-dict assoc

    : LOAD ( <key> -- <val> ) 
    

\ x [ x 2 z 3 y 4 ] get-val

: get-val ( key seq -- val )
  dup empty? 
  [ drop \ [ _is-invalid-key ] cons word ] % eg `x_is-invalid-key`
  [
    uncons            % key k1 rest
    -rot over equal?  % rest key (k1==key?)
    [ drop top ]
    [ swap pop get-val ] % recurse on remaining pairs
    if
  ]
  if ;

