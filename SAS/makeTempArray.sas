/*
    Macro makeTempArray
    
    Purpose: To create temporary arrays without knowing the
             size of the array needed beforehand. This is a 
             limitation of the original SAS procedure for
             creating temporary arrays.
    
    Parameters:
        arrayname : an arbitrary name for your array
        ischar    : pass either Y for a character array 
                    or N for numeric
        items     : pass the list of items to be contained in
                    the array, wrapped in %str() and separated
                    by commas
*/

%macro makeTempArray(arrayname=, ischar=, items=);
    %let n=%sysfunc(countw(&items., ',', )); /*count the number of items to reserve space for*/
   
    %if &ischar.=Y %then %do; /*if this is a character array, we need the length of the longest item*/ 
        %let l = 1;
        %do j = 1 %to &n.;
            %let l0 = %sysfunc(length(%sysfunc(scan(&items., &j., ',', r))));
            %if  &l0. > &l. %then %let l = &l0.;
        %end;
    %end;
    
    array &arrayname. {&n.} %if &ischar.=Y %then $&l.; _temporary_ (
        %do i = 1 %to &n.;
            %let item = %sysfunc(scan(&items., &i., ',', r));
            %if &ischar.=Y %then %str("&item." ); %else &item.;
        %end;
    );
%mend makeTempArray;

data test;
    set sashelp.cars;
    
    %makeTempArray(arrayname=%str(my_cars), ischar=%str(Y), items=%str(AUDI, LAND ROVER, MERCEDES-BENZ));
    %makeTempArray(arrayname=%str(my_cyls), ischar=%str(N), items=%str(6));
    
    /*Look for all Audis, Land Rovers, and Mercs with 6 cylinders*/
    if (upcase(make) not in my_cars) or (cylinders not in my_cyls) then delete;
run;