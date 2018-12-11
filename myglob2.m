function [op,flag]=myglob2(pos)
flag=0;
pp=fileparts(pos);
try
tmp=ls(pos);
tmp=mystrsplit(tmp,'\n');
if length(tmp)>1
    error('specifically for single match only!')
end

op= tmp{1};
catch
   op=[];
   flag=1;
end