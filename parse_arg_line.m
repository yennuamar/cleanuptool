function opstruct=parse_arg_line(strin)
% an input line of options (flags and assignments) such as:
% -r   (flag)
% -type=linear   (assignment)
%will be put in a structure. Flag fields are defined and set to 1.
%Assignment are parsed as strings



if isempty(strin)
    opstruct=[];
    return
end

opts=mystrsplit(strin,' ');

for k=1:length(opts)
    copt=opts{k};
    
    if isempty(findstr(copt,'='))
        opstruct.(copt(2:end))=1;
    else
        opstruct.(copt((2:findstr(copt,'=')-1)))=copt((findstr(copt,'=')+1):end);
    end
    
end


