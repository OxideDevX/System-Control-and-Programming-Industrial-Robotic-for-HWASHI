% 2D system(работает если свариваеться абсолютная плоскость)
function linIndex = sub2ind2d(sz, rowSub, colSub)
  linIndex = (colSub-1) * sz(1) + rowSub;

