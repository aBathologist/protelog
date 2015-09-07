:- module(composer,
          [ op(200, xfx, user:(=:)),
            op(100, xfy, user:(<-)),
            op(50, fx, user:(//)),
            op(50, fx, user:(inv)),
            
            (=:)/2,
            (<-)/2,
            (//)/2,
            inv/2,
            inv/3
          ]).

%% ?Defined =: +Predicate
%
% Provide a definition-like syntax for unifying with the last argument of
% a predicate (which is left implicit):
%
%       ?- X =: plus(1,2).
%       X = 3.
%
% This operator provides syntax that resembles functional notation, but it
% does *not* facilitate functional syntax. It is just notation for emphasizing
% the last component of a relation. E.g.,
%
%       ?- 3 =: plus(1,X).
%       X = 2.

V =: P1 <- P0 :- X =: P0, call(P1, X, V).
V =: Pred     :- Pred \= _ <- _, call(Pred, V).

%% +TruncatedPred1 <- +TruncatedPred0
% 
% Compose predicates, equivalent to
%
%   call(TruncatedPred0, X), call(TruncatedPred1, X)
%
% e.g.:
%
%   ?- write <- string_concat("Hello, ", "world!").
%   Hello, world!
%
% Used with =:/2, these compositions can be chained, with intermediate argumetns
% supplied. E.g.,
% 
%   ?- W = "ABCDEFG",
%      LowerCaseReversed =: inv string_chars <- reverse <- string_chars <- string_lower(W).
%   LowerCaseReversed = "gfedcba".

P2 <- P1 <- P0 :- X =: P0, P1_ =.. [P1,X], P2 <- P1_.

P1 <- P0 :- X =: P0, X =: P1.

%% "pass through" arguments.
%
% Useful for testing an arguments properties, e.g.:
%
%       ?-  X =: sumlist <- //is_list <- last([1,2,3,[4,5,6]]).
%       X = 15.
%
% Also useful for passing along bound partial terms, e.g.:
%
%       ?- TenThrees =: //maplist(=(3)) <- inv length(10).
%       TenThrees = [3, 3, 3, 3, 3, 3, 3, 3, 3|...].

//(P1, X, X) :- call(P1, X).
//(X, X).

%% inv(+Pred, ?A, ?B)
%
% The inverse of a relation Pred, e.g.,
%
%   ?- length(X, 3).
%   X = [_G32877, _G32880, _G32883].
%
%   ?- inv(length, 3, X).
%   X = [_G32873, _G32876, _G32879].
%
% inv/2 is sugar to allow for cleaner inversion in compositions:
%
%   numlist(1,5,Ns),<- <- length

inv(P, A, B) :- call(P, B, A).
inv(P0, B)    :-
    P0 =.. [F|Args],
    append(Rest, [A], Args),
    append(Rest, [B, A], InvertedArgs),
    apply(F, InvertedArgs).