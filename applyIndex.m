function [ outStruct ] = applyIndex( inStruct, indexFilter,  varargin)
% applyIndexToFields( inStruct, indexFilter,  fieldList) will apply the index
% filter INDEXFILTER to the fields of INSTRUCT structure listed in FIELDLIST
% and return OUTSTRUCT

    outStruct = inStruct;

    if ~isempty(varargin)
        fieldList = varargin{1};
    else % choose only the fields that have the correct dimension to apply indexFilter
        fieldList = fieldnames(inStruct);
        keepInd = zeros(1,length(fieldList));
        for tii = 1:length(fieldList)
            fieldDim = size(inStruct.(fieldList{tii}));
            filterDim = size(indexFilter);
            if sum(fieldDim==filterDim)==2
                keepInd(tii) = 1;
            end
        end
        fieldList = {fieldList{logical(keepInd)}};
    end

    for fii = 1:length(fieldList)
        inField = inStruct.(fieldList{fii});
        outField = inField(indexFilter);
        outStruct.(fieldList{fii}) = outField;
    end

end

