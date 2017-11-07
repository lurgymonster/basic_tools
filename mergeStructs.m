function [ structOut ] = mergeStructs( structIn1, structIn2 )

    structOut = structIn1;
    fieldNames = fieldnames(structIn2);
    for fii = 1:numel(fieldNames)
        structOut.(fieldNames{fii}) = structIn2.(fieldNames{fii});
    end
end

