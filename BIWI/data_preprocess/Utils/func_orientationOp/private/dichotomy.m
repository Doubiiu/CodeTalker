function [ k ] = dichotomy( test, fun, data , k1, k2, min_max)
%DICHOTOMY outputs min or max k within range k1, k2 such that output of fun
%satisfies test
%   Detailed explanation goes here
k2 = max(k2,k1);
k = min(max(int((k2+k1)/2), k1),k2);
if k2 - k1 <= 1
    if strcmp(min_max, 'max') 
        if test(fun(data, k))
            k1 = k;
            k = dichotomy( test, fun, data , k1, k2, min_max);
        else
            k2 = k;
            k = dichotomy( test, fun, data , k1, k2, min_max);
        end    
    else % max_min == 'min'
        if test(fun(data, k))
            k2 = k;
            k = dichotomy( test, fun, data , k1, k2, min_max);
        else
            k1 = k;
            k = dichotomy( test, fun, data , k1, k2, min_max);
        end 
    end
end

end

