function outArray = collateCellScalarField(inStructCell, fieldName, varargin)

if ~isempty(varargin)
    indSel = varargin{1};
else
    indSel = 1:numel(inStructCell);
end

outArray = zeros(size(inStructCell));
for sii = 1:numel(inStructCell)
    fieldVal = getfield(inStructCell{sii}, fieldName);
    if isscalar(fieldVal)
        outArray(sii) = fieldVal;
    else
        outArray(sii) = NaN;
    end
end

