% % Binary search. 
% % Search 'sval' in sorted vector 'x', returns index of 'sval' in 'x'
% %  
% % INPUT:
% % x: vector of numeric values, x should already be sorted in ascending order
% %    (e.g. 2,7,20,...120)
% % sval: numeric value to be search in x
% %  
% % OUTPUT:
% % index: index of sval with respect to x. If sval is not found in x
% %        then index is empty.
       
function index = binarysearch(x,val)

if(val == x(1))
    index = 1;
    return;
end

if(val == x(end))
    index = length(x);
    return;
end

index=[];
from=1;
to=length(x);

while from<=to
    mid = round(from + (to - from)/2);    
    if(x(mid) <= val && x(mid+1) > val)
        index = mid;
        return;
    end
    if(x(mid) < val)
        from = mid+1;
    else
        to = mid-1;
    end
end



% % --------------------------------------------
% % Example code for Testing
% % x = sort(randint(1,1000,[0,400])); 
% % sval=12
% % index = binaraysearchasc(x,sval)
% % x(index)
% % --------------------------------------------

% % % --------------------------------
% % % Author: Dr. Murtaza Khan
% % % Email : drkhanmurtaza@gmail.com
% % % --------------------------------


