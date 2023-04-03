function samples = get_samples(shape, samples_number, samples_source)
%Sampling on mesh: fps_geodesic, fps_euclidean, or random
if nargin < 3
    samples_source = 'geodesic';
end
samples = [];

surface = shape.surface;
switch lower(samples_source)
    case 'euclidean'
        samples = fps_euclidean(shape, samples_number);
    case 'geodesic'
        samples = fps_geodesic(shape, samples_number);
    case 'random'
        samples = rps(surface, samples_number);
    otherwise
        error('Unsupported samples source: %s\n', samples_source);
end
end