% Projection onto the simplex or the l1 ball.

% Author: Laurent Condat, PhD, CNRS research fellow in Grenoble, France.
% Version: 1.0, Sept. 18, 2015.
% Copyright: Laurent Condat.
% Plase contact me for any question or remark: http://www.gipsa-lab.grenoble-inp.fr/~laurent.condat/

% Description: A compact and efficient Matlab function to project every column of a N-D array y over the simplex, i.e. the set of vectors with nonnegative elements whose sum is one (or any a>0 by changing "-1" by "-a" in the function). 

% This algorithm is the simplest one, based on sorting. If we define K=size(y,1), the length of the columns of y, the complexity is dominated by the sort, so it is O(K.log(K)) for every column. There exist more efficient O(K) algorithms, see 
% L. Condat, "Fast Projection onto the Simplex and the l1 Ball," Mathematical Programming Series A., 2015
% but for small K, say up to 100, there is no gain in using them in Matlab instead of the code here.

% The trick used here is that for every column of y, the result of bsxfun(...) is a vector whose elements are nondecreasing up to a certain index, at which the value is the desired threshold, and nonincreasing after. So, the desired threshold is simply the maximal element of this vector.

proj_simplex_array = @(y) max(bsxfun(@minus,y,max(bsxfun(@rdivide,cumsum(sort(y,1,'descend'),1)-1,(1:size(y,1))'),[],1)),0);

% For y a column vector, one can simplify the function to

proj_simplex_vector = @(y) max(y-max((cumsum(sort(y,1,'descend'),1)-1)./(1:size(y,1))'),0);

% Now comes the adaptation to project onto the l1 ball of radius 1 (or any radius a>0 by changing the "-1" by "-a"). The trick used here is that we compute the threshold like above, and if it is negative, then y is inside the ball, so there is nothing to do and the threshold is set to zero.

proj_l1ball_array = @(y) max(bsxfun(@minus,abs(y),max(max(bsxfun(@rdivide,cumsum(sort(abs(y),1,'descend'),1)-1,(1:size(y,1))'),[],1),0)),0).*sign(y);

% For y a column vector, one can simplify the function to

proj_l1ball_vector = @(y) max(abs(y)-max(max((cumsum(sort(abs(y),1,'descend'),1)-1)./(1:size(y,1))'),0),0).*sign(y);
