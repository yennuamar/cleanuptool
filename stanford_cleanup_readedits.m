function edits=stanford_cleanup_readedits(fname)
mat=load(fname);
edits.excludeCORE=mat.storestruct.excludeCORE;
edits.excludeHYPO=mat.storestruct.excludeHYPO;
if isfield(mat.storestruct,'comment')
    edits.comment=mat.storestruct.comment;
else
    edits.comment='';
end