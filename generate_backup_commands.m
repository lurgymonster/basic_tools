function fileLines = generate_robocopy_bat( sourceDir, destDir, varargin )
%% fileLines = generate_xcopy_bat( sourceDir, destDir, backupName, instanceList )
% function to generate a batch script for copying files
% from SOURCEDIR to DESTDIR with a BACKUPNAME 
% INSTANCELIST contains a list of search strings with which to select the 
% files to be backed up.

command = 'robocopy';

%% parse variable input
if isempty(varargin)
    flags = '/s /xo';
    backupName = '';
    instanceList = {'.*'}; 
    fileName = [command, '_all.bat'];
else
    flags = varargin{1};
    instanceList = varargin{2};
    backupName = varargin{3};
    if isempty(instanceList)
        instanceList = {'.*'};
        backupName = 'all';
    end
    if isempty(backupName)
        fileName = [command, '_untitled.bat'];
    else
        destDir = [destDir, '\', backupName];
        fileName = [command, '_', backupName, '.bat'];
    end
    
end

%% iterate over list of instances to have separate command in batch
fID = fopen(fileName, 'wt');
fileLines = cell(size(instanceList));
for ii = 1:numel(instanceList)
    commandLine = [command, ' ', sourceDir, ...
        ' ', destDir, ' ', '*', instanceList{ii}, ' ', flags];
    fileLines{ii} = commandLine;
    fprintf(fID, '%s\n\r', commandLine);
%     fwrite(fID, sprintf('%s\n', commandLine));
end
fileLines = fileLines';
fclose(fID);

end

