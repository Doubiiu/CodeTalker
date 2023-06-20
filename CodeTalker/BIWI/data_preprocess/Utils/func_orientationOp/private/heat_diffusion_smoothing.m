function [smoothed_fct] = heat_diffusion_smoothing(W, Ae, fct, diffusion_time) 
	% Computes the heat diffusion of a function at a given time using an implicit Euler scheme.
	% The resulting function will be smoother.
	%
	% Input:  W                  -  (n x n) cotan weight matrix
	%         fct                -  (n x 1) Vector containing the function values
	%         diffusion_time     -  (1 x k) Vector contining the diffusion times
	%
	% Output: smoothed_fct       -  (n x k) Matrix with the values of k smoothed function
            
	if size(diffusion_time, 1) > 1
		diffusion_time = diffusion_time';
	end

	if size(diffusion_time, 1) ~= 1
		error('Variable "Time" should be vector');
	end
	if size(W, 1) ~= size(W, 2)
		error('Given LB matrix is not square');
	end
	if size(W, 2) ~= size(fct, 1)
		error('Uncompatible size between function and operator');
	end
	if size(fct, 2) ~= 1
		error('Variable "Function" should be a column vector');
	end

	diffusion_time = sort(diffusion_time);    % Time must be increasing.
	n = size(W, 2);
	k = size(diffusion_time, 2);
	
	smoothed_fct       = zeros(n, k);
	smoothed_fct(:,1)  = (Ae + (diffusion_time(1) * W )) \ (Ae * fct);
	for i = 2:k
		smoothed_fct(:,i) = ( Ae + (diffusion_time(i) - diffusion_time(i-1) ) * W ) \ (Ae * smoothed_fct(:, i-1)) ;
	end
end