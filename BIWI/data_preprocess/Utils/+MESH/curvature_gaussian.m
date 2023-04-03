function [gauss_curv] = curvature_gaussian(V, T, W, Ae, smoothing_time)                                        
    % Computes the Gaussian curvature at each vertex of a given mesh.
    % (Optional) A smoothing using the heat diffusion can be done
    % as post-processing.
    %
    % Input:
    %         inmesh            -  (Mesh)
    %
    %         laplace_beltrami  -  (Laplace_Beltrami)The corresponding LB of the inmesh.
    %
    %         smoothing         -  (k x 1, Optional) vector with time for the
    %                              heat diffusion processing.
    %
    % Output:
    %         gauss_curv        -  (num_vertices x k+1) The gaussian curvature of each vertex.
    %                              If smoothing is applied then the first column contains
    %                              the mean curvature and the k-following columns contain
    %                              the k-smoothed versions of the mean.
    %
    % Notes: See Meyer, M. Desbrun, P. Schroder, and A. H. Barr. "Discrete
    %            Differential-Geometry Operators for Triangulated 2-Manifolds."

    angles  = angles_of_triangles(V, T);
    areas = full(sum(Ae,2));

    gauss_curv = ( 2 * pi - accumarray(T(:), angles(:))) ./ areas;   % TODO-E: Is it OK that areas not normalized?

    if exist('smoothing_time', 'var')
%         gauss_curv = log(abs(gauss_curv)+1);
        gauss_curv_smooth = heat_diffusion_smoothing(W, Ae, gauss_curv, smoothing_time);
        gauss_curv        = [gauss_curv, gauss_curv_smooth];
    end
end