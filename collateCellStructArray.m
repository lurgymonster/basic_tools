function [outStruct] = collateCellStructArray(inStruct)

fieldsList = fieldnames(inStruct);
outStruct = struct();

for ii = 1:length(fieldsList)
    structField = getfield(inStruct, fieldsList{ii});
    if iscell(structField)
        colField = [];
        for jj = 1:length(structField)
            newlist = structField{jj};
%             fieldsList{ii}
%             whos newlist
            if strcmp(fieldsList{ii}, 't')
                if isempty(colField)
                    oldVal = 0; 
                else
                    oldVal = colField(end);
                end                    
                colField = [colField; oldVal+newlist];
            elseif ~strcmp(fieldsList{ii}, 'gx') ...
                    && ~strcmp(fieldsList{ii}, 'gy') ...
                    && ~strcmp(fieldsList{ii}, 'gz') ...
                    && ~strcmp(fieldsList{ii}, 'fitx') ...
                    && ~strcmp(fieldsList{ii}, 'fity') ...
                    && ~strcmp(fieldsList{ii}, 'fitz')
                colField = [colField; newlist];
            else
                colField{end+1} = newlist;
            end
        end
        outStruct = setfield(outStruct, fieldsList{ii}, colField);
    else
        outStruct = setfield(outStruct, fieldsList{ii}, structField);
    end
end 