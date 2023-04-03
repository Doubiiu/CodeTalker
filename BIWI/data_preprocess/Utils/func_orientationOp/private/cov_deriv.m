function [op, D] = cov_deriv(mesh, Vf, basis, basisi);
op = vf2op(mesh, Vf);
D = basisi * op * basis;