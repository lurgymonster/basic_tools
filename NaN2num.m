%% function to replace all NaN values with input value NUM, in array GRID 
%% default NUM=0

% MC Richter, 2016
% Dept. of Chemical Engineering, 
% University of Cape Town
function newGrid = NaN2num(Grid, varargin)

if isempty(varargin)
    num = 0;
else
    num = varargin{1};
end

[aa, bb] = size(Grid);
newGrid = Grid;

for i = 1:aa
    for j = 1:bb
        if isnan(newGrid(i, j))
            newGrid(i, j) = num;
        end
    end
end