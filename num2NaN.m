%% function to replace all given values of NUM with NaN values within an
%% array Grid

% MC Richter, 2016
% Dept. of Chemical Engineering, 
% University of Cape Town
function newGrid = num2NaN(Grid, varargin)

if isempty(varargin)
    num = 0;
else
    num = varargin{1};
end

[aa, bb] = size(Grid);
newGrid = Grid;

for i = 1:aa
    for j = 1:bb
        if newGrid(i, j) == num
            newGrid(i, j) = 0/0;
        end
    end
end