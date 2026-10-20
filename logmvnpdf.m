function [logp] = logmvnpdf(x,mu,Sigma)
% outputs log likelihood array for observations x  where x_n ~ N(mu,Sigma)
% x is N x D, mu is 1 x D, Sigma is D x D

[N,D] = size(x);
const = -0.5 * D * log(2*pi); % constant

xc = bsxfun(@minus,x,mu); % (x - mu); N x D

term1 = -0.5 * sum((xc / Sigma) .* xc, 2); % N x 1; This is the quadratic form of the Gaussian.
term2 = const - 0.5 * logdet(Sigma);    % scalar
logp = term1 + term2;

end

function y = logdet(A)

U = chol(A);
y = 2*sum(log(diag(U)));

end