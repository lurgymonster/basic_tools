function [outStruct] = collateCellFields(inStruct)

fieldsList = fieldnames(inStruct);
outStruct = struct();

for ii = 1:length(fieldsList)
    structField = inStruct.(fieldsList{ii});
    if iscell(structField)        
        outStruct.(fieldsList{ii}) = cell2mat([structField(:)]);
    else
        outStruct.(fieldsList{ii}) = structField;
    end
end 