: stepcc ( dict ds cs -- ??? )
  unpush dup type                        % dict ds rcs itm type 
  {
    \ wrd [ rot4 2dup                    % ds rcs itm dict itm dict 
            [ get ] dip                  % ds rcs res          dict
            -rot4 dup type               % dict ds rcs res type
            {
              \ stk [ swap concat ]      % dict ds [ @res @rcs ]
              \ fct [ swapd apply swap ] % dict ds' rcs
              :else [ swapd push swap    % dict [ res @ds ] rcs
                      \ read-word push ] % dict [ res @ds ] [ read-word @rcs ]
            } cond
          ]
    \ map [ swapd push swap
            \ read-mapping push ]        % dict [ itm @ds ] [ read-mapping @rcs ]
    \ fct [ get-ds unpush apply set-ds ] % XXX set-ds unklar!
    :else [ swapd push swap ]            % dict [ itm @ds ] rcs
  } cond ;

: runcc ( dict ds cs -- dict' ds' [ ] ) dup empty? [ stepcc runcc ] unless ;

: get-dict ( dict ds cs => dict [ @ds dict ] cs ) [ -rot over push rot ] meta  ;
: set-dict ( dict [ @ds dict' ] cs => dict' [ @ds ] cs ) 

: stepcc' ( dict ds cs -- ??? )
  unpush dup type                        % ds rcs itm type 
  {
    \ wrd [ dup get-dict swap            % ds rcs itm dict itm 
            get                          % ds rcs res
            dup type                     % ds rcs res type
            {
              \ stk [ swap concat ]      % ds [ @res @rcs ]
              \ fct [ swapd apply swap ] % ds' rcs
              :else [ swapd push swap    % [ res @ds ] rcs
                      \ read-word push ] % [ res @ds ] [ read-word @rcs ]
            } cond
          ]
    \ map [ swapd push swap
            \ read-mapping push ]        % [ itm @ds ] [ read-mapping @rcs ]
    \ fct [ get-ds unpush apply set-ds ] % [ ]
    :else [ swapd push swap ]            % [ itm @ds ] rcs
  } cond ;

: runcc' ( ds cs -- ds' [ ] ) dup empty? [ stepcc' runcc' ] unless ;

: call' ( @ds [ @q ] -- @ds ) get-ds unpush runcc' drop set-ds ;

: meta ( dict ds cs => dict' ds' cs')

: stepcc'' ( dict ds cs -- ??? )
  unpush dup type                        % ds rcs itm type 
  {
    \ wrd [ dup get-dict swap            % ds rcs itm dict itm 
            get                          % ds rcs res
            dup type                     % ds rcs res type
            {
              \ stk [ swap concat ]      % ds [ @res @rcs ]
              \ fct [ swapd apply swap ] % ds' rcs
              \ wrd [ dup \ meta equal? ]
              :else [ swapd push swap    % [ res @ds ] rcs
                      \ read-word push ] % [ res @ds ] [ read-word @rcs ]
              \ map [ ]
            } cond
          ]
    \ map [ swapd push swap
            \ read-mapping push ]        % [ itm @ds ] [ read-mapping @rcs ]
    \ fct [ get-ds unpush apply set-ds ]
    :else [ swapd push swap ]            % [ itm @ds ] rcs
  } cond ;

// prelude 

; Die Wörter `get-ds` und `set-ds` sind keine Metawörter! Man kann sie normal definieren.
;
; Das Wort `dip` ist essenziell, weil es beliebig tief in den Stapel abtauchen kann.
; Es ist als Metawort unverzichtbar, wenn `stepcc` es nutzen können soll
; [ @q ] #i | dip => 
;  : (( @ds [ @q ] | call/2 )) -- emptystack over push over push swap get-dict -rot runcc 


Die Wörter `get-ds` und `set-ds` sind keine Metawörter! Man muss sie dann allerdings im Kernel hinterlegen.

```clojure
user=> (defn get-ds [& r] r)
#'user/get-ds
user=> (get-ds 1 2 3 4)
(1 2 3 4)
user=> (get-ds '(1 2 3 4))
((1 2 3 4))
```

```clojure
user=> (defn set-ds [ds & r] {:pre [(seq ds)]} ds)
#'user/set-ds
user=> (set-ds 1 2 3)
Execution error (IllegalArgumentException) at user/set-ds (REPL:1).
Don't know how to create ISeq from: java.lang.Long
user=> (set-ds '(1 2 3) 4 5 6)
(1 2 3)
```
