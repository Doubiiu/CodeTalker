function [ sfun ] = signFunc( fun, sgn )
%SIGN Summary of this function goes here
%   Detailed explanation goes here
    sfun = fun;
    if strcmp(sgn,'pos')
        sfun( sfun < 0.0) = 0.0*sfun( sfun < 0.0);
    end
    if strcmp(sgn,'neg')
        sfun( sfun > 0.0) = 0.0*sfun( sfun > 0.0);
        sfun = -sfun;
    end
    if strcmp(sgn,'abs')
        sfun = abs(fun);
    end
end

