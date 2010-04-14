$orderby = ' ORDER BY a.some ASC, b.else DESC';
$orderby =~  s/(BY|\,)\s+\w+\./$1 ttbl\./g;
print $orderby;
