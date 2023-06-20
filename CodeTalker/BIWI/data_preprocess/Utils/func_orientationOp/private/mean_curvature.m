function [mean_curv] = mean_curvature(V, T, W, Ae, smoothing_time)
	% Computes the mean curvature at each vertex of a given mesh.
	% This implementation utilizes the Laplace Beltrami (LB) operator of the mesh (see Notes).
	% 
	%
	% Parameters
	% ----------
	%           V                 :   (num_of_vertices x 3) 3D coordinates of the mesh vertices.
	%
	%           T                 :   (num_of_triangles x 3) T[i] are the 3 indices corresponding to the 3 vertices of the i-th triangle.
	%
	%           W                 :  (n x n) cotan weight matrix
	%                                             
	%           smoothing         :  (k x 1, optional) Vector 
	%                                Values corresponding to time samples for the heat diffusion smoothing         
	%
	% Returns
	% -------
	%           mean_curv         :  (num_vertices x k+1)
	%                                The mean curvature of each vertex.
	%                                If smoothing is applied then the first column contains
	%                                the mean curvature and the k-following columns contain
	%                                the k-smoothed versions of it.

	N = cross( V(T(:,1),:) - V(T(:,2),:), V(T(:,1),:) - V(T(:,3),:));
	N = [accumarray(T(:), repmat(N(:,1), [3,1])) , accumarray(T(:), repmat(N(:,2) , [3,1])), accumarray(T(:), repmat(N(:,3), [3,1]))];
	N = N ./ repmat(sqrt(sum(N.^2, 2)), [1, 3]);

	mean_curv = 0.5 * sum(N .* (W * V), 2);
            
	if exist('smoothing_time', 'var')
%         mean_curv = log(abs(mean_curv)+1);
		mean_curv_smooth = heat_diffusion_smoothing(W, Ae, mean_curv, smoothing_time);
		mean_curv        = [mean_curv, mean_curv_smooth];
	end
end

