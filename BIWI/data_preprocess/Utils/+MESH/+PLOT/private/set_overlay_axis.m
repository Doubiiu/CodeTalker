function [xdiam, ydiam, zdiam] = set_overlay_axis(xdiam, ydiam, zdiam, overlay_axis)
switch lower(overlay_axis)
    case 'x'
        ydiam = 0; zdiam = 0;
    case 'y'
        xdiam = 0; zdiam = 0;
    case 'z'
        xdiam = 0; ydiam = 0;
    case 'xy'
        zdiam = 0;
    case 'xz'
        ydiam = 0;
    case 'yz'
        xdiam = 0;
    case 'xyz'
    otherwise
        error('invalid overlay_axis type')
end
end