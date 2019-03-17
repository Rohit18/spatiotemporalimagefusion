function pixval = newtest(x)

[r, c] = size(x);
temp = sum(x(:));
pixval = x(round(r/2),round(c/2))/temp;

end