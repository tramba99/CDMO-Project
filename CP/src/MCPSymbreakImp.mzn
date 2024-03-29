include "globals.mzn";
include "alldifferent_except.mzn";
include "count_leq.mzn";
include "count.mzn";
include "value_precede.mzn";


% INPUT VARIABLES
int: m;                          % Number of couriers
int: n;                          % Number of items
set of int: LOADS = 1..m;
array[LOADS] of int: l;          % Maximum load for each courier
set of int: SIZES = 1..n;
array[SIZES] of int: s;          % Size of each item
array[1..n+1, 1..n+1] of int: D; % Distance matrix


% DECISION VARIABLES
array[1..m, 1..n+1] of var 1..n+1: routes; % Routes for each courier


% ---------------------------------------------------------------------------------------------------------------------
% CONSTRAINTS

% TWO COURIERS CANNOT GO TO THE SAME DISTRIBUTION POINT
% Value of all the variables must be different (except n+1 representing the origin point)
constraint 
  alldifferent_except(routes,{n+1});


% ALL ITEMS MUST BE DELIVERED
% Force values from 1 to n to appear exactly once
constraint 
  forall(i in 1..n)(
    count(routes,i,1));


% THE COURIER MUST FINISH IN THE ORIGIN POINT. 
% Force the value n+1 to appear at least once in the last position. In the worst case scenario a courier will deliver n-m+1 items,he will have a n+1 in the positions n-m+2..n+1 because we forced them to deliver at least one item. 
constraint 
  forall(i in 1..m, j in n-m+2..n+1)(
    routes[i, j] = n + 1);

  
% ONCE RETURNED TO ORIGIN, A COURIER CANNOT DELIVER MORE
% Force all the numbers after the first n+1 to be also n+1
constraint 
  forall(i in 1..m, j in 1..n)(
    if routes[i,j]==n+1 then routes[i,j+1] = n+1 
      else true endif);


% AVOID COURIER OVERLOAD
% Force that the total size of items assigned to each courier cannot exceed their maximum load size.
constraint
  forall(i in 1..m)(
    sum(j in 1..n where routes[i,j] != n+1)(s[routes[i,j]]) <= l[i]);


% SIMMETRY BREAKING
% Constraint to force the first value of each row of the matrix to be different from n+1
constraint 
  forall(i in 1..m)(
    routes[i, 1] != n+1);


% IMPLIED CONSTRAINT
% Force to have exactly (m*(n+1))-n n+1s 
constraint 
    count(routes,n+1,(m*(n+1))-n);

% ---------------------------------------------------------------------------------------------------------------------
% OBJECTIVE FUNCTION


%Application of the same objective function above to all couriers 
array[1..m] of var opt int: dist_courier =[sum(j in 1..n)(D[ routes[i, j], routes[i, j+1]]) +(D[n+1, routes[i,1]])|i in 1..m];


% ---------------------------------------------------------------------------------------------------------------------

% Solve
% Search annotations

ann: search_ann1 = int_search(routes, input_order, indomain_min);
ann: search_ann2 = int_search(routes, input_order, indomain_random);
ann: search_ann3 = int_search(routes, first_fail, indomain_min);
ann: search_ann4 = int_search(routes, first_fail, indomain_random);
ann: search_ann5 = int_search(routes, dom_w_deg, indomain_min); 
ann: search_ann6 = int_search(routes, dom_w_deg, indomain_random); 
 


solve :: search_ann3  minimize max(dist_courier);


       
output ["Objective function value: \(dist_courier)\n"];
output ["Routes value: \(routes)\n"];
